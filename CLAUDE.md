# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

An iOS 3D game engine, originally written against OpenGL ES (following ThinMatrix's OpenGL tutorial series — hence the "GL" name and the ThinMatrix assets). It is **mid-migration to Metal**: the iOS target (`GLGameEngine`) now renders entirely with Metal/MetalKit, while retaining the OpenGL-era class structure and naming. The engine renders a scene of terrain, entities (rocks, trees, grass, farmhouse, boat, lamps), a skybox, and reflective/refractive water.

Objective-C, no package manager, no test suite of substance — it is a personal graphics project built with Xcode.

## Build & run

Open `GLGameEngine.xcodeproj` in Xcode, or from the command line:

```sh
# Build the iOS app (the actively-maintained, Metal-migrated target)
xcodebuild -project GLGameEngine.xcodeproj -scheme GLGameEngine -sdk iphoneos build

# Build for the simulator (works despite the clip-distance GPU check — see below)
xcodebuild -project GLGameEngine.xcodeproj -scheme GLGameEngine -sdk iphonesimulator build

# List schemes/targets
xcodebuild -list -project GLGameEngine.xcodeproj
```

Targets: `GLGameEngine` (iOS, deployment target 17.0 — **this is the one to work on**), `GLGameEngine Mac` (legacy macOS, deployment target 10.11), plus `GLGameEngineTests` / `GLGameEngine MacTests` (empty scaffolding). The Mac target predates the Metal migration and is not maintained.

Requires a real device or a Metal-capable simulator: `ViewController initMetalContext` calls `exit()` if no Metal device is found, and asserts `MTLGPUFamilyApple4` (A11+) support for `[[clip_distance]]` — but only on real devices (`#if !TARGET_OS_SIMULATOR`).

## Architecture

### The OpenGL → Metal translation layer

The migration deliberately preserved the OpenGL call structure and mapped each GL concept onto a Metal equivalent, so old rendering code reads almost unchanged. **When editing rendering code, work with the grain of these mappings** rather than reintroducing raw GL idioms:

- **`MetalContext`** (singleton, `sharedContext`) replaces the implicit global `EAGLContext` state. It owns the `MTLDevice`, `MTLCommandQueue`, per-frame command buffer, and the current `MTLRenderCommandEncoder`. Key translations, documented in `MetalContext.h`:
  - "Bind a framebuffer" → `stagePassDescriptor:` stages an `MTLRenderPassDescriptor`; the encoder is created **lazily** on first draw, so the GL order (bind FBO → set clear color → clear → draw) keeps working.
  - `glEnable/glDisable(GL_DEPTH_TEST)` → two prebuilt `MTLDepthStencilState`s (`dsLessWrite`, `dsAlwaysNoWrite`).
  - `glTexParameteri` sampler configs → three prebuilt `MTLSamplerState`s (`samplerMipRepeat`, `samplerLinearClamp`, `samplerNearestClamp`).
  - `glEnable/glDisable(GL_CULL_FACE)` → `cullingEnabled` property (applied to the current encoder immediately). `MasterRenderer +enableCulling`/`+disableCulling` wrap this.
- **`ShaderProgram`** (abstract base) = a GL program → an `MTLRenderPipelineState` plus accumulated uniform state. Subclasses implement `createVertexDescriptor` (was `bindAttributes`), optionally `configurePipelineDescriptor:` (e.g. blending), and `uploadUniforms` (writes the uniform struct onto the current encoder just before each draw). The former `glUniform*` calls became `load…:` setter methods that mutate a uniform struct held by the subclass; that state persists across draws exactly like GL uniform state did. `activate` sets the pipeline state on the encoder.
- **`RawModel`** = the former VAO: holds up to 4 vertex buffers (one per attribute, slots mirroring GL attribute locations) plus an index buffer. `bindVAO` = `glBindVertexArray`. For indexed models `vertexCount` holds the element (index) count, as under GL.
- **`GLTypesShim.h`** re-typedefs `GLfloat`, `GLuint`, etc. as plain scalars so the OpenGL-era method signatures compile after the OpenGL ES framework was removed. `GLKit`/`GLKMath` is still used for vector/matrix math (`GLKVector3`, `GLKMatrix4`, …).

### Shader/uniform conventions — `ShaderTypes.h`

`ShaderTypes.h` is the single source of truth shared between Objective-C and the `.metal` shaders. It defines:
- `BufferIndex` — vertex buffer slots (positions=0, texCoords=1, normals=2, instance matrices=3, vertex uniforms=4; fragment uniforms=0 in the fragment namespace).
- `TextureIndex` — fragment texture slots, mirroring the old GL texture units per shader family.
- One `…VertexUniforms` / `…FragmentUniforms` struct per shader program (each GLSL shader's uniforms collapsed into a struct). `MAX_LIGHTS` is 4.

**Active shaders are the `.metal` files** (`StaticShaders.metal`, `TerrainShaders.metal`, `SkyboxShaders.metal`, `WaterShaders.metal`, `InstancingShaders.metal`, `GUIShaders.metal`) — these are what the Sources build phase compiles. The `.vsh`/`.fsh` GLSL files are the **legacy OpenGL originals, kept for reference only** and not built. When changing a shader, edit the `.metal` file (and matching struct in `ShaderTypes.h`), not the `.vsh`/`.fsh`.

### Rendering pipeline — `MasterRenderer` + `ViewController`

`ViewController` is the `MTKViewDelegate`; its view is an `MTKView` (`glview`). Per frame (`drawInMTKView:`):
1. `MetalContext beginFrame` opens the command buffer.
2. `process…` methods (`processEntity:`, `processTerrain:`, `processWaterTile:`) batch scene objects into `MasterRenderer`'s per-renderer collections.
3. Water reflection/refraction are rendered first into off-screen `WaterFrameBuffers` (`bindReflectionFrameBuffer`/`bindRefractionFrameBuffer` stage those passes; the camera is moved/pitch-inverted for the reflection pass), each via `renderWithLights:camera:andClippingPlane:` with a different clipping plane.
4. `bindDrawable` stages the on-screen drawable's pass; the scene is rendered again, then water (`renderWaterWithCamera:andLight:`), then optional debug GUI.
5. `MetalContext endFrameAndPresentDrawable:` commits and presents.

`MasterRenderer` owns one shader + one renderer per object family: `StaticShaderProgram`/`EntityRenderer`, `TerrainShader`/`TerrainRenderer`, `SkyboxShader`/`SkyboxRenderer`, `WaterShader`/`WaterRenderer`, `GUIShader`/`GUIRenderer`, and an `InstancingShaderProgram` for instanced models. Each renderer binds its shader, sets uniforms, binds the model's `RawModel`/texture, and issues the draw. Fog (`Fog` struct) and sky color (`RGBA`) are global render settings.

### Scene construction

`ViewController setupEntities` hand-builds the demo scene: loads OBJ models via `OBJLoader2` (`OBJLoader` is the older variant), scatters rocks/trees/grass/flowers using `MathUtils_RandomFloat` and terrain height sampling (`Terrain getHeightAtWorldX:worldZ:`), and places lights. Instanced rendering (`InstanceableTexturedModel`, the `instanceableModels` path) is scaffolded but currently commented out in favor of per-entity draws.

### Model formats

`.mm` files (Objective-C++) are used where C++ is needed — the OBJ loaders (`OBJLoader.mm`, `OBJLoader2.mm`), `Loader.mm`, `Buffer.mm`, `InstanceableTexturedModel.mm`, `Terrain.mm`. Plain `.m` elsewhere. `SIMDBridge.h` bridges `GLKit` matrix types to `simd` types for the uniform structs.

## Conventions

- Assets (`.obj`, `.png`, `.jpg`) live directly in the `GLGameEngine/` source directory alongside code and are loaded by name at runtime.
- The GL-era naming is intentional throughout (`initGLObjects`, `bindVAO`, `GLfloat`, class names) — preserve it; it maps to a mental model the rest of the code shares. Comments generally explain the OpenGL→Metal correspondence.
