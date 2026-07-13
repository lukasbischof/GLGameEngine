//
//  WaterShader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"
#import "Light.h"
#import "Camera.h"

@interface WaterShader : ShaderProgram

+ (WaterShader *)waterShaderProgram;

- (void)loadTransformationMatrix:(simd_float4x4)transformationMatrix;
- (void)loadProjectionMatrix:(simd_float4x4)projectionMatrix;
- (void)loadViewMatrix:(Camera *)cam;
- (void)loadMoveFactor:(float)moveFactor;
- (void)loadLight:(Light *)light;

@end
