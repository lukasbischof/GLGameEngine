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

struct _RGBA {
    GLfloat r, g, b, a;
};
typedef struct _RGBA RGBA;

@interface MasterRenderer : NSObject

@property (assign, nonatomic) RGBA clearColor;

@property (strong, nonatomic, nonnull) StaticShaderProgram *shader;
@property (strong, nonatomic, nonnull) TerrainShader *terrainShader;
@property (strong, nonatomic, nonnull) EntityRenderer *entityRenderer;
@property (strong, nonatomic, nonnull) TerrainRenderer *terrainRenderer;

+ (MasterRenderer *_Nonnull)renderer;

- (void)updateProjectionForAspect:(float)aspect;
- (void)processEntity:(Entity *_Nonnull)entity;
- (void)processTerrain:(Terrain *_Nonnull)terrain;
- (void)renderWithLight:(Light *_Nonnull)light andCamera:(Camera *_Nonnull)camera;
- (void)cleanUp;

@end

EXPORT RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
EXPORT RGBA RGBAMakeFromRGBHex(uint32_t hex);
EXPORT GLKVector4 RGBAGetGLKVector4(RGBA rgba);
EXPORT GLKVector3 RGBAGetGLKVector3(RGBA rgba);
