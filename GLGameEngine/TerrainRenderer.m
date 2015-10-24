//
//  TerrainRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainRenderer.h"

@interface TerrainRenderer ()

@property (strong, nonatomic) TerrainShader *shader;

@end

@implementation TerrainRenderer

+ (TerrainRenderer *)terrainRendererWithShader:(TerrainShader *)shader
{
    return [[TerrainRenderer alloc] initWithShader:shader];
}

- (instancetype)initWithShader:(TerrainShader *)shader
{
    if ((self = [super init])) {
        self.shader = shader;
    }
    
    return self;
}

- (void)render:(NSArray<Terrain *> *)terrains withCamera:(Camera *)camera
{
    for (Terrain *terrain in terrains) {
        [self prepareTerrain:terrain];
        [self loadTerrainMatricesWithTerrain:terrain andViewMatrix:[camera getViewMatrix]];
        
        glDrawElements(GL_TRIANGLES, terrain.model.vertexCount, GL_UNSIGNED_INT, 0);
        
        [self unbindTerrain];
    }
}

- (void)prepareTerrain:(Terrain *)terrain
{
    RawModel *model = terrain.model;
    [model bindVAO];
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(terrain.texture.textureTarget, terrain.texture.textureID);
}

- (void)unbindTerrain
{
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
}

- (void)loadTerrainMatricesWithTerrain:(Terrain *)terrain andViewMatrix:(GLKMatrix4)viewMat
{
    GLKMatrix4 transformationMatrix = GLKMatrix4MakeTranslation(terrain.x, 0, terrain.z);
    [self.shader loadTransformationMatrix:transformationMatrix];
    [self.shader loadNormalMatrixWithModelMatrix:transformationMatrix
                                   andViewMatrix:viewMat];
}

@end
