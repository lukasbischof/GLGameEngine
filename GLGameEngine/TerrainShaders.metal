//
//  TerrainShaders.metal
//  GLGameEngine
//
//  Metal translation of TerrainVertexShader.vsh + TerrainFragmentShader.fsh.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position  [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
    float3 normals   [[attribute(2)]];
} TerrainVertexIn;

typedef struct {
    float4 position [[position]];
    float clipDistance [[clip_distance]] [1];
    float3 normal;
    float2 texCoords;
    float2 tiledTexCoords;
    float3 modelPosition;
    float3 lightDirection0;
    float3 lightDirection1;
    float3 lightDirection2;
    float3 lightDirection3;
    float visibility;
} TerrainVertexOut;

typedef struct {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
    float2 tiledTexCoords;
    float3 modelPosition;
    float3 lightDirection0;
    float3 lightDirection1;
    float3 lightDirection2;
    float3 lightDirection3;
    float visibility;
} TerrainFragmentIn;

vertex TerrainVertexOut vertex_terrain(TerrainVertexIn in [[stage_in]],
                                       constant TerrainVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    TerrainVertexOut out;

    float4 worldPosition = u.transformationMatrix * float4(in.position.xyz, 1.0);
    out.clipDistance[0] = dot(worldPosition, u.clippingPlane);

    float4 modelPosition = u.viewMatrix * worldPosition;
    out.position = u.projectionMatrix * modelPosition;

    out.modelPosition = modelPosition.xyz;
    out.texCoords = in.texCoords;
    out.tiledTexCoords = in.texCoords * 46.0;
    out.normal = u.normalMatrix * in.normals;

    out.lightDirection0 = (u.viewMatrix * float4(u.lightPosition[0], 1.0)).xyz - out.modelPosition;
    out.lightDirection1 = (u.viewMatrix * float4(u.lightPosition[1], 1.0)).xyz - out.modelPosition;
    out.lightDirection2 = (u.viewMatrix * float4(u.lightPosition[2], 1.0)).xyz - out.modelPosition;
    out.lightDirection3 = (u.viewMatrix * float4(u.lightPosition[3], 1.0)).xyz - out.modelPosition;

    float vertDistance = length(modelPosition.xyz);
    float visibility = exp(-pow(vertDistance * u.density, u.gradient));
    out.visibility = clamp(visibility, 0.0, 1.0);

    return out;
}

static float getAttenuation(constant TerrainFragmentUniforms &u, int i, float lightDistance)
{
    return (u.attenuation[i].x) + (u.attenuation[i].y * lightDistance) + (u.attenuation[i].z * lightDistance * lightDistance);
}

fragment float4 fragment_terrain(TerrainFragmentIn in [[stage_in]],
                                 texture2d<float> u_backgroundSampler [[texture(TextureIndexBackground)]],
                                 texture2d<float> u_rSampler [[texture(TextureIndexR)]],
                                 texture2d<float> u_gSampler [[texture(TextureIndexG)]],
                                 texture2d<float> u_bSampler [[texture(TextureIndexB)]],
                                 texture2d<float> u_blendMapSampler [[texture(TextureIndexBlendMap)]],
                                 sampler terrainSampler [[sampler(0)]],
                                 constant TerrainFragmentUniforms &u [[buffer(BufferIndexFragmentUniforms)]])
{
    float4 blendMapColor = u_blendMapSampler.sample(terrainSampler, in.texCoords);

    float backTextureAmount = 1.0 - (blendMapColor.r + /*blendMapColor.g +*/ blendMapColor.b);
    float4 backgroundTextureColor = u_backgroundSampler.sample(terrainSampler, in.tiledTexCoords) * backTextureAmount;
    float4 rTextureColor = u_rSampler.sample(terrainSampler, in.tiledTexCoords) * blendMapColor.r;
//    float4 gTextureColor = u_gSampler.sample(terrainSampler, in.tiledTexCoords) * blendMapColor.g;
    float4 bTextureColor = u_bSampler.sample(terrainSampler, in.tiledTexCoords) * blendMapColor.b;

    float4 finalColor = backgroundTextureColor + rTextureColor /*+ gTextureColor */+ bTextureColor;

    float3 totalDiffuse = float3(0.0);

    float3 lightDirection[4] = { in.lightDirection0, in.lightDirection1, in.lightDirection2, in.lightDirection3 };

    for (int i = 0; i < 4; i++) {
        float lightDistance = length(lightDirection[i]);
        float3 unitLightDirection = normalize(lightDirection[i]);
        float attenuationFactor = getAttenuation(u, i, lightDistance);

        float diffuseWeight = max(dot(normalize(in.normal), unitLightDirection), 0.0);

        totalDiffuse += diffuseWeight * u.lightColor[i] / attenuationFactor;
    }

    // color + lighting
    float4 color = finalColor * float4(max(totalDiffuse, float3(0.2)), 1.0);

    // fog
    return mix(float4(u.skyColor, 1.0), color, in.visibility);
}
