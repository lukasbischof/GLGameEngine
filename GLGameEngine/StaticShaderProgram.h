//
//  StaticShaderProgram.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"
#import "Light.h"

@interface StaticShaderProgram : ShaderProgram

+ (StaticShaderProgram *)staticShaderProgram;

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix;
- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)loadViewMatrix:(GLKMatrix4)viewMatrix;
- (void)loadLight:(Light *)light;

@end
