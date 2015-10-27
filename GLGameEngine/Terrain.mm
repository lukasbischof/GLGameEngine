//
//  Terrain.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "Terrain.h"
#import "Buffer.h"

static const GLint VERTEX_COUNT = 128;

@interface Terrain ()

@end

@implementation Terrain

+ (Terrain *)terrainWithGridX:(GLint)gridX
                        gridZ:(GLint)gridZ
                       loader:(Loader *)loader
                  texturePack:(TerrainTexturePackage *)texturePack
                  andBlendMap:(TerrainTexture *)blendMap
{
    return [[Terrain alloc] initWithGridX:gridX
                                    gridZ:gridZ
                                   loader:loader
                              texturePack:texturePack
                              andBlendMap:blendMap];
}

- (instancetype)initWithGridX:(GLint)gridX
                        gridZ:(GLint)gridZ
                       loader:(Loader *)loader
                  texturePack:(TerrainTexturePackage *)texturePack
                  andBlendMap:(TerrainTexture *)blendMap
{
    if ((self = [super init])) {
        _texturePack = texturePack;
        _blendMap = blendMap;
        self.x = gridX * TERRAIN_SIZE;
        self.z = gridZ * TERRAIN_SIZE;
        _model = [self generateTerrain:loader];
        
        /*glBindTexture(self.texture.textureTarget, self.texture.textureID);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_WRAP_T, GL_REPEAT);*/
    }
    
    return self;
}

- (RawModel *)generateTerrain:(Loader *)loader
{
    GLint count = VERTEX_COUNT * VERTEX_COUNT;
    GLfloat vertices[count * 3];
    GLfloat normals[count * 3];
    GLfloat textureCoords[count * 2];
    GLuint indices[6 * (VERTEX_COUNT - 1) * (VERTEX_COUNT - 1)];
    
    GLuint vertexPointer = 0;
    for (GLuint i = 0; i < VERTEX_COUNT; i++) {
        for (GLuint j = 0; j < VERTEX_COUNT; j++) {
            vertices[vertexPointer * 3] = (GLfloat)j / ((GLfloat)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            vertices[vertexPointer * 3 + 1] = 0;
            vertices[vertexPointer * 3 + 2] = (GLfloat)i / ((GLfloat)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            normals[vertexPointer * 3] = 0;
            normals[vertexPointer * 3 + 1] = 1;
            normals[vertexPointer * 3 + 2] = 0;
            textureCoords[vertexPointer * 2] = (GLfloat)j / ((GLfloat)VERTEX_COUNT - 1);
            textureCoords[vertexPointer * 2 + 1] = (GLfloat)i / ((GLfloat)VERTEX_COUNT - 1);
            vertexPointer++;
        }
    }
    
    GLuint pointer = 0;
    for (GLuint gz = 0; gz < VERTEX_COUNT - 1; gz++) {
        for (GLuint gx = 0; gx < VERTEX_COUNT - 1; gx++) {
            GLuint topLeft = (gz * VERTEX_COUNT) + gx;
            GLuint topRight = topLeft + 1;
            GLuint bottomLeft = ((gz + 1) * VERTEX_COUNT) + gx;
            GLuint bottomRight = bottomLeft + 1;
            indices[pointer++] = topLeft;
            indices[pointer++] = bottomLeft;
            indices[pointer++] = topRight;
            indices[pointer++] = topRight;
            indices[pointer++] = bottomLeft;
            indices[pointer++] = bottomRight;
        }
    }
    
    FloatBuffer positionsBuffer = FloatBufferCreateWithDataNoCopy(vertices, sizeof(vertices));
    FloatBuffer normalsBuffer = FloatBufferCreateWithDataNoCopy(normals, sizeof(normals));
    FloatBuffer texCoordsBuffer = FloatBufferCreateWithDataNoCopy(textureCoords, sizeof(textureCoords));
    UintBuffer indicesBuffer = UintBufferCreateWithDataNoCopy(indices, sizeof(indices));
    
    return [loader createRawModelWithPositions:positionsBuffer normals:normalsBuffer textureCoords:texCoordsBuffer andIndices:indicesBuffer];
}

@end
