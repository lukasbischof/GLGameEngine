//
//  TerrainShader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"
#import "Light.h"

@interface TerrainShader : ShaderProgram

+ (TerrainShader *)terrainShaderProgram;

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix;
- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)loadViewMatrix:(GLKMatrix4)viewMatrix;
- (void)loadNormalMatrixWithModelMatrix:(GLKMatrix4)modelMatrix andViewMatrix:(GLKMatrix4)viewMatrix;
- (void)loadLights:(NSArray<Light *> *)lights;
- (void)loadSkyColor:(GLKVector3)skyColor;
- (void)loadFogDensity:(GLfloat)density andGradient:(GLfloat)gradient;
- (void)loadTextureUnits;
- (void)loadClippingPlane:(GLKVector4)clippingPlane;

@end
