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
        [self.shader activate];
        [self.shader loadTextureUnits];
        [self.shader deactivate];
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
    
    /*glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);*/
    
    [self bindTexturesForTerrain:terrain];
}

- (void)bindTexturesForTerrain:(Terrain *)terrain
{
    TerrainTexturePackage *pack = terrain.texturePack;
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(pack.backgroundTexture.textureTarget, pack.backgroundTexture.textureID);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(pack.rTexture.textureTarget, pack.rTexture.textureID);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(pack.gTexture.textureTarget, pack.gTexture.textureID);
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(pack.bTexture.textureTarget, pack.bTexture.textureID);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(terrain.blendMap.textureTarget, terrain.blendMap.textureID);
}

- (void)unbindTerrain
{
    /*glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);*/
}

- (void)loadTerrainMatricesWithTerrain:(Terrain *)terrain andViewMatrix:(GLKMatrix4)viewMat
{
    GLKMatrix4 transformationMatrix = GLKMatrix4MakeTranslation(terrain.x, 0, terrain.z);
    [self.shader loadTransformationMatrix:transformationMatrix];
    [self.shader loadNormalMatrixWithModelMatrix:transformationMatrix
                                   andViewMatrix:viewMat];
}

@end
