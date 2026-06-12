//
//  InstancingShaders.metal
//  GLGameEngine
//
//  Metal translation of InstancingVertexShader.vsh. The fragment stage reuses
//  fragment_static from StaticShaders.metal (the GL program linked
//  InstancingVertexShader.vsh with FragmentShader.fsh).
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float3 position  [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
    float3 normals   [[attribute(2)]];
    // in_transformationMatrix: a mat4 attribute occupies 4 consecutive locations
    float4 transformationCol0 [[attribute(3)]];
    float4 transformationCol1 [[attribute(4)]];
    float4 transformationCol2 [[attribute(5)]];
    float4 transformationCol3 [[attribute(6)]];
} InstancingVertexIn;

// Must match StaticShaders.metal's fragment input by member name.
typedef struct {
    float4 position [[position]];
    float clipDistance [[clip_distance]] [1];
    float3 normal;
    float2 texCoords;
    float3 modelPosition;
    float3 lightDirection0;
    float3 lightDirection1;
    float3 lightDirection2;
    float3 lightDirection3;
    float visibility;
} InstancingVertexOut;

// MSL has no inverse() builtin -- adjugate-based 3x3 inverse.
static float3x3 inverse3x3(float3x3 m)
{
    float3 c0 = m[0], c1 = m[1], c2 = m[2];

    float3 r0 = cross(c1, c2);
    float3 r1 = cross(c2, c0);
    float3 r2 = cross(c0, c1);

    float det = dot(c0, r0);

    return float3x3(float3(r0.x, r1.x, r2.x),
                    float3(r0.y, r1.y, r2.y),
                    float3(r0.z, r1.z, r2.z)) * (1.0 / det);
}

vertex InstancingVertexOut vertex_instancing(InstancingVertexIn in [[stage_in]],
                                             constant StaticVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    InstancingVertexOut out;

    float4x4 transformationMatrix = float4x4(in.transformationCol0,
                                             in.transformationCol1,
                                             in.transformationCol2,
                                             in.transformationCol3);

    float4 worldPosition = transformationMatrix * float4(in.position, 1.0);
    out.clipDistance[0] = dot(worldPosition, u.clippingPlane);

    float4 modelPosition = u.viewMatrix * worldPosition;
    out.position = u.projectionMatrix * modelPosition;

    out.modelPosition = modelPosition.xyz;
    out.texCoords = (in.texCoords / u.numberOfRows) + u.offset;

    float4x4 mv = u.viewMatrix * transformationMatrix;
    float3x3 normalMat = transpose(inverse3x3(float3x3(mv[0].xyz, mv[1].xyz, mv[2].xyz)));

    out.normal = normalize(normalMat * in.normals);

    out.lightDirection0 = (u.viewMatrix * float4(u.lightPosition[0], 1.0)).xyz - out.modelPosition;
    out.lightDirection1 = (u.viewMatrix * float4(u.lightPosition[1], 1.0)).xyz - out.modelPosition;
    out.lightDirection2 = (u.viewMatrix * float4(u.lightPosition[2], 1.0)).xyz - out.modelPosition;
    out.lightDirection3 = (u.viewMatrix * float4(u.lightPosition[3], 1.0)).xyz - out.modelPosition;

    float vertDistance = length(modelPosition.xyz);
    float visibility = exp(-pow(vertDistance * u.density, u.gradient));
    out.visibility = clamp(visibility, 0.0, 1.0);

    return out;
}
