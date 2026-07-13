//
//  ShaderTypes.h
//  GLGameEngine
//
//  Types shared between the Objective-C renderer and the Metal shaders:
//  buffer/texture index conventions and the per-shader uniform structs.
//  (each shader program's uniforms are collapsed into one struct per stage).
//

#ifndef GLGameEngine_ShaderTypes_h
#define GLGameEngine_ShaderTypes_h

#include <simd/simd.h>

#ifndef MAX_LIGHTS
#define MAX_LIGHTS 4
#endif

// Vertex buffer slots. 0-3 hold one vertex attribute each,
// the uniform struct lives in its own slot above them.
typedef enum BufferIndex {
    BufferIndexPositions        = 0,
    BufferIndexTexCoords        = 1,
    BufferIndexNormals          = 2,
    BufferIndexInstanceMatrices = 3, // occupies vertex attributes 3-6 (one vec4 each)
    BufferIndexVertexUniforms   = 4,
    BufferIndexFragmentUniforms = 0  // fragment stage namespace
} BufferIndex;

// Fragment texture slots, grouped per shader family.
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

// vertex_static + vertex_instancing uniforms
typedef struct {
    matrix_float4x4 transformationMatrix; // unused by the instancing variant (per-instance attribute)
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float3x3 normalMatrix;
    float density;                        // fog
    float gradient;                       // fog
    float numberOfRows;                   // texture atlas row count (float for the shader)
    vector_float2 offset;                 // texture atlas
    vector_float3 lightPosition[MAX_LIGHTS];
    vector_float4 clippingPlane;
} StaticVertexUniforms;

// fragment_static uniforms (shared by static + instancing pipelines)
typedef struct {
    vector_float3 lightColor[MAX_LIGHTS];
    vector_float3 attenuation[MAX_LIGHTS];
    vector_float3 skyColor;
    float damper;
    float reflectivity;
} StaticFragmentUniforms;

// vertex_terrain uniforms
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

// fragment_terrain uniforms
typedef struct {
    vector_float3 lightColor[MAX_LIGHTS];
    vector_float3 attenuation[MAX_LIGHTS];
    vector_float3 skyColor;
} TerrainFragmentUniforms;

// skybox uniforms
typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
} SkyboxVertexUniforms;

typedef struct {
    vector_float3 fogColor;
    float blendFactor;
} SkyboxFragmentUniforms;

// water uniforms
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

// GUI uniforms
typedef struct {
    matrix_float4x4 transformationMatrix;
} GUIVertexUniforms;

#endif /* GLGameEngine_ShaderTypes_h */
