//
//  Loader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Loader.h"
#include <vector>
#include <stdio.h>
#include <iostream>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface Loader () {
    std::vector<GLuint> vaos;
    std::vector<GLuint> vbos;
    std::vector<GLuint> textures;
}

@end

@implementation Loader

+ (Loader *)loader
{
    return [Loader new];
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self restoreObjectsCreationLists];
    }
    
    return self;
}

// Initialisiert die Listen, die dafür zuständig sind, alle GL-IDs der erstellten Objekte zu halten,    \
    damit wir sie auch wieder löschen können.
- (void)restoreObjectsCreationLists
{
    vaos = std::vector<GLuint>();
    vbos = std::vector<GLuint>();
    textures = std::vector<GLuint>();
}

- (GLKTextureInfo *)loadTexture:(NSString *)textureName withExtension:(NSString *)extension
{
    NSString *path = [[NSBundle mainBundle] pathForResource:textureName ofType:extension];
    if (!path) {
        NSLog(@"[Loader]: Can't load texture %@.%@", textureName, extension);
        return nil;
    }
    
    NSError *error;
    NSDictionary *options = @{
        GLKTextureLoaderOriginBottomLeft: @YES,
        GLKTextureLoaderGenerateMipmaps: @YES
    };
    GLKTextureInfo *texInfo = [GLKTextureLoader textureWithContentsOfFile:path
                                                                  options:options
                                                                    error:&error];
    
    if (error) {
        NSLog(@"[Loader]: Can't load texture: %@", error);
        NSLog(@"OpenGL Error: %u", glGetError());
        return nil;
    }
    
    textures.push_back(texInfo.name);
    
    return texInfo;
}

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions
                                  normals:(FloatBuffer)normals
                               andIndices:(UintBuffer)indices
{
    if (positions.data == NULL || indices.data == NULL || normals.data == NULL)
        return nil;
    
    GLuint vertexCount = (GLuint)(indices.length / UINT_BUFFER_ELEMENT_SIZE);
    RawModel *model = [RawModel modelByCreatingVAOWithVertexCount:vertexCount];
    
    vaos.push_back(model.vaoID);
    
    [model bindVAO];
    [self bindIndicesBuffer:indices];
    [self storeData:positions inVAOAttribIndex:0 withAttribSize:3];
    [self storeData:normals inVAOAttribIndex:2 withAttribSize:3];
    [model unbindVAO];
    
    return model;
}

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions
                                  normals:(FloatBuffer)normals
                            textureCoords:(FloatBuffer)texCoords
                               andIndices:(UintBuffer)indices
{
    if (positions.data == NULL || indices.data == NULL || normals.data == NULL || texCoords.data == NULL)
        return nil;
    
    GLuint vertexCount = (GLuint)(indices.length / UINT_BUFFER_ELEMENT_SIZE);
    RawModel *model = [RawModel modelByCreatingVAOWithVertexCount:vertexCount];
    
    vaos.push_back(model.vaoID);
    
    [model bindVAO];
    [self bindIndicesBuffer:indices];
    [self storeData:positions inVAOAttribIndex:0 withAttribSize:3];
    [self storeData:texCoords inVAOAttribIndex:1 withAttribSize:2];
    [self storeData:normals inVAOAttribIndex:2 withAttribSize:3];
    [model unbindVAO];
    
    return model;
}

- (TexturedModel *)createTexturedModelWithPositions:(FloatBuffer)positions
                                           normals:(FloatBuffer)normals
                                textureCoordinates:(FloatBuffer)texCoords
                                           indices:(UintBuffer)indices
                                        andTexture:(ModelTexture *)texture
{
    RawModel *rawModel = [self createRawModelWithPositions:positions normals:normals andIndices:indices];
    
    [rawModel bindVAO];
    [self storeData:texCoords inVAOAttribIndex:1 withAttribSize:2];
    [rawModel unbindVAO];
    
    return [[TexturedModel alloc] initWithRawModel:rawModel andTexture:texture];
    
//    RawModel *rawModel = [self createRawModelWithPositions:positions normals:normals textureCoords:texCoords andIndices:indices];
//    
//    return [[TexturedModel alloc] initWithRawModel:rawModel andTexture:texture];
}

- (TexturedModel *)createTexturedModelWithPositions:(GLfloat *)positions
                                    positionsLength:(size_t)positionsLength
                                            normals:(GLfloat *)normals
                                      normalsLength:(size_t)normalsLength
                                 textureCoordinates:(GLfloat *)textureCoordinates
                           textureCoordinatesLength:(size_t)texCoordsLength
                                            indices:(GLuint *)indices
                                      indicesLength:(size_t)indicesLength
                                         andTexture:(ModelTexture *)texture
{
    FloatBuffer positionBuf = FloatBufferCreateWithDataNoCopy(positions, positionsLength);
    FloatBuffer texCoordsBuf = FloatBufferCreateWithDataNoCopy(textureCoordinates, texCoordsLength);
    UintBuffer indicesBuf = UintBufferCreateWithDataNoCopy(indices, indicesLength);
    FloatBuffer normalsBuf = FloatBufferCreateWithDataNoCopy(normals, normalsLength);
    
    return [self createTexturedModelWithPositions:positionBuf
                                          normals:normalsBuf
                               textureCoordinates:texCoordsBuf
                                          indices:indicesBuf
                                       andTexture:texture];
}

- (TexturedModel *)createTexturedModelWithPositions:(GLKMeshBuffer *)positions
                                            normlas:(GLKMeshBuffer *)normals
                                 textureCoordinates:(GLKMeshBuffer *)texCoords
                                        vertexCount:(NSUInteger)vertexCount
                                          submeshes:(NSArray<GLKSubmesh *> *)submeshes
                                         andTexture:(ModelTexture *)texture
{
    if (!positions || !normals || !texCoords || !submeshes || !texture) {
        NSLog(@"[Loader]: Can't create textured model in %s", __PRETTY_FUNCTION__);
        return nil;
    }
    
    RawModel *model = [RawModel modelByCreatingVAOWithVertexCount:(GLuint)vertexCount];
    
    vaos.push_back(model.vaoID);
    
    GLKSubmesh *submesh = submeshes[0];
    
    [model bindVAO];
    [self setBuffer:positions inVAOAttribIndex:0 withAttribSize:3 andType:GL_FLOAT];
    [self setBuffer:texCoords inVAOAttribIndex:1 withAttribSize:2 andType:GL_HALF_FLOAT];
    [self setBuffer:normals inVAOAttribIndex:2 withAttribSize:3 andType:GL_FLOAT];
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, submesh.elementBuffer.glBufferName);
    
    [model unbindVAO];
    
    return [[TexturedModel alloc] initWithRawModel:model andTexture:texture];
}

- (void)setBuffer:(GLKMeshBuffer *)buffer inVAOAttribIndex:(GLuint)attribIndex withAttribSize:(GLint)size andType:(GLenum)type
{
    vbos.push_back(buffer.glBufferName);
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer.glBufferName);
    glVertexAttribPointer(attribIndex, size, type, GL_FALSE, 0, BUFFER_OFFSET(buffer.offset));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)storeData:(FloatBuffer)data inVAOAttribIndex:(GLuint)attribIndex withAttribSize:(GLint)size
{
    GLuint vboID;
    glGenBuffers(1, &vboID);
    
    vbos.push_back(vboID);
    
    glBindBuffer(GL_ARRAY_BUFFER, vboID);
    glBufferData(GL_ARRAY_BUFFER, data.length, data.data, GL_STATIC_DRAW);
    glVertexAttribPointer(attribIndex, size, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)bindIndicesBuffer:(UintBuffer)indexBuffer
{
    GLuint vbo;
    glGenBuffers(1, &vbo);
    
    vbos.push_back(vbo);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexBuffer.length, indexBuffer.data, GL_STATIC_DRAW);
}

- (void)cleanUp
{
    // auto: C++11
    for (auto &vao : vaos) {
        glDeleteVertexArrays(1, &vao);
    }
    
    for (auto &vbo : vbos) {
        glDeleteBuffers(1, &vbo);
    }
    
    for (auto &tex : textures) {
        glDeleteTextures(1, &tex);
    }
    
    [self restoreObjectsCreationLists];
}

@end
