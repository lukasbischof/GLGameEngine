//
//  GUIShaders.metal
//  GLGameEngine
//
//  Screen-space textured quads for debug overlays.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

typedef struct {
    float2 position [[attribute(0)]];
} GUIVertexIn;

typedef struct {
    float4 position [[position]];
    float2 textureCoordinates;
} GUIVertexOut;

vertex GUIVertexOut vertex_gui(GUIVertexIn in [[stage_in]],
                               constant GUIVertexUniforms &u [[buffer(BufferIndexVertexUniforms)]])
{
    GUIVertexOut out;

    out.position = u.transformationMatrix * float4(in.position, 0.0, 1.0);
    out.textureCoordinates = float2((in.position.x + 1.0) / 2.0, 1.0 - (in.position.y + 1.0) / 2.0);

    return out;
}

fragment float4 fragment_gui(GUIVertexOut in [[stage_in]],
                             texture2d<float> u_guiTexture [[texture(TextureIndexDiffuse)]],
                             sampler guiSampler [[sampler(TextureIndexDiffuse)]])
{
    return u_guiTexture.sample(guiSampler, in.textureCoordinates);
}
