//
//  StaticShaderProgram.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "StaticShaderProgram.h"
#import "MathUtils.h"

NSString *const VERTEX_SHADER_FILE_NAME = @"VertexShader";
NSString *const FRAGMENT_SHADER_FILE_NAME = @"FragmentShader";

#define IN_POSITION_NAME "in_position"
#define IN_TEX_COORDS_NAME "in_texCoords"
#define IN_NORMALS_NAME "in_normals"

#define UNIFORM_IN_NORMAL_NAME "in_normal"
#define UNIFORM_TRANSFORMATION_MATRIX_NAME "u_transformationMatrix"
#define UNIFORM_PROJECTION_MATRIX_NAME "u_projectionMatrix"
#define UNIFORM_NORMAL_MATRIX_NAME "u_normalMatrix"
#define UNIFORM_VIEW_MATRIX_NAME "u_viewMatrix"
#define UNIFORM_LIGHT_COLOR_NAME "u_lightColor"
#define UNIFORM_LIGHT_POSITION_NAME "u_lightPosition"
#define UNIFORM_SKY_COLOR_NAME "u_skyColor"
#define UNIFORM_DENSITY_NAME "u_density"
#define UNIFORM_GRADIENT_NAME "u_gradient"

@implementation StaticShaderProgram {
    GLuint uniform_transformation_matrix_location,
           uniform_projection_matrix_location,
           uniform_normal_matrix_location,
           uniform_view_matrix_location,
           uniform_light_color_location,
           uniform_light_position_location,
           uniform_sky_color_location,
           uniform_density_location,
           uniform_gradient_location;
}

+ (StaticShaderProgram *)staticShaderProgram
{
    return [[StaticShaderProgram alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:FRAGMENT_SHADER_FILE_NAME])) {
        
    }
    
    return self;
}

- (void)bindAttributes
{
    [super bindAttribute:0 toVariableName:IN_POSITION_NAME];
    [super bindAttribute:1 toVariableName:IN_TEX_COORDS_NAME];
    [super bindAttribute:2 toVariableName:IN_NORMALS_NAME];
}

- (void)getAllUniformLocations
{
    uniform_transformation_matrix_location = [super getUniformLocation:UNIFORM_TRANSFORMATION_MATRIX_NAME];
    uniform_projection_matrix_location = [super getUniformLocation:UNIFORM_PROJECTION_MATRIX_NAME];
    uniform_normal_matrix_location = [super getUniformLocation:UNIFORM_NORMAL_MATRIX_NAME];
    uniform_view_matrix_location = [super getUniformLocation:UNIFORM_VIEW_MATRIX_NAME];
    uniform_light_color_location = [super getUniformLocation:UNIFORM_LIGHT_COLOR_NAME];
    uniform_light_position_location = [super getUniformLocation:UNIFORM_LIGHT_POSITION_NAME];
    uniform_sky_color_location = [super getUniformLocation:UNIFORM_SKY_COLOR_NAME];
    uniform_density_location = [super getUniformLocation:UNIFORM_DENSITY_NAME];
    uniform_gradient_location = [super getUniformLocation:UNIFORM_GRADIENT_NAME];
}

- (void)loadFogDensity:(GLfloat)density andGradient:(GLfloat)gradient
{
    [super loadFloat:density toLocation:uniform_density_location];
    [super loadFloat:gradient toLocation:uniform_gradient_location];
}

- (void)loadSkyColor:(GLKVector3)skyColor
{
    [super loadFloatVector3:skyColor toLocation:uniform_sky_color_location];
}

- (void)loadLight:(Light *)light
{
    [self loadFloatVector3:light.position toLocation:uniform_light_position_location];
    [self loadFloatVector3:light.color toLocation:uniform_light_color_location];
}

- (void)loadTransformationMatrix:(GLKMatrix4)transformationMatrix
{
    [super loadMatrix4x4:transformationMatrix toLocation:uniform_transformation_matrix_location];
}

- (void)loadProjectionMatrix:(GLKMatrix4)projectionMatrix
{
    [super loadMatrix4x4:projectionMatrix toLocation:uniform_projection_matrix_location];
}

- (void)loadViewMatrix:(GLKMatrix4)viewMatrix
{
    [super loadMatrix4x4:viewMatrix toLocation:uniform_view_matrix_location];
}

- (void)loadNormalMatrixWithModelMatrix:(GLKMatrix4)modelMatrix andViewMatrix:(GLKMatrix4)viewMatrix
{
    [super loadMatrix3x3:MathUtils_CreateNormalMatrix(modelMatrix, viewMatrix) toLocation:uniform_normal_matrix_location];
}

@end
