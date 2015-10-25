//
//  Loader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "RawModel.h"
#import "TexturedModel.h"
#import "Buffer.h"

@interface Loader : NSObject

+ (Loader *)loader;

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals andIndices:(UintBuffer)indices;
- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals textureCoords:(FloatBuffer)texCoords andIndices:(UintBuffer)indices;

- (TexturedModel *)createTexturedModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals textureCoordinates:(FloatBuffer)texCoords indices:(UintBuffer)indices andTexture:(ModelTexture *)texture;
- (TexturedModel *)createTexturedModelWithPositions:(GLfloat *)positions positionsLength:(size_t)positionsLength normals:(GLfloat *)normals normalsLength:(size_t)normalsLength textureCoordinates:(GLfloat *)textureCoordinates textureCoordinatesLength:(size_t)texCoordsLength indices:(GLuint *)indices indicesLength:(size_t)indicesLength andTexture:(ModelTexture *)texture;
- (TexturedModel *)createTexturedModelWithPositions:(GLKMeshBuffer *)positions normlas:(GLKMeshBuffer *)normals textureCoordinates:(GLKMeshBuffer *)texCoords vertexCount:(NSUInteger)vertexCount submeshes:(NSArray<GLKSubmesh *> *)submeshes andTexture:(ModelTexture *)texture;

- (GLKTextureInfo *)loadTexture:(NSString *)textureName withExtension:(NSString *)extension;

- (void)cleanUp;

@end
