//
//  MasterRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.08.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticShaderProgram.h"
#import "EntityRenderer.h"
#import "TerrainRenderer.h"
#import "SkyboxRenderer.h"
#import "WaterRenderer.h"
#import "GUIRenderer.h"
#import "InstancingShaderProgram.h"
#import "InstanceableTexturedModel.h"

typedef struct {
    GLfloat density;
    GLfloat gradient;
} Fog;

static const Fog kDefaultFog = (Fog) {
    0.015,
    1.8
};

static const Fog kNoFog = (Fog){ 0.f, 1.f };

struct _RGBA {
    GLfloat r, g, b, a;
};
typedef struct _RGBA RGBA;

@interface MasterRenderer : NSObject

@property (assign, nonatomic) RGBA skyColor;
@property (assign, nonatomic) Fog fog;

@property (strong, nonatomic, nonnull) StaticShaderProgram *shader;
@property (strong, nonatomic, nonnull) InstancingShaderProgram *instancingShader;
@property (strong, nonatomic, nonnull) TerrainShader *terrainShader;
@property (strong, nonatomic, nonnull) EntityRenderer *entityRenderer;
@property (strong, nonatomic, nonnull) TerrainRenderer *terrainRenderer;
@property (strong, nonatomic, nonnull) SkyboxRenderer *skyboxRenderer;
@property (strong, nonatomic, nonnull) WaterRenderer *waterRenderer;
@property (strong, nonatomic, nonnull) GUIRenderer *guiRenderer;

+ (MasterRenderer *_Nonnull)rendererWithLoader:(Loader *_Nonnull)loader andFBOs:(WaterFrameBuffers *_Nullable)fbos;

- (_Nonnull instancetype)initWithLoader:(Loader *_Nonnull)loader andFBOs:(WaterFrameBuffers *_Nullable)fbos;

+ (void)enableCulling;
+ (void)disableCulling;

- (void)updateProjectionForAspect:(float)aspect;
- (void)processEntity:(Entity *_Nonnull)entity;
- (void)processInstanceableModel:(InstanceableTexturedModel *_Nonnull)model;
- (void)processTerrain:(Terrain *_Nonnull)terrain;
- (void)processWaterTile:(WaterTile *_Nonnull)tile;
- (void)renderWithLights:(NSArray<Light *> *_Nonnull)lights camera:(Camera *_Nonnull)camera andClippingPlane:(GLKVector4)clippingPlane;
- (void)renderWaterWithCamera:(Camera *_Nonnull)camera andLight:(Light *_Nonnull)light;
- (void)finishedFrame;
- (void)renderGUI:(NSArray<GUITexture *> *_Nonnull)guis;
- (void)cleanUp;

@end

EXPORT RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
EXPORT RGBA RGBAMakeFromRGBHex(uint32_t hex);
EXPORT GLKVector4 RGBAGetGLKVector4(RGBA rgba);
EXPORT GLKVector3 RGBAGetGLKVector3(RGBA rgba);

EXPORT Fog FogMake(GLfloat density, GLfloat gradient);
