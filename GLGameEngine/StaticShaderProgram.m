//
//  StaticShaderProgram.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "StaticShaderProgram.h"
#import "MathUtils.h"
#import "MetalContext.h"

NSString *const VERTEX_FUNCTION_NAME = @"vertex_static";
NSString *const FRAGMENT_FUNCTION_NAME = @"fragment_static";

@implementation StaticShaderProgram {
    StaticVertexUniforms _vertexUniforms;
    StaticFragmentUniforms _fragmentUniforms;
}

+ (StaticShaderProgram *)staticShaderProgram
{
    return [[StaticShaderProgram alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:FRAGMENT_FUNCTION_NAME])) {

    }

    return self;
}

- (MTLVertexDescriptor *)createVertexDescriptor
{
    MTLVertexDescriptor *descriptor = [MTLVertexDescriptor vertexDescriptor];

    // GL attribute 0: in_position (vec3)
    descriptor.attributes[0].format = MTLVertexFormatFloat3;
    descriptor.attributes[0].offset = 0;
    descriptor.attributes[0].bufferIndex = BufferIndexPositions;
    descriptor.layouts[BufferIndexPositions].stride = sizeof(float) * 3;

    // GL attribute 1: in_texCoords (vec2, delivered as half2 by Model I/O -- OBJLoader2)
    descriptor.attributes[1].format = MTLVertexFormatHalf2;
    descriptor.attributes[1].offset = 0;
    descriptor.attributes[1].bufferIndex = BufferIndexTexCoords;
    descriptor.layouts[BufferIndexTexCoords].stride = sizeof(uint16_t) * 2;

    // GL attribute 2: in_normals (vec3)
    descriptor.attributes[2].format = MTLVertexFormatFloat3;
    descriptor.attributes[2].offset = 0;
    descriptor.attributes[2].bufferIndex = BufferIndexNormals;
    descriptor.layouts[BufferIndexNormals].stride = sizeof(float) * 3;

    return descriptor;
}

- (void)uploadUniforms
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    [encoder setVertexBytes:&_vertexUniforms length:sizeof(_vertexUniforms) atIndex:BufferIndexVertexUniforms];
    [encoder setFragmentBytes:&_fragmentUniforms length:sizeof(_fragmentUniforms) atIndex:BufferIndexFragmentUniforms];
}

- (void)loadDamper:(float)damper andReflectivity:(float)reflectivity
{
    _fragmentUniforms.damper = damper;
    _fragmentUniforms.reflectivity = reflectivity;
}

- (void)loadOffset:(simd_float2)offset
{
    _vertexUniforms.offset = offset;
}

- (void)loadNumberOfRows:(int32_t)numberOfRows
{
    _vertexUniforms.numberOfRows = (float)numberOfRows;
}

- (void)loadFogDensity:(float)density andGradient:(float)gradient
{
    _vertexUniforms.density = density;
    _vertexUniforms.gradient = gradient;
}

- (void)loadSkyColor:(simd_float3)skyColor
{
    _fragmentUniforms.skyColor = skyColor;
}

- (void)loadLights:(NSArray<Light *> *)lights
{
    for (uint32_t i = 0; i < MAX_LIGHTS; i++) {
        if (i < lights.count) {
            _vertexUniforms.lightPosition[i] = lights[i].position;
            _fragmentUniforms.lightColor[i] = lights[i].color;
            _fragmentUniforms.attenuation[i] = lights[i].attenuation;
        } else {
            _vertexUniforms.lightPosition[i] = simd_make_float3(0, 0, 0);
            _fragmentUniforms.lightColor[i] = simd_make_float3(0, 0, 0);
            _fragmentUniforms.attenuation[i] = simd_make_float3(1, 0, 0);
        }
    }
}

- (void)loadTransformationMatrix:(simd_float4x4)transformationMatrix
{
    _vertexUniforms.transformationMatrix = transformationMatrix;
}

- (void)loadProjectionMatrix:(simd_float4x4)projectionMatrix
{
    _vertexUniforms.projectionMatrix = projectionMatrix;
}

- (void)loadViewMatrix:(simd_float4x4)viewMatrix
{
    _vertexUniforms.viewMatrix = viewMatrix;
}

- (void)loadNormalMatrixWithModelMatrix:(simd_float4x4)modelMatrix andViewMatrix:(simd_float4x4)viewMatrix
{
    _vertexUniforms.normalMatrix = MathUtils_CreateNormalMatrix(modelMatrix, viewMatrix);
}

- (void)loadClippingPlane:(simd_float4)clippingPlane
{
    _vertexUniforms.clippingPlane = clippingPlane;
}

@end
