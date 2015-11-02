//
//  TerrainShader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainShader.h"
#import "MathUtils.h"

NSString *const TERRAIN_VERTEX_SHADER_FILE_NAME = @"TerrainVertexShader";
NSString *const TERRAIN_FRAGMENT_SHADER_FILE_NAME = @"TerrainFragmentShader";

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
#define UNIFORM_SKY_COLOR_NAME "u_skyColor"
#define UNIFORM_DENSITY_NAME "u_density"
#define UNIFORM_GRADIENT_NAME "u_gradient"
#define UNIFORM_BACKGROUND_SAMPLER_NAME "u_backgroundSampler"
#define UNIFORM_R_SAMPLER_NAME "u_rSampler"
#define UNIFORM_G_SAMPLER_NAME "u_gSampler"
#define UNIFORM_B_SAMPLER_NAME "u_bSampler"
#define UNIFORM_BLEND_MAP_SAMPLER_NAME "u_blendMapSampler"

@implementation TerrainShader {
    GLuint uniform_transformation_matrix_location,
           uniform_projection_matrix_location,
           uniform_normal_matrix_location,
           uniform_view_matrix_location,
           uniform_light_color_locations[MAX_LIGHTS],
           uniform_light_position_locations[MAX_LIGHTS],
           uniform_attenuation_locations[MAX_LIGHTS],
           uniform_sky_color_location,
           uniform_density_location,
           uniform_gradient_location,
           uniform_background_sampler_location,
           uniform_r_sampler_location,
           uniform_g_sampler_location,
           uniform_b_sampler_location,
           uniform_blend_map_sampler_location;
}

+ (TerrainShader *)terrainShaderProgram
{
    return [[TerrainShader alloc] init];
}

- (instancetype)init
{
    if ((self = [super initWithVertexShaderName:TERRAIN_VERTEX_SHADER_FILE_NAME
                          andFragmentShaderName:TERRAIN_FRAGMENT_SHADER_FILE_NAME])) {
        
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
    uniform_background_sampler_location = [super getUniformLocation:UNIFORM_BACKGROUND_SAMPLER_NAME];
    uniform_r_sampler_location = [super getUniformLocation:UNIFORM_R_SAMPLER_NAME];
    uniform_g_sampler_location = [super getUniformLocation:UNIFORM_G_SAMPLER_NAME];
    uniform_b_sampler_location = [super getUniformLocation:UNIFORM_B_SAMPLER_NAME];
    uniform_blend_map_sampler_location = [super getUniformLocation:UNIFORM_BLEND_MAP_SAMPLER_NAME];
    
    for (GLuint i = 0; i < MAX_LIGHTS; i++) {
        uniform_light_position_locations[i] = [super getUniformLocation:UNIFORM_LIGHT_POSITION_NAME(i)];
        uniform_light_color_locations[i] = [super getUniformLocation:UNIFORM_LIGHT_COLOR_NAME(i)];
        uniform_attenuation_locations[i] = [super getUniformLocation:UNIFORM_ATTENUATION_NAME(i)];
    }
}

- (void)loadTextureUnits
{
    [super loadInt:0 toLocation:uniform_background_sampler_location];
    [super loadInt:1 toLocation:uniform_r_sampler_location];
    [super loadInt:2 toLocation:uniform_g_sampler_location];
    [super loadInt:3 toLocation:uniform_b_sampler_location];
    [super loadInt:4 toLocation:uniform_blend_map_sampler_location];
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
