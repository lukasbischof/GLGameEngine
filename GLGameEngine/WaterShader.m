//
//  WaterShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterShader.h"
#import "MetalContext.h"
#import "SIMDBridge.h"

NSString *const WATER_VERTEX_FUNCTION_NAME = @"vertex_water";
NSString *const WATER_FRAGMENT_FUNCTION_NAME = @"fragment_water";

@implementation WaterShader {
    WaterVertexUniforms _vertexUniforms;
    WaterFragmentUniforms _fragmentUniforms;
}

#pragma mark - init
+ (WaterShader *)waterShaderProgram
{
    return [[WaterShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:WATER_VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:WATER_FRAGMENT_FUNCTION_NAME])) {

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

- (void)configurePipelineDescriptor:(MTLRenderPipelineDescriptor *)descriptor
{
    // glEnable(GL_BLEND) + glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
    MTLRenderPipelineColorAttachmentDescriptor *colorAttachment = descriptor.colorAttachments[0];
    colorAttachment.blendingEnabled = YES;
    colorAttachment.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    colorAttachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorAttachment.sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    colorAttachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
}

- (void)uploadUniforms
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    [encoder setVertexBytes:&_vertexUniforms length:sizeof(_vertexUniforms) atIndex:BufferIndexVertexUniforms];
    [encoder setFragmentBytes:&_fragmentUniforms length:sizeof(_fragmentUniforms) atIndex:BufferIndexFragmentUniforms];
}

- (void)loadLight:(Light *)light
{
    _fragmentUniforms.lightColor = SIMD_Vector3(light.color);
    _vertexUniforms.lightPosition = SIMD_Vector3(light.position);
}

- (void)loadMoveFactor:(GLfloat)moveFactor
{
    _fragmentUniforms.moveFactor = moveFactor;
}

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix
{
    _vertexUniforms.transformationMatrix = SIMD_Matrix4(transformationMatrix);
}

- (void)loadViewMatrix:(Camera *)cam
{
    _vertexUniforms.viewMatrix = SIMD_Matrix4(cam.viewMatrix);
    _vertexUniforms.cameraPosition = SIMD_Vector3(cam.position);
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    _vertexUniforms.projectionMatrix = SIMD_Matrix4(projectionMatrix);
}

@end
