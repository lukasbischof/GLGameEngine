//
//  InstancingShaderProgram.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"
#import "Light.h"

@interface InstancingShaderProgram : ShaderProgram

+ (InstancingShaderProgram *)instancingShaderProgram;

- (void)loadProjectionMatrix:(simd_float4x4)projectionMatrix;
- (void)loadViewMatrix:(simd_float4x4)viewMatrix;
- (void)loadNormalMatrixWithModelMatrix:(simd_float4x4)modelMatrix andViewMatrix:(simd_float4x4)viewMatrix;
- (void)loadLights:(NSArray<Light *> *)lights;
- (void)loadSkyColor:(simd_float3)skyColor;
- (void)loadFogDensity:(float)density andGradient:(float)gradient;
- (void)loadNumberOfRows:(int32_t)numberOfRows;
- (void)loadOffset:(simd_float2)offset;
- (void)loadDamper:(float)damper andReflectivity:(float)reflectivity;
- (void)loadClippingPlane:(simd_float4)clippingPlane;

@end
