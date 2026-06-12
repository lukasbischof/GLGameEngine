//
//  StaticShaders.metal
//  GLGameEngine
//
//  Metal translation of VertexShader.vsh + FragmentShader.fsh.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position  [[attribute(0)]];
    float2 texCoords [[attribute(1)]]; // delivered as half2 by the entity vertex descriptor
    float3 normals   [[attribute(2)]];
} StaticVertexIn;

typedef struct {
    float4 position [[position]];
    float clipDistance [[clip_distance]] [1];
    float3 normal;
    float2 texCoords;
    float3 modelPosition;
    // MSL stage_in members can't be arrays -> the GLSL inout_lightDirection[4] is unrolled
    float3 lightDirection0;
    float3 lightDirection1;
    float3 lightDirection2;
    float3 lightDirection3;
    float visibility;
} StaticVertexOut;

// Fragment-stage view of StaticVertexOut: identical member names (matched by name),
// without the [[clip_distance]] member, which must not appear in a fragment input.
typedef struct {
    float4 position [[position]];
    float3 normal;
    float2 texCoords;
    float3 modelPosition;
    float3 lightDirection0;
    float3 lightDirection1;
    float3 lightDirection2;
    float3 lightDirection3;
    float visibility;
} StaticFragmentIn;

vertex StaticVertexOut vertex_static(StaticVertexIn in [[stage_in]],
                                     constant StaticVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    StaticVertexOut out;

    float4 worldPosition = u.transformationMatrix * float4(in.position, 1.0);
    out.clipDistance[0] = dot(worldPosition, u.clippingPlane);

    float4 modelPosition = u.viewMatrix * worldPosition;
    out.position = u.projectionMatrix * modelPosition;

    out.modelPosition = modelPosition.xyz;
    out.texCoords = (in.texCoords / u.numberOfRows) + u.offset;
    out.normal = normalize(u.normalMatrix * in.normals);

    out.lightDirection0 = (u.viewMatrix * float4(u.lightPosition[0], 1.0)).xyz - out.modelPosition;
    out.lightDirection1 = (u.viewMatrix * float4(u.lightPosition[1], 1.0)).xyz - out.modelPosition;
    out.lightDirection2 = (u.viewMatrix * float4(u.lightPosition[2], 1.0)).xyz - out.modelPosition;
    out.lightDirection3 = (u.viewMatrix * float4(u.lightPosition[3], 1.0)).xyz - out.modelPosition;

    float vertDistance = length(modelPosition.xyz);
    float visibility = exp(-pow(vertDistance * u.density, u.gradient));
    out.visibility = clamp(visibility, 0.0, 1.0);

    return out;
}

static float getAttenuation(constant StaticFragmentUniforms &u, int i, float lightDistance)
{
    return (u.attenuation[i].x) + (u.attenuation[i].y * lightDistance) + (u.attenuation[i].z * lightDistance * lightDistance);
}

fragment float4 fragment_static(StaticFragmentIn in [[stage_in]],
                                texture2d<float> u_textureSampler [[texture(TextureIndexDiffuse)]],
                                sampler textureSampler [[sampler(TextureIndexDiffuse)]],
                                constant StaticFragmentUniforms &u [[buffer(BufferIndexFragmentUniforms)]])
{
    float4 textureColor = u_textureSampler.sample(textureSampler, in.texCoords);

    if (textureColor.a < 0.5)
        discard_fragment();

    float3 eyeVec = normalize(-in.modelPosition);
    float3 totalDiffuse = float3(0.0);
    float3 totalSpecular = float3(0.0);

    float3 lightDirection[4] = { in.lightDirection0, in.lightDirection1, in.lightDirection2, in.lightDirection3 };

    for (int i = 0; i < 4; i++) {
        float lightDistance = length(lightDirection[i]);
        float3 unitLightDirection = normalize(lightDirection[i]);
        float attenuationFactor = getAttenuation(u, i, lightDistance);
        float diffuseWeight = max(dot(in.normal, unitLightDirection), 0.0);

        totalDiffuse += diffuseWeight * u.lightColor[i] / attenuationFactor;

        if (u.reflectivity <= 0.0)
            continue;

        float3 reflectedLight = normalize(reflect(-unitLightDirection, in.normal));
        float specularWeight = pow(max(dot(eyeVec, reflectedLight), 0.0), u.damper) * u.reflectivity;

        totalSpecular += (specularWeight * float3(1.0)) / attenuationFactor;
    }

    // color + lighting
    float4 color = textureColor * float4(max(totalDiffuse, float3(0.2)) + totalSpecular, 1.0);

    // fog
    return mix(float4(u.skyColor, 1.0), color, in.visibility);
}
