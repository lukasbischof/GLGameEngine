# Remove the OpenGL→Metal type bridge — native simd types throughout

Date: 2026-07-12 · Status: approved by Lukas

## Goal

The engine was migrated from OpenGL ES to Metal but kept a GL compatibility
skin: `GLTypesShim.h` (GL scalar typedefs), GLKit math types everywhere
(`GLKMatrix4`, `GLKVector3`, …) converted to simd at the uniform-upload
boundary via `SIMDBridge.h`, and GL vocabulary in method names/comments.
Remove that skin: native Metal/simd types end to end.

## Decisions (user-confirmed)

- **Types**: GLKit math types → `simd_float4x4`/`simd_float3x3`/`simd_float2/3/4`.
  GL scalars → `float`, `uint32_t`, `int32_t`, `uint8_t`, `BOOL`. Delete
  `GLTypesShim.h` and `SIMDBridge.h` (no conversion boundary remains).
- **Naming**: GL-era method names and comments move to Metal vocabulary
  (`bindVAO` → `bindBuffersToEncoder`, `initGLObjects` → `initSceneObjects`,
  `glview` → `metalView`, `ShaderProgram.activate` → `bindPipeline`).
  Class names stay (RawModel, Loader, MasterRenderer, …).
- **Architecture**: render flow untouched — staged pass descriptor with lazy
  encoder creation, uniform-state accumulation in shader programs, per-family
  renderers. This migration changes types and names only.

## Math strategy

`MathUtils` stays the math home, rewritten on simd. simd provides
`simd_mul`, `simd_inverse`, `simd_transpose`, vector operators; it lacks
affine constructors, so `MathUtils` gains helpers that replicate GLKit's
formulas exactly (bit-compatible rendering):

- `MathUtils_MatrixMakeTranslation/Scale/XRotation/YRotation/ZRotation`
- `MathUtils_MatrixMakePerspective` (same RH, GL-clip-space convention;
  `MasterRenderer`'s GL→Metal clip conversion matrix stays unchanged)
- `MathUtils_Matrix4GetUpperLeft3x3`
- `MathUtils_CreateNormalMatrix` uses `simd_determinant` to keep the
  identity fallback for non-invertible matrices (behavior pinned by tests)

`Rotation` struct (degrees) is kept.

## Risks / mitigations

- `simd_float3` is 16 bytes (GLKVector3 was 12, packed): audit every
  memcpy/buffer-building site. `ShaderTypes.h` is already simd; Terrain
  vertex generation appends scalar floats — safe.
- Rotation-matrix and perspective formulas must match GLKit exactly —
  unit tests assert numeric expectations and point-transform properties
  independently of the helpers.

## Order of work (build + test after each)

1. `MathUtils` on simd (+ helpers), tests updated alongside
2. Value classes: Camera, Entity, Light, WaterTile, Terrain, Fog/RGBA
3. Renderers, shader programs, ViewController, MasterRenderer; delete
   `SIMDBridge.h` (uniform structs take simd values directly)
4. Delete `GLTypesShim.h`, replace GL scalars, apply renames, rewrite
   GL-correspondence comments; drop the GLKit framework dependency
5. Tests fully on simd (`MatrixAssertions.h` on simd; `SIMDBridgeTests`
   deleted with the bridge); final: full test run + simulator screenshot
   compared against the pre-migration scene
