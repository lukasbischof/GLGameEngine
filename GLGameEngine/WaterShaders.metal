// vim: set ft=cpp:
//
//  WaterShaders.metal
//  GLGameEngine
//
//  Metal translation of WaterVertexShader.vsh + WaterFragmentShader.fsh.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position [[attribute(0)]];
} WaterVertexIn;

typedef struct {
    float4 position [[position]];
    float4 clipSpace;
    float2 textureCoordinates;
    float3 toCamera;
    float3 fromLight;
} WaterVertexOut;

constant float tiling = 4.0;

constant float waveStrength = 0.025;
constant float shineDamper = 50.0;
constant float reflectivity = 0.6;

constant float nearz = 1.5;
constant float farz = 300.0;

vertex WaterVertexOut vertex_water(WaterVertexIn in [[stage_in]],
                                   constant WaterVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    WaterVertexOut out;

    float4 worldPosition = u.transformationMatrix * float4(in.position, 1.0);
    out.clipSpace = u.projectionMatrix * u.viewMatrix * worldPosition;
    out.textureCoordinates = float2(in.position.x / 2.0 + 0.5, in.position.z / 2.0 + 0.5) * tiling;
    out.toCamera = u.cameraPosition - worldPosition.xyz;
    out.fromLight = worldPosition.xyz - u.lightPosition;
    out.position = out.clipSpace;

    return out;
}

// The projection matrix maps z to [0,1] so that in.position.z and the sampled
// depth texture equal GL window-space depth -- this stays the GL formula.
static float linearizeDepth(float depth)
{
    return 2.0 * nearz * farz / (farz + nearz - (2.0 * depth - 1.0) * (farz - nearz));
}

static float getWaterDepth(float2 uv, float fragDepth,
                           texture2d<float> depthMap, sampler depthSampler)
{
    float depth = depthMap.sample(depthSampler, uv).r;
    float floorDistance = linearizeDepth(depth);

    depth = fragDepth;
    float waterDistance = linearizeDepth(depth);

    return floorDistance - waterDistance;
}

fragment float4 fragment_water(WaterVertexOut in [[stage_in]],
                               texture2d<float> u_reflectionTexture [[texture(TextureIndexReflection)]],
                               texture2d<float> u_refractionTexture [[texture(TextureIndexRefraction)]],
                               texture2d<float> u_dudvMap [[texture(TextureIndexDuDvMap)]],
                               texture2d<float> u_normalMap [[texture(TextureIndexNormalMap)]],
                               texture2d<float> u_depthMap [[texture(TextureIndexDepthMap)]],
                               sampler targetSampler [[sampler(TextureIndexReflection)]],
                               sampler mapSampler [[sampler(TextureIndexDuDvMap)]],
                               sampler depthSampler [[sampler(TextureIndexDepthMap)]],
                               constant WaterFragmentUniforms &u [[buffer(BufferIndexFragmentUniforms)]])
{
    float2 normalizedDeviceSpace = (in.clipSpace.xy / in.clipSpace.w) / 2.0 + 0.5;
    // Metal render targets have their origin at the top left (GL: bottom left),
    // so the V formulas of refraction and reflection are swapped vs. the GLSL.
    float2 refractTexCoords = float2(normalizedDeviceSpace.x, 1.0 - normalizedDeviceSpace.y);
    float2 reflectTexCoords = float2(normalizedDeviceSpace.x, normalizedDeviceSpace.y);

    // depth
    float waterDepth = getWaterDepth(refractTexCoords, in.position.z, u_depthMap, depthSampler);

    // distort
    float2 distortedTexCoords = (u_dudvMap.sample(mapSampler, float2(in.textureCoordinates.x + u.moveFactor, in.textureCoordinates.y)).rg * 0.3);
    distortedTexCoords = in.textureCoordinates + float2(distortedTexCoords.x, distortedTexCoords.y + u.moveFactor);
    float2 totalDistort = (u_dudvMap.sample(mapSampler, distortedTexCoords).rg * 2.0 - 1.0) * waveStrength * clamp(waterDepth / 10.0, 0.0, 1.0);

    refractTexCoords += totalDistort;
    refractTexCoords = clamp(refractTexCoords, 0.001, 0.999);

    reflectTexCoords += totalDistort;
    reflectTexCoords = clamp(reflectTexCoords, 0.001, 0.999);

    // reflection + refraction
    float4 reflectColor = u_reflectionTexture.sample(targetSampler, reflectTexCoords);
    float4 refractColor = u_refractionTexture.sample(targetSampler, refractTexCoords);

    // normals
    float4 normalMapColor = u_normalMap.sample(mapSampler, distortedTexCoords);
    float3 normal = normalize(float3(normalMapColor.r * 2.0 - 1.0, normalMapColor.b * 6.0, normalMapColor.g * 2.0 - 1.0));

    // fresnel
    float3 viewVec = normalize(in.toCamera);
    float refractiveFactor = pow(dot(viewVec, normal), 0.4);
    refractiveFactor = clamp(refractiveFactor, 0.0, 1.0);

    // light
    float3 reflectedLight = reflect(normalize(in.fromLight), normal);
    float specular = pow(max(dot(reflectedLight, viewVec), 0.0), shineDamper);
    float4 specularHighlights = float4(u.lightColor * specular * reflectivity * clamp(waterDepth / 5.0, 0.0, 1.0), 0.0);

    // final
    float4 color = mix(reflectColor, refractColor, refractiveFactor) + float4(0.0, 0.05, 0.1, 1.0) + specularHighlights;
    color.a = clamp(waterDepth / 5.0, 0.0, 1.0);

    return color;
}
