# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An iOS 3D game engine written against **Metal/MetalKit**. It began life as an OpenGL ES project (following ThinMatrix's OpenGL tutorial series — hence the "GL" name and the ThinMatrix assets) and has since been fully migrated: rendering, math types (`simd`), and vocabulary are all native Metal now; only the project name and some class names (`RawModel`, `Loader`, …) remain from that era. The engine renders a scene of terrain, entities (rocks, trees, grass, farmhouse, boat, lamps), a skybox with a day/night cycle, and reflective/refractive water.

Objective-C, no package manager — it is a personal graphics project built with Xcode. Unit tests for the GPU-free logic live in `GLGameEngineTests` (see below).

## Build & run

Open `GLGameEngine.xcodeproj` in Xcode, or from the command line:

```sh
# Build the iOS app
xcodebuild -project GLGameEngine.xcodeproj -scheme GLGameEngine -sdk iphoneos build

# Build for the simulator (works despite the clip-distance GPU check — see below)
xcodebuild -project GLGameEngine.xcodeproj -scheme GLGameEngine -sdk iphonesimulator build

# Run the unit tests (hosted in the app, so they need a Metal-capable simulator)
xcodebuild -project GLGameEngine.xcodeproj -scheme GLGameEngine \
  -destination 'platform=iOS Simulator,name=iPhone 17' test

# List schemes/targets
xcodebuild -list -project GLGameEngine.xcodeproj
```

Targets: `GLGameEngine` (iOS, deployment target 17.0) and `GLGameEngineTests` (XCTest bundle hosted in the app; tests import engine headers via `USER_HEADER_SEARCH_PATHS` and link against the host app's symbols, so engine sources are not compiled twice). A legacy `GLGameEngine Mac` target existed pre-Metal-migration but was removed (see git history).

Requires a real device or a Metal-capable simulator: `ViewController initMetalContext` exits if no Metal device is found, and asserts `MTLGPUFamilyApple4` (A11+) support for `[[clip_distance]]` — but only on real devices (`#if !TARGET_OS_SIMULATOR`).

## Architecture

### Core Metal objects

- **`MetalContext`** (singleton, `sharedContext`) owns the `MTLDevice`, `MTLCommandQueue`, per-frame command buffer, and the current `MTLRenderCommandEncoder`. Render passes are **staged**: `stagePassDescriptor:` ends the current encoder and records the next pass's descriptor; the encoder is created **lazily on the first draw**, so a pass's clear values can still be configured after staging (see `MasterRenderer prepare`). It also owns prebuilt `MTLDepthStencilState`s (`dsLessWrite`, `dsAlwaysNoWrite`), three prebuilt `MTLSamplerState`s (`samplerMipRepeat`, `samplerLinearClamp`, `samplerNearestClamp`), and the `cullingEnabled` toggle (applied to the current encoder immediately; `MasterRenderer +enableCulling`/`+disableCulling` wrap it). New encoders default to counter-clockwise front faces (Metal's default is clockwise!), back-face culling, and less+write depth.
- **`ShaderProgram`** (abstract base) wraps an `MTLRenderPipelineState` plus accumulated uniform state. Subclasses implement `createVertexDescriptor`, optionally `configurePipelineDescriptor:` (e.g. blending), and `uploadUniforms` (copies the uniform structs onto the current encoder via `setVertexBytes`/`setFragmentBytes` just before each draw). The `load…:` setter methods mutate uniform structs held by the subclass; that state persists across draws. `bindPipeline` sets the pipeline state on the encoder.
- **`RawModel`** holds up to 4 vertex buffers (one per attribute, slots 0–3) plus the index buffer; `bindBuffersToEncoder` sets them on the current encoder. For indexed models `vertexCount` holds the index count.

### Math — simd everywhere

All CPU-side math uses `simd` types (`simd_float4x4`, `simd_float3x3`, `simd_float2/3/4`) — the same types the shaders consume, so uniform structs are filled without conversion. `MathUtils` provides what simd lacks: affine constructors (`MathUtils_MatrixMakeTranslation/Scale/X-Y-ZRotation`), `MathUtils_MatrixMakePerspective` (GL-style z∈[-1,1] convention; `MasterRenderer createProjectionMatrixWithAspect:` multiplies a conversion matrix on top for Metal's z∈[0,1] clip space — keep these two in sync), `MathUtils_Matrix4GetUpperLeft3x3`, the transformation/normal-matrix builders, barycentric terrain interpolation, and randomness. **Note:** `Rotation` and the rotation parameters of the transformation-matrix builders are in **degrees**.

### Shader/uniform conventions — `ShaderTypes.h`

`ShaderTypes.h` is the single source of truth shared between Objective-C and the `.metal` shaders. It defines:
- `BufferIndex` — vertex buffer slots (positions=0, texCoords=1, normals=2, instance matrices=3, vertex uniforms=4; fragment uniforms=0 in the fragment namespace).
- `TextureIndex` — fragment texture slots, grouped per shader family.
- One `…VertexUniforms` / `…FragmentUniforms` struct per shader program. `MAX_LIGHTS` is 4.

Shaders are the `.metal` files (`StaticShaders.metal`, `TerrainShaders.metal`, `SkyboxShaders.metal`, `WaterShaders.metal`, `InstancingShaders.metal`, `GUIShaders.metal`). When changing a shader, edit the `.metal` file and the matching struct in `ShaderTypes.h`. (The original GLSL sources live in git history.)

### Rendering pipeline — `MasterRenderer` + `ViewController`

`ViewController` is the `MTKViewDelegate`; its view is an `MTKView` (`metalView`). Per frame (`drawInMTKView:`):
1. `MetalContext beginFrame` opens the command buffer.
2. `process…` methods (`processEntity:`, `processTerrain:`, `processWaterTile:`) batch scene objects into `MasterRenderer`'s per-renderer collections.
3. Water reflection/refraction are rendered first into off-screen `WaterFrameBuffers` (`bindReflectionFrameBuffer`/`bindRefractionFrameBuffer` stage those passes; the camera is moved/pitch-inverted for the reflection pass), each via `renderWithLights:camera:andClippingPlane:` with a different clipping plane.
4. `bindDrawable` stages the on-screen drawable's pass; the scene is rendered again, then water (`renderWaterWithCamera:andLight:`), then optional debug GUI.
5. `MetalContext endFrameAndPresentDrawable:` commits and presents.

`MasterRenderer` owns one shader + one renderer per object family: `StaticShaderProgram`/`EntityRenderer`, `TerrainShader`/`TerrainRenderer`, `SkyboxShader`/`SkyboxRenderer`, `WaterShader`/`WaterRenderer`, `GUIShader`/`GUIRenderer`, and an `InstancingShaderProgram` for instanced models. Each renderer binds its shader's pipeline, sets uniforms, binds the model's `RawModel`/texture, and issues the draw. Fog (`Fog` struct) and sky color (`RGBA`) are global render settings.

### Scene construction

`ViewController setupEntities` hand-builds the demo scene: loads OBJ models via `OBJLoader2` (Model I/O; the older `OBJLoader` v1 was removed), scatters rocks/trees/grass/flowers using `MathUtils_RandomFloat` and terrain height sampling (`Terrain getHeightAtWorldX:worldZ:`), and places lights. Instanced rendering (`InstanceableTexturedModel` / `InstancingShaderProgram` / `InstancingShaders.metal`) is unused scaffolding: nothing feeds `instancedEntities`, and `MasterRenderer` skips the instancing shader when that collection is empty.

Entities cache their transformation matrix behind a dirty flag (`Entity.m`); any new mutation path for position/rotation/scale must invalidate it (route through the property setters). `MasterRenderer`'s batch dictionary and arrays are reused across frames — `clearEntities` empties the batches rather than removing them, and `EntityRenderer` skips empty batches. `TexturedModel` keys that dictionary via UUID-based `isEqual:`/`hash` (copies share the UUID and therefore the batch).

### Model formats

`.mm` files (Objective-C++) are used where C++ is needed — `OBJLoader2.mm`, `Loader.mm`, `Buffer.mm`, `InstanceableTexturedModel.mm`, `Terrain.mm`. Plain `.m` elsewhere.

## Testing

`GLGameEngineTests` covers the GPU-free logic: `MathUtils` (barycentric terrain interpolation, affine constructors, transformation/normal matrices), `Camera`, `Entity` (incl. the transform cache), `TexturedModel` equality/hashing, the `Buffer` C API, and `Terrain` height sampling (via its CPU-only `initWithGridX:gridZ:heightMapData:width:height:` initializer). Renderers/shaders/loaders need a `MetalContext` device and are not unit-tested. When touching entity/camera/matrix math, run the tests — they pin the exact matrix outputs.

## Conventions

- Assets (`.obj`, `.png`, `.jpg`) live directly in the `GLGameEngine/` source directory alongside code and are loaded by name at runtime.
- simd vector elements are not addressable (`&v.x` won't compile); copy to locals when packing bytes (see `Terrain generateTerrain:`).
- `simd_float3` is 16 bytes (padded), not 12 — never `memcpy` arrays of them as packed float triples; build packed buffers from scalar floats.
