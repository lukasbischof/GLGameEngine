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
#import "SIMDBridge.h"

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

- (void)loadTextureUnits
{
    // texture indices are fixed in the shader ([[texture(n)]]), nothing to do
}

- (void)loadBlendFactor:(GLfloat)blendFactor
{
    _fragmentUniforms.blendFactor = blendFactor;
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    _vertexUniforms.projectionMatrix = SIMD_Matrix4(projectionMatrix);
}

- (void)loadViewMatrix:(GLKMatrix4)viewMatrix
{
    viewMatrix.m30 = 0.0;
    viewMatrix.m31 = 0.0;
    viewMatrix.m32 = 0.0;

    GLfloat currentRotation = fmodf(([TimeController sharedController].passedTime * self.rotation_speed), 360);

    viewMatrix = GLKMatrix4Rotate(viewMatrix, MathUtils_DegToRad(currentRotation), 0, 1, 0);
    _vertexUniforms.viewMatrix = SIMD_Matrix4(viewMatrix);
}

- (void)loadFogColor:(GLKVector3)fogColor
{
    _fragmentUniforms.fogColor = SIMD_Vector3(fogColor);
}

@end
