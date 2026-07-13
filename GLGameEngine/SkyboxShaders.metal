//
//  SkyboxShaders.metal
//  GLGameEngine
//
//  Day/night cube-map skybox with horizon fog blending.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position [[attribute(0)]];
} SkyboxVertexIn;

typedef struct {
    float4 position [[position]];
    float3 texCoords;
} SkyboxVertexOut;

constant float c_lowerLimit = 0.0;
constant float c_upperLimit = 30.0;

vertex SkyboxVertexOut vertex_skybox(SkyboxVertexIn in [[stage_in]],
                                     constant SkyboxVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    SkyboxVertexOut out;

    out.position = u.projectionMatrix * u.viewMatrix * float4(in.position, 1.0);
    out.texCoords = in.position;

    return out;
}

fragment float4 fragment_skybox(SkyboxVertexOut in [[stage_in]],
                                texturecube<float> u_cubeSampler1 [[texture(TextureIndexCubeDay)]],
                                texturecube<float> u_cubeSampler2 [[texture(TextureIndexCubeNight)]],
                                sampler cubeSampler [[sampler(0)]],
                                constant SkyboxFragmentUniforms &u [[buffer(BufferIndexFragmentUniforms)]])
{
    float4 texture1 = u_cubeSampler1.sample(cubeSampler, normalize(in.texCoords));
    float4 texture2 = u_cubeSampler2.sample(cubeSampler, normalize(in.texCoords));
    float4 finalColor = mix(texture1, texture2, u.blendFactor);

    float factor = (in.texCoords.y - c_lowerLimit) / (c_upperLimit - c_lowerLimit);
    factor = clamp(factor, 0.0, 1.0);

    return mix(float4(u.fogColor, 1.0), finalColor, factor);
}
