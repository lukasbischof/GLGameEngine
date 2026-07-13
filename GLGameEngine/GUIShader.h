//
//  GUIShader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"

@interface GUIShader : ShaderProgram

+ (GUIShader *)GUIShaderProgram;

- (void)loadTransformationMatrix:(simd_float4x4)transformationMatrix;

@end
