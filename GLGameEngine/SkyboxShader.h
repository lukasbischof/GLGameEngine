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

@property (assign, nonatomic) GLfloat rotation_speed; // Die Rotationsgeschwindigkeit der Skybox um die Y-Achse. In deg/s

+ (SkyboxShader *)skyboxShaderProgram;

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)loadViewMatrix:(GLKMatrix4)viewMatrix;
- (void)loadFogColor:(GLKVector3)fogColor;
- (void)loadBlendFactor:(GLfloat)blendFactor;
- (void)loadTextureUnits;

@end
