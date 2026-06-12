//
//  ShaderTypes.h
//  GLGameEngine
//
//  Types shared between the Objective-C renderer and the Metal shaders:
//  buffer/texture index conventions and the per-shader uniform structs.
//  (The GLSL "uniform" variables of each shader program became one struct.)
//

#ifndef GLGameEngine_ShaderTypes_h
#define GLGameEngine_ShaderTypes_h

#include <simd/simd.h>

#ifndef MAX_LIGHTS
#define MAX_LIGHTS 4
#endif

// Vertex buffer slots. 0-3 mirror the OpenGL attribute locations,
// the uniform struct lives in its own slot above them.
typedef enum BufferIndex {
    BufferIndexPositions        = 0,
    BufferIndexTexCoords        = 1,
    BufferIndexNormals          = 2,
    BufferIndexInstanceMatrices = 3, // occupies vertex attributes 3-6 (one vec4 each)
    BufferIndexVertexUniforms   = 4,
    BufferIndexFragmentUniforms = 0  // fragment stage namespace
} BufferIndex;

// Fragment texture indices mirror the OpenGL texture units exactly.
typedef enum TextureIndex {
    // Static/Instancing entities + GUI
    TextureIndexDiffuse     = 0,

    // Terrain
    TextureIndexBackground  = 0,
    TextureIndexR           = 1,
    TextureIndexG           = 2,
    TextureIndexB           = 3,
    TextureIndexBlendMap    = 4,

    // Skybox
    TextureIndexCubeDay     = 0,
    TextureIndexCubeNight   = 1,

    // Water
    TextureIndexReflection  = 0,
    TextureIndexRefraction  = 1,
    TextureIndexDuDvMap     = 2,
    TextureIndexNormalMap   = 3,
    TextureIndexDepthMap    = 4
} TextureIndex;

// VertexShader.vsh + InstancingVertexShader.vsh uniforms
typedef struct {
    matrix_float4x4 transformationMatrix; // unused by the instancing variant (per-instance attribute)
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
    float density;                        // fog
    float gradient;                       // fog
    float numberOfRows;                   // texture atlas (loaded as float, like glUniform1f did)
    vector_float2 offset;                 // texture atlas
    vector_float3 lightPosition[MAX_LIGHTS];
    vector_float4 clippingPlane;
} StaticVertexUniforms;

// FragmentShader.fsh uniforms (shared by static + instancing pipelines)
typedef struct {
    vector_float3 lightColor[MAX_LIGHTS];
    vector_float3 attenuation[MAX_LIGHTS];
    vector_float3 skyColor;
    float damper;
    float reflectivity;
} StaticFragmentUniforms;

// TerrainVertexShader.vsh uniforms
typedef struct {
    matrix_float4x4 transformationMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
    float density;
    float gradient;
    vector_float3 lightPosition[MAX_LIGHTS];
    vector_float4 clippingPlane;
} TerrainVertexUniforms;

// TerrainFragmentShader.fsh uniforms
typedef struct {
    vector_float3 lightColor[MAX_LIGHTS];
    vector_float3 attenuation[MAX_LIGHTS];
    vector_float3 skyColor;
} TerrainFragmentUniforms;

// SkyboxVertexShader.vsh / SkyboxFragmentShader.fsh uniforms
typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
} SkyboxVertexUniforms;

typedef struct {
    vector_float3 fogColor;
    float blendFactor;
} SkyboxFragmentUniforms;

// WaterVertexShader.vsh / WaterFragmentShader.fsh uniforms
typedef struct {
    matrix_float4x4 transformationMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    vector_float3 cameraPosition;
    vector_float3 lightPosition;
} WaterVertexUniforms;

typedef struct {
    vector_float3 lightColor;
    float moveFactor;
} WaterFragmentUniforms;

// GUIVertexShader.vsh uniforms
typedef struct {
    matrix_float4x4 transformationMatrix;
} GUIVertexUniforms;

#endif /* GLGameEngine_ShaderTypes_h */
