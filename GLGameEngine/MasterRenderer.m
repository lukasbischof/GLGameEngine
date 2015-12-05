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
#import "NSObject+class.h"

// Field of View in degrees
static const GLfloat FOVY = 45.0;
static const GLfloat NEARZ = 1.5;
static const GLfloat FARZ = 300.0;

typedef NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> EntityMap;
typedef NSMutableArray<InstanceableTexturedModel *> InstancingEntityMap;

@interface MasterRenderer ()

@property (assign, nonatomic) GLKMatrix4 projectionMatrix;
@property (strong, nonatomic, nonnull) EntityMap *entities;
@property (strong, nonnull, nonatomic) InstancingEntityMap *instancedEntities;
@property (strong, nonatomic, nonnull) NSMutableArray<Terrain *> *terrains;
@property (strong, nonatomic, nonnull) NSMutableArray<WaterTile *> *waterTiles;

@end

@implementation MasterRenderer

#pragma mark - init
+ (MasterRenderer *)rendererWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)fbos
{
    return [[MasterRenderer alloc] initWithLoader:loader andFBOs:fbos];
}

- (instancetype)init
{
    NSLog(@"[%@]: Direct init not supported", [self className]);
    return nil;
}

#warning fbos ist _Nullable, wird aber nicht im Initializer geprüft
- (instancetype)initWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)fbos
{
    if ((self = [super init])) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        float aspect = size.width / size.height;
        
        [self updateProjectionForAspect:aspect];
        
        self.shader = [StaticShaderProgram staticShaderProgram];
        self.instancingShader = [InstancingShaderProgram instancingShaderProgram];
        self.entityRenderer = [EntityRenderer rendererWithShaderProgram:self.shader andInstancingShaderProgram:self.instancingShader];
        self.terrainShader = [TerrainShader terrainShaderProgram];
        self.terrainRenderer = [TerrainRenderer terrainRendererWithShader:self.terrainShader];
        self.skyboxRenderer = [SkyboxRenderer skyboxRendererWithLoader:loader];
        self.waterRenderer = [WaterRenderer waterRendererWithLoader:loader andFBOs:fbos];
        self.guiRenderer = [GUIRenderer rendererWithLoader:loader];
        
        self.skyColor = RGBAMake(0.5f, 0.5f, 0.5f, 1.f);
        self.fog = kDefaultFog;
        
        [self setupProperties];
        
        _entities = [EntityMap dictionary];
        _instancedEntities = [InstancingEntityMap array];
        _terrains = [NSMutableArray<Terrain *> array];
        _waterTiles = [NSMutableArray<WaterTile *> array];
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
    
    [self.instancingShader bind:^{
        [self.instancingShader loadProjectionMatrix:_projectionMatrix];
    }];
    
    [self.terrainShader activate];
    [self.terrainShader loadProjectionMatrix:_projectionMatrix];
    [self.terrainShader deactivate];
    
    [self.skyboxRenderer updateProjectionMatrix:_projectionMatrix];
    [self.waterRenderer updateProjectionMatrix:_projectionMatrix];
}

#pragma mark - Rendering
- (void)renderGUI:(NSArray<GUITexture *> *)guis
{
    [self.guiRenderer render:guis];
}

- (void)renderWithLights:(NSArray<Light *> *)lights camera:(Camera * _Nonnull)camera andClippingPlane:(GLKVector4)clippingPlane
{
    [self prepare];
    
    [self.skyboxRenderer renderWithCamera:camera];
    
    // The depth will be turned on after the skybox render call automatically
    glDepthFunc(GL_LESS);
    
    glEnable(GL_CLIP_DISTANCE0_APPLE);
    
    [self.shader activate];
    [self.shader loadClippingPlane:clippingPlane];
    [self.shader loadLights:lights];
    [self.shader loadSkyColor:RGBAGetGLKVector3(self.skyColor)];
    [self.shader loadViewMatrix:[camera getViewMatrix]];
    [self.entityRenderer render:self.entities withCamera:camera];
    [self.shader deactivate];
    
    [self.instancingShader activate];
    [self.instancingShader loadClippingPlane:clippingPlane];
    [self.instancingShader loadLights:lights];
    [self.instancingShader loadSkyColor:RGBAGetGLKVector3(self.skyColor)];
    [self.instancingShader loadViewMatrix:[camera getViewMatrix]];
    [self.entityRenderer renderInstances:self.instancedEntities withCamera:camera];
    [self.instancingShader deactivate];
    
    [self.terrainShader activate];
    [self.terrainShader loadClippingPlane:clippingPlane];
    [self.terrainShader loadLights:lights];
    [self.terrainShader loadSkyColor:RGBAGetGLKVector3(self.skyColor)];
    [self.terrainShader loadViewMatrix:[camera getViewMatrix]];
    [self.terrainRenderer render:self.terrains withCamera:camera];
    [self.terrainShader deactivate];
}

- (void)renderWaterWithCamera:(Camera *)camera andLight:(Light * _Nonnull)light
{
    [self.waterRenderer render:self.waterTiles withCamera:camera andLight:light];
}

- (void)finishedFrame
{
    [self clearWaterTiles];
    [self clearEntities];
    [self clearTerrains];
}

- (void)prepare
{
    glClearColor(self.skyColor.r, self.skyColor.g, self.skyColor.b, self.skyColor.a);
    glClearDepthf(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
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

- (void)processInstanceableModel:(InstanceableTexturedModel *)model
{
    [self.instancedEntities addObject:model];
}

- (void)processTerrain:(Terrain *)terrain
{
    [self.terrains addObject:terrain];
}

- (void)processWaterTile:(WaterTile *)tile
{
    [self.waterTiles addObject:tile];
}

- (void)clearEntities
{
    [self.entities removeAllObjects];
    [self.instancedEntities removeAllObjects];
}

- (void)clearTerrains
{
    [self.terrains removeAllObjects];
}

- (void)clearWaterTiles
{
    [self.waterTiles removeAllObjects];
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
    [self.instancingShader cleanUp];
    [self.terrainShader cleanUp];
    [self.waterRenderer cleanUp];
    [self.skyboxRenderer cleanUp];
    [self.guiRenderer cleanUp];
}

#pragma mark - getters / setters
- (void)setFog:(Fog)fog
{
    // NSLog(@"set");
    _fog = fog;
    
    [self.shader activate];
    [self.shader loadFogDensity:fog.density andGradient:fog.gradient];
    [self.shader deactivate];
    
    [self.instancingShader bind:^{
        [self.instancingShader loadFogDensity:fog.density andGradient:fog.gradient];
    }];
    
    [self.terrainShader activate];
    [self.terrainShader loadFogDensity:fog.density andGradient:fog.gradient];
    [self.terrainShader deactivate];
}

- (void)setSkyColor:(RGBA)skyColor
{
    _skyColor = skyColor;
    
    [self.skyboxRenderer updateFogColor:RGBAGetGLKVector3(skyColor)];
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
