//
//  GUIShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUIShader.h"
#import "MetalContext.h"

NSString *const GUI_VERTEX_FUNCTION_NAME = @"vertex_gui";
NSString *const GUI_FRAGMENT_FUNCTION_NAME = @"fragment_gui";

@implementation GUIShader {
    GUIVertexUniforms _vertexUniforms;
}

+ (GUIShader *)GUIShaderProgram
{
    return [[GUIShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:GUI_VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:GUI_FRAGMENT_FUNCTION_NAME])) {

    }

    return self;
}

- (MTLVertexDescriptor *)createVertexDescriptor
{
    MTLVertexDescriptor *descriptor = [MTLVertexDescriptor vertexDescriptor];

    descriptor.attributes[0].format = MTLVertexFormatFloat2;
    descriptor.attributes[0].offset = 0;
    descriptor.attributes[0].bufferIndex = BufferIndexPositions;
    descriptor.layouts[BufferIndexPositions].stride = sizeof(float) * 2;

    return descriptor;
}

- (void)configurePipelineDescriptor:(MTLRenderPipelineDescriptor *)descriptor
{
    // alpha blending: srcAlpha / oneMinusSrcAlpha
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
}

- (void)loadTransformationMatrix:(simd_float4x4)transformationMatrix
{
    _vertexUniforms.transformationMatrix = transformationMatrix;
}

@end
