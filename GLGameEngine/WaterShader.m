//
//  WaterShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterShader.h"

NSString *const WATER_VERTEX_SHADER_FILE_NAME = @"WaterVertexShader";
NSString *const WATER_FRAGMENT_SHADER_FILE_NAME = @"WaterFragmentShader";

@implementation WaterShader {
    GLuint uniform_projection_matrix_location,
           uniform_view_matrix_location,
           uniform_transformation_matrix_location,
           uniform_reflection_texture_location,
           uniform_refraction_texture_location,
           uniform_dudv_map_location,
           uniform_normal_map_location,
           uniform_depth_map_location,
           uniform_move_factor_location,
           uniform_camera_position_location,
           uniform_light_position_location,
           uniform_light_color_location;
}

#pragma mark - init
+ (WaterShader *)waterShaderProgram
{
    return [[WaterShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:WATER_VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:WATER_FRAGMENT_SHADER_FILE_NAME])) {
        
    }
    
    return self;
}

#pragma mark - location stuff
- (void)bindAttributes
{
    [self bindAttribute:0 toVariableName:"in_position"];
}

- (void)getAllUniformLocations
{
    uniform_projection_matrix_location = [self getUniformLocation:"u_projectionMatrix"];
    uniform_view_matrix_location = [self getUniformLocation:"u_viewMatrix"];
    uniform_transformation_matrix_location = [self getUniformLocation:"u_transformationMatrix"];
    uniform_reflection_texture_location = [self getUniformLocation:"u_reflectionTexture"];
    uniform_refraction_texture_location = [self getUniformLocation:"u_refractionTexture"];
    uniform_dudv_map_location = [self getUniformLocation:"u_dudvMap"];
    uniform_move_factor_location = [self getUniformLocation:"u_moveFactor"];
    uniform_camera_position_location = [self getUniformLocation:"u_cameraPosition"];
    uniform_normal_map_location = [self getUniformLocation:"u_normalMap"];
    uniform_depth_map_location = [self getUniformLocation:"u_depthMap"];
    uniform_light_position_location = [self getUniformLocation:"u_lightPosition"];
    uniform_light_color_location = [self getUniformLocation:"u_lightColor"];
}

- (void)loadLight:(Light *)light
{
    [self loadFloatVector3:light.color toLocation:uniform_light_color_location];
    [self loadFloatVector3:light.position toLocation:uniform_light_position_location];
}

- (void)loadMoveFactor:(GLfloat)moveFactor
{
    [self loadFloat:moveFactor toLocation:uniform_move_factor_location];
}

- (void)loadTextureUnits
{
    [self loadInt:0 toLocation:uniform_reflection_texture_location];
    [self loadInt:1 toLocation:uniform_refraction_texture_location];
    [self loadInt:2 toLocation:uniform_dudv_map_location];
    [self loadInt:3 toLocation:uniform_normal_map_location];
    [self loadInt:4 toLocation:uniform_depth_map_location];
}

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix
{
    [self loadMatrix4x4:transformationMatrix toLocation:uniform_transformation_matrix_location];
}

- (void)loadViewMatrix:(Camera *)cam
{
    [self loadMatrix4x4:cam.viewMatrix toLocation:uniform_view_matrix_location];
    [self loadFloatVector3:cam.position toLocation:uniform_camera_position_location];
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    [self loadMatrix4x4:projectionMatrix toLocation:uniform_projection_matrix_location];
}

@end
