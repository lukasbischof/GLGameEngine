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
- (void)loadNormalMatrixWithModelMatrix:(GLKMatrix4)modelMatrix andViewMatrix:(GLKMatrix4)viewMatrix;
- (void)loadLights:(NSArray<Light *> *)lights;
- (void)loadSkyColor:(GLKVector3)skyColor;
- (void)loadFogDensity:(GLfloat)density andGradient:(GLfloat)gradient;
- (void)loadNumberOfRows:(GLint)numberOfRows;
- (void)loadOffset:(GLKVector2)offset;
- (void)loadDamper:(GLfloat)damper andReflectivity:(GLfloat)reflectivity;
- (void)loadClippingPlane:(GLKVector4)clippingPlane;

@end
