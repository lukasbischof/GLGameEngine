//
//  SkyboxShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "SkyboxShader.h"

NSString *const SKYBOX_VERTEX_SHADER_FILE_NAME = @"SkyboxVertexShader";
NSString *const SKYBOX_FRAGMENT_SHADER_FILE_NAME = @"SkyboxFragmentShader";

#define IN_POSITION_NAME "in_position"

#define UNIFORM_PROJECTION_MATRIX_NAME "u_projectionMatrix"
#define UNIFORM_VIEW_MATRIX_NAME "u_viewMatrix"

@implementation SkyboxShader {
    GLuint uniform_projection_matrix_location,
           uniform_view_matrix_location;
}

+ (SkyboxShader *)skyboxShaderProgram
{
    return [[SkyboxShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:SKYBOX_VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:SKYBOX_FRAGMENT_SHADER_FILE_NAME])) {
        
    }
    
    return self;
}

- (void)bindAttributes
{
    [self bindAttribute:0 toVariableName:IN_POSITION_NAME];
}

- (void)getAllUniformLocations
{
    uniform_projection_matrix_location = [self getUniformLocation:UNIFORM_PROJECTION_MATRIX_NAME];
    uniform_view_matrix_location = [self getUniformLocation:UNIFORM_VIEW_MATRIX_NAME];
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    [self loadMatrix4x4:projectionMatrix toLocation:uniform_projection_matrix_location];
}

- (void)loadViewMatrix:(GLKMatrix4)viewMatrix
{
    viewMatrix.m30 = 0.0;
    viewMatrix.m31 = 0.0;
    viewMatrix.m32 = 0.0;
    
    [self loadMatrix4x4:viewMatrix toLocation:uniform_view_matrix_location];
}

@end
