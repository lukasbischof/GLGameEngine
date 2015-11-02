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

+ (SkyboxShader *)skyboxShaderProgram;

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix;
- (void)loadViewMatrix:(GLKMatrix4)viewMatrix;

@end
