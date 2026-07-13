//
//  InstancingShaderProgram.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "InstancingShaderProgram.h"
#import "MathUtils.h"
#import "MetalContext.h"

NSString *const INSTANCING_VERTEX_FUNCTION_NAME = @"vertex_instancing";
NSString *const INSTANCING_FRAGMENT_FUNCTION_NAME = @"fragment_static";

@implementation InstancingShaderProgram {
    // The per-instance transformation matrix is a vertex attribute; everything
    // else matches the static shader, so the same uniform structs are used.
    StaticVertexUniforms _vertexUniforms;
    StaticFragmentUniforms _fragmentUniforms;
}

+ (InstancingShaderProgram *)instancingShaderProgram
{
    return [[InstancingShaderProgram alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:INSTANCING_VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:INSTANCING_FRAGMENT_FUNCTION_NAME])) {

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

    descriptor.attributes[1].format = MTLVertexFormatHalf2;
    descriptor.attributes[1].offset = 0;
    descriptor.attributes[1].bufferIndex = BufferIndexTexCoords;
    descriptor.layouts[BufferIndexTexCoords].stride = sizeof(uint16_t) * 2;

    descriptor.attributes[2].format = MTLVertexFormatFloat3;
    descriptor.attributes[2].offset = 0;
    descriptor.attributes[2].bufferIndex = BufferIndexNormals;
    descriptor.layouts[BufferIndexNormals].stride = sizeof(float) * 3;

    // GL attributes 3-6: in_transformationMatrix (mat4, one vec4 per location)
    // with glVertexAttribDivisor(i, 1) -> per-instance step function
    for (NSUInteger i = 0; i < 4; i++) {
        descriptor.attributes[3 + i].format = MTLVertexFormatFloat4;
        descriptor.attributes[3 + i].offset = sizeof(float) * 4 * i;
        descriptor.attributes[3 + i].bufferIndex = BufferIndexInstanceMatrices;
    }
    descriptor.layouts[BufferIndexInstanceMatrices].stride = sizeof(float) * 16;
    descriptor.layouts[BufferIndexInstanceMatrices].stepFunction = MTLVertexStepFunctionPerInstance;
    descriptor.layouts[BufferIndexInstanceMatrices].stepRate = 1;

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
