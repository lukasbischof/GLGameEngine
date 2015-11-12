//
//  GUIShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUIShader.h"

NSString *const GUI_VERTEX_SHADER_FILE_NAME = @"GUIVertexShader";
NSString *const GUI_FRAGMENT_SHADER_FILE_NAME = @"GUIFragmentShader";

@implementation GUIShader {
    GLuint uniform_transformation_matrix_location;
}

+ (GUIShader *)GUIShaderProgram
{
    return [[GUIShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:GUI_VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:GUI_FRAGMENT_SHADER_FILE_NAME])) {
        
    }
    
    return self;
}

- (void)getAllUniformLocations
{
    uniform_transformation_matrix_location = [self getUniformLocation:"u_transformationMatrix"];
}

- (void)bindAttributes
{
    [self bindAttribute:0 toVariableName:"in_position"];
}

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix
{
    [self loadMatrix4x4:transformationMatrix toLocation:uniform_transformation_matrix_location];
}

@end
