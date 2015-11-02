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
#define UNIFORM_LIGHT_COLOR_NAME(i) ([NSString stringWithFormat:@"u_lightColor[%d]", (i)].UTF8String)
#define UNIFORM_LIGHT_POSITION_NAME(i) ([NSString stringWithFormat:@"u_lightPosition[%d]", (i)].UTF8String)
#define UNIFORM_ATTENUATION_NAME(i) ([NSString stringWithFormat:@"u_attenuation[%d]", (i)].UTF8String)
#define UNIFORM_DAMPER_NAME "u_damper"
#define UNIFORM_REFLECTIVITY_NAME "u_reflectivity"
#define UNIFORM_SKY_COLOR_NAME "u_skyColor"
#define UNIFORM_DENSITY_NAME "u_density"
#define UNIFORM_GRADIENT_NAME "u_gradient"
#define UNIFORM_NUMBER_OF_ROWS_NAME "u_numberOfRows"
#define UNIFORM_OFFSET_NAME "u_offset"

@implementation StaticShaderProgram {
    GLuint uniform_transformation_matrix_location,
           uniform_projection_matrix_location,
           uniform_normal_matrix_location,
           uniform_view_matrix_location,
           uniform_light_color_locations[MAX_LIGHTS],
           uniform_light_position_locations[MAX_LIGHTS],
           uniform_attenuation_locations[MAX_LIGHTS],
           uniform_damper_location,
           uniform_reflectivity_location,
           uniform_sky_color_location,
           uniform_density_location,
           uniform_gradient_location,
           uniform_number_of_rows_location,
           uniform_offset_location;
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
    uniform_sky_color_location = [super getUniformLocation:UNIFORM_SKY_COLOR_NAME];
    uniform_density_location = [super getUniformLocation:UNIFORM_DENSITY_NAME];
    uniform_gradient_location = [super getUniformLocation:UNIFORM_GRADIENT_NAME];
    uniform_number_of_rows_location = [super getUniformLocation:UNIFORM_NUMBER_OF_ROWS_NAME];
    uniform_offset_location = [super getUniformLocation:UNIFORM_OFFSET_NAME];
    uniform_damper_location = [super getUniformLocation:UNIFORM_DAMPER_NAME];
    uniform_reflectivity_location = [super getUniformLocation:UNIFORM_REFLECTIVITY_NAME];
    
    
    for (GLuint i = 0; i < MAX_LIGHTS; i++) {
        uniform_light_color_locations[i] = [super getUniformLocation:UNIFORM_LIGHT_COLOR_NAME(i)];
        uniform_light_position_locations[i] = [super getUniformLocation:UNIFORM_LIGHT_POSITION_NAME(i)];
        uniform_attenuation_locations[i] = [super getUniformLocation:UNIFORM_ATTENUATION_NAME(i)];
    }
}

- (void)loadDamper:(GLfloat)damper andReflectivity:(GLfloat)reflectivity
{
    [super loadFloat:damper toLocation:uniform_damper_location];
    [super loadFloat:reflectivity toLocation:uniform_reflectivity_location];
}

- (void)loadOffset:(GLKVector2)offset
{
    [super loadFloatVector2:offset toLocation:uniform_offset_location];
}

- (void)loadNumberOfRows:(GLint)numberOfRows
{
    [super loadFloat:numberOfRows toLocation:uniform_number_of_rows_location];
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

- (void)loadLights:(NSArray<Light *> *)lights
{
    for (GLuint i = 0; i < MAX_LIGHTS; i++) {
        if (i < lights.count) {
            [super loadFloatVector3:lights[i].position toLocation:uniform_light_position_locations[i]];
            [super loadFloatVector3:lights[i].color toLocation:uniform_light_color_locations[i]];
            [super loadFloatVector3:lights[i].attenuation toLocation:uniform_attenuation_locations[i]];
        } else {
            [super loadFloatVector3:GLKVector3Make(0, 0, 0) toLocation:uniform_light_position_locations[i]];
            [super loadFloatVector3:GLKVector3Make(0, 0, 0) toLocation:uniform_light_color_locations[i]];
            [super loadFloatVector3:GLKVector3Make(1, 0, 0) toLocation:uniform_attenuation_locations[i]];
        }
    }
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
