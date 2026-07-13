//
//  SkyboxShader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShaderProgram.h"

@interface SkyboxShader : ShaderProgram

@property (assign, nonatomic) float rotation_speed; // Die Rotationsgeschwindigkeit der Skybox um die Y-Achse. In deg/s

+ (SkyboxShader *)skyboxShaderProgram;

- (void)loadProjectionMatrix:(simd_float4x4)projectionMatrix;
- (void)loadViewMatrix:(simd_float4x4)viewMatrix;
- (void)loadFogColor:(simd_float3)fogColor;
- (void)loadBlendFactor:(float)blendFactor;

@end
