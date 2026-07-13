//
//  SkyboxShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "SkyboxShader.h"
#import "TimeController.h"
#import "MathUtils.h"
#import "MetalContext.h"

NSString *const SKYBOX_VERTEX_FUNCTION_NAME = @"vertex_skybox";
NSString *const SKYBOX_FRAGMENT_FUNCTION_NAME = @"fragment_skybox";

@implementation SkyboxShader {
    SkyboxVertexUniforms _vertexUniforms;
    SkyboxFragmentUniforms _fragmentUniforms;
}

+ (SkyboxShader *)skyboxShaderProgram
{
    return [[SkyboxShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:SKYBOX_VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:SKYBOX_FRAGMENT_FUNCTION_NAME])) {
        self.rotation_speed = 0.f;
    }

    return self;
}

- (MTLVertexDescriptor *)createVertexDescriptor
{
    MTLVertexDescriptor *descriptor = [MTLVertexDescriptor vertexDescriptor];

    descriptor.attributes[0].format = MTLVertexFormatFloat3;
    descriptor.attributes[0].offset = 0;
    descriptor.attributes[0].bufferIndex = BufferIndexPositions;
    descriptor.layouts[BufferIndexPositions].stride = sizeof(float) * 3;

    return descriptor;
}

- (void)uploadUniforms
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    [encoder setVertexBytes:&_vertexUniforms length:sizeof(_vertexUniforms) atIndex:BufferIndexVertexUniforms];
    [encoder setFragmentBytes:&_fragmentUniforms length:sizeof(_fragmentUniforms) atIndex:BufferIndexFragmentUniforms];
}

- (void)loadBlendFactor:(float)blendFactor
{
    _fragmentUniforms.blendFactor = blendFactor;
}

- (void)loadProjectionMatrix:(simd_float4x4)projectionMatrix
{
    _vertexUniforms.projectionMatrix = projectionMatrix;
}

- (void)loadViewMatrix:(simd_float4x4)viewMatrix
{
    // strip the translation (last column) so the skybox stays centered on the camera
    viewMatrix.columns[3] = simd_make_float4(0.f, 0.f, 0.f, viewMatrix.columns[3].w);

    float currentRotation = fmodf(([TimeController sharedController].passedTime * self.rotation_speed), 360);

    viewMatrix = simd_mul(viewMatrix, MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(currentRotation)));
    _vertexUniforms.viewMatrix = viewMatrix;
}

- (void)loadFogColor:(simd_float3)fogColor
{
    _fragmentUniforms.fogColor = fogColor;
}

@end
