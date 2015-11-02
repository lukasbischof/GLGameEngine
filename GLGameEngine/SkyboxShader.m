//
//  SkyboxShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "SkyboxShader.h"
#import "TimeController.h"
#import "MathUtils.h"

NSString *const SKYBOX_VERTEX_SHADER_FILE_NAME = @"SkyboxVertexShader";
NSString *const SKYBOX_FRAGMENT_SHADER_FILE_NAME = @"SkyboxFragmentShader";

@implementation SkyboxShader {
    GLuint uniform_projection_matrix_location,
           uniform_view_matrix_location,
           uniform_fog_color_location,
           uniform_blend_factor_location,
           uniform_cube_sampler1_location,
           uniform_cube_sampler2_location;
}

+ (SkyboxShader *)skyboxShaderProgram
{
    return [[SkyboxShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:SKYBOX_VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:SKYBOX_FRAGMENT_SHADER_FILE_NAME])) {
        self.rotation_speed = 0.f;
    }
    
    return self;
}

- (void)bindAttributes
{
    [self bindAttribute:0 toVariableName:"in_position"];
}

- (void)getAllUniformLocations
{
    uniform_projection_matrix_location = [self getUniformLocation:"u_projectionMatrix"];
    uniform_view_matrix_location = [self getUniformLocation:"u_viewMatrix"];
    uniform_fog_color_location = [self getUniformLocation:"u_fogColor"];
    uniform_blend_factor_location = [self getUniformLocation:"u_blendFactor"];
    uniform_cube_sampler1_location = [self getUniformLocation:"u_cubeSampler1"];
    uniform_cube_sampler2_location = [self getUniformLocation:"u_cubeSampler2"];
}

- (void)loadTextureUnits
{
    [self loadInt:0 toLocation:uniform_cube_sampler1_location];
    [self loadInt:1 toLocation:uniform_cube_sampler2_location];
}

- (void)loadBlendFactor:(GLfloat)blendFactor
{
    [self loadFloat:blendFactor toLocation:uniform_blend_factor_location];
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
    
    GLfloat currentRotation = fmodf(([TimeController sharedController].passedTime * self.rotation_speed), 360);
    
    viewMatrix = GLKMatrix4Rotate(viewMatrix, MathUtils_DegToRad(currentRotation), 0, 1, 0);
    [self loadMatrix4x4:viewMatrix toLocation:uniform_view_matrix_location];
}

- (void)loadFogColor:(GLKVector3)fogColor
{
    [self loadFloatVector3:fogColor toLocation:uniform_fog_color_location];
}

@end
