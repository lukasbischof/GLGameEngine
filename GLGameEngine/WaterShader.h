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

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix;
- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)loadViewMatrix:(Camera *)cam;
- (void)loadTextureUnits;
- (void)loadMoveFactor:(GLfloat)moveFactor;
- (void)loadLight:(Light *)light;

@end
