//
//  MasterRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.08.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "MasterRenderer.h"
#import "TexturedModel.h"
#import "Entity.h"

// Field of View in degrees
static const GLfloat FOVY = 45;
static const GLfloat NEARZ = 0.1;
static const GLfloat FARZ = 200;

typedef NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> EntityMap;

@interface MasterRenderer ()

@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (strong, nonatomic, nonnull) EntityMap *entities;
@property (strong, nonnull, nonatomic) NSMutableArray<Terrain *> *terrains;

@end

@implementation MasterRenderer

#pragma mark - init
+ (MasterRenderer *)renderer
{
    return [[MasterRenderer alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        float aspect = size.width / size.height;
        
        [self updateProjectionForAspect:aspect];
        
        self.shader = [StaticShaderProgram staticShaderProgram];
        self.entityRenderer = [EntityRenderer rendererWithShaderProgram:self.shader];
        self.terrainShader = [TerrainShader terrainShaderProgram];
        self.terrainRenderer = [TerrainRenderer terrainRendererWithShader:self.terrainShader];
        
        self.skyColor = RGBAMake(0.5f, 0.5f, 0.5f, 1.f);
        self.fog = kDefaultFog;
        
        [self setupProperties];
        
        _entities = [EntityMap dictionary];
        _terrains = [NSMutableArray<Terrain *> array];
    }
    
    return self;
}

- (void)setupProperties
{
    [MasterRenderer enableCulling];
}

+ (void)enableCulling
{
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);
}

+ (void)disableCulling
{
    glDisable(GL_CULL_FACE);
}

- (void)updateProjectionForAspect:(float)aspect
{
    [self createProjectionMatrixWithAspect:aspect];
    [self.shader activate];
    [self.shader loadProjectionMatrix:_projectionMatrix];
    [self.shader deactivate];
    
    [self.terrainShader activate];
    [self.terrainShader loadProjectionMatrix:_projectionMatrix];
    [self.terrainShader deactivate];
}

#pragma mark - Rendering
- (void)renderWithLight:(Light *)light andCamera:(Camera *)camera
{
    [self prepare];
    [self.shader activate];
    [self.shader loadLight:light];
    [self.shader loadSkyColor:RGBAGetGLKVector3(self.skyColor)];
    [self.shader loadViewMatrix:[camera getViewMatrix]];
    [self.entityRenderer render:self.entities withCamera:camera];
    [self.shader deactivate];
    
    [self.terrainShader activate];
    [self.terrainShader loadLight:light];
    [self.terrainShader loadSkyColor:RGBAGetGLKVector3(self.skyColor)];
    [self.terrainShader loadViewMatrix:[camera getViewMatrix]];
    [self.terrainRenderer render:self.terrains withCamera:camera];
    [self.terrainShader deactivate];
    
    [self clearEntities];
    [self clearTerrains];
}

- (void)prepare
{
    glClearColor(self.skyColor.r, self.skyColor.g, self.skyColor.b, self.skyColor.a);
    glClearDepthf(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);
}

#pragma mark - Entity Map
- (void)processEntity:(Entity *)entity
{
    TexturedModel *entityModel = entity.model;
    NSMutableArray<Entity *> *batch = [self.entities objectForKey:entityModel];
    
    if (batch != nil) {
        [self.entities[entityModel] addObject:entity];
    } else {
        NSMutableArray<Entity *> *newBatch = [NSMutableArray array];
        [newBatch addObject:entity];
        
        [self.entities setObject:newBatch forKey:entityModel];
    }
}

- (void)processTerrain:(Terrain *)terrain
{
    [self.terrains addObject:terrain];
}

- (void)clearEntities
{
    [self.entities removeAllObjects];
}

- (void)clearTerrains
{
    [self.terrains removeAllObjects];
}

#pragma mark - private methods
- (void)createProjectionMatrixWithAspect:(float)aspect
{
    _projectionMatrix = GLKMatrix4MakePerspective(MathUtils_DegToRad(FOVY), aspect, NEARZ, FARZ);
}

#pragma mark - Memory
- (void)cleanUp
{
    [self.shader cleanUp];
    [self.terrainShader cleanUp];
}

#pragma mark - getters / setters
- (void)setFog:(Fog)fog
{
    NSLog(@"set");
    _fog = fog;
    
    [self.shader activate];
    [self.shader loadFogDensity:fog.density andGradient:fog.gradient];
    [self.shader deactivate];
    
    [self.terrainShader activate];
    [self.terrainShader loadFogDensity:fog.density andGradient:fog.gradient];
    [self.terrainShader deactivate];
}

@end


EXPORT RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
    return (RGBA) {
        MAX(0., MIN(red, 1.)),
        MAX(0., MIN(green, 1.)),
        MAX(0., MIN(blue, 1.)),
        MAX(0., MIN(alpha, 1.)),
    };
}

EXPORT RGBA RGBAMakeFromRGBHex(uint32_t hex) {
    // 0x FF   AA   88
    //   red green blue
    
    return (RGBA) {
        (hex >> 16) / 255,
        ((hex >> 8) & 0x00FF) / 255,
        (hex & 0x0000FF) / 255,
        1.0
    };
}

EXPORT GLKVector4 RGBAGetGLKVector4(RGBA rgba) {
    return GLKVector4Make(rgba.r, rgba.g, rgba.b, rgba.a);
}

EXPORT GLKVector3 RGBAGetGLKVector3(RGBA rgba) {
    return GLKVector3Make(rgba.r, rgba.g, rgba.b);
}


Fog FogMake(GLfloat density, GLfloat gradient) {
    return (Fog) {
        density, gradient
    };
}
