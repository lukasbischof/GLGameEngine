//
//  Terrain.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTypesShim.h"
#import "RawModel.h"
#import "TerrainTexturePackage.h"
#import "Loader.h"
#import "MathUtils.h"

static const GLfloat TERRAIN_SIZE = 400;

@interface Terrain : NSObject

@property (assign, nonatomic) GLfloat x;
@property (assign, nonatomic) GLfloat z;
@property (strong, nonatomic, readonly, nonnull) RawModel *model;
@property (strong, nonatomic, readonly, nonnull) TerrainTexturePackage *texturePack;
@property (strong, nonatomic, readonly, nonnull) TerrainTexture *blendMap;

+ (Terrain *_Nonnull)terrainWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *_Nonnull)loader texturePack:(TerrainTexturePackage *_Nonnull)texturePack heightMapName:(NSString *_Nonnull)heightMap andBlendMap:(TerrainTexture *_Nonnull)blendMap;

- (_Nonnull instancetype)initWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *_Nonnull)loader texturePack:(TerrainTexturePackage *_Nonnull)texturePack heightMapName:(NSString *_Nonnull)heightMap andBlendMap:(TerrainTexture *_Nonnull)blendMap;

/**
 CPU-only initializer: wraps raw RGBA heightmap bytes (4 bytes per pixel,
 width*height pixels, copied) without touching the Loader or the GPU, so the
 height sampling below is unit-testable. No RawModel is generated on this path.
*/
- (_Nonnull instancetype)initWithGridX:(GLint)gridX gridZ:(GLint)gridZ heightMapData:(const uint8_t *_Nonnull)data width:(NSUInteger)width height:(NSUInteger)height;

- (GLfloat)getHeightAtWorldX:(GLfloat)worldX worldZ:(GLfloat)worldZ;

@end
