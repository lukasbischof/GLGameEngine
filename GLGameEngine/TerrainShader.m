//
//  TerrainShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainShader.h"
#import "MathUtils.h"
#import "MetalContext.h"
#import "SIMDBridge.h"

NSString *const TERRAIN_VERTEX_FUNCTION_NAME = @"vertex_terrain";
NSString *const TERRAIN_FRAGMENT_FUNCTION_NAME = @"fragment_terrain";

@implementation TerrainShader {
    TerrainVertexUniforms _vertexUniforms;
    TerrainFragmentUniforms _fragmentUniforms;
}

+ (TerrainShader *)terrainShaderProgram
{
    return [[TerrainShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexFunctionName:TERRAIN_VERTEX_FUNCTION_NAME
                          andFragmentFunctionName:TERRAIN_FRAGMENT_FUNCTION_NAME])) {

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

    // terrain texture coordinates are packed floats (Loader storeData), not half2
    descriptor.attributes[1].format = MTLVertexFormatFloat2;
    descriptor.attributes[1].offset = 0;
    descriptor.attributes[1].bufferIndex = BufferIndexTexCoords;
    descriptor.layouts[BufferIndexTexCoords].stride = sizeof(float) * 2;

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

- (void)loadClippingPlane:(GLKVector4)clippingPlane
{
    _vertexUniforms.clippingPlane = SIMD_Vector4(clippingPlane);
}

- (void)loadTextureUnits
{
    // texture indices are fixed in the shader ([[texture(n)]]), nothing to do
}

- (void)loadFogDensity:(GLfloat)density andGradient:(GLfloat)gradient
{
    _vertexUniforms.density = density;
    _vertexUniforms.gradient = gradient;
}

- (void)loadSkyColor:(GLKVector3)skyColor
{
    _fragmentUniforms.skyColor = SIMD_Vector3(skyColor);
}

- (void)loadLights:(NSArray<Light *> *)lights
{
    for (GLuint i = 0; i < MAX_LIGHTS; i++) {
        if (i < lights.count) {
            _vertexUniforms.lightPosition[i] = SIMD_Vector3(lights[i].position);
            _fragmentUniforms.lightColor[i] = SIMD_Vector3(lights[i].color);
            _fragmentUniforms.attenuation[i] = SIMD_Vector3(lights[i].attenuation);
        } else {
            _vertexUniforms.lightPosition[i] = simd_make_float3(0, 0, 0);
            _fragmentUniforms.lightColor[i] = simd_make_float3(0, 0, 0);
            _fragmentUniforms.attenuation[i] = simd_make_float3(1, 0, 0);
        }
    }
}

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix
{
    _vertexUniforms.transformationMatrix = SIMD_Matrix4(transformationMatrix);
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    _vertexUniforms.projectionMatrix = SIMD_Matrix4(projectionMatrix);
}

- (void)loadViewMatrix:(GLKMatrix4)viewMatrix
{
    _vertexUniforms.viewMatrix = SIMD_Matrix4(viewMatrix);
}

- (void)loadNormalMatrixWithModelMatrix:(GLKMatrix4)modelMatrix andViewMatrix:(GLKMatrix4)viewMatrix
{
    _vertexUniforms.normalMatrix = SIMD_Matrix3(MathUtils_CreateNormalMatrix(modelMatrix, viewMatrix));
}

@end
