//
//  Loader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "GLTypesShim.h"
#import "RawModel.h"
#import "TexturedModel.h"
#import "Buffer.h"

@interface Loader : NSObject

+ (Loader *)loader;

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions dimensions:(GLuint)dimensions;
- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals andIndices:(UintBuffer)indices;
- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals textureCoords:(FloatBuffer)texCoords andIndices:(UintBuffer)indices;

- (TexturedModel *)createTexturedModelWithPositions:(FloatBuffer)positions normals:(FloatBuffer)normals textureCoordinates:(FloatBuffer)texCoords indices:(UintBuffer)indices andTexture:(ModelTexture *)texture;
- (TexturedModel *)createTexturedModelWithPositions:(GLfloat *)positions positionsLength:(size_t)positionsLength normals:(GLfloat *)normals normalsLength:(size_t)normalsLength textureCoordinates:(GLfloat *)textureCoordinates textureCoordinatesLength:(size_t)texCoordsLength indices:(GLuint *)indices indicesLength:(size_t)indicesLength andTexture:(ModelTexture *)texture;
- (TexturedModel *)createTexturedModelWithPositions:(MTKMeshBuffer *)positions normlas:(MTKMeshBuffer *)normals textureCoordinates:(MTKMeshBuffer *)texCoords submeshes:(NSArray<MTKSubmesh *> *)submeshes andTexture:(ModelTexture *)texture;

- (id<MTLTexture>)loadTexture:(NSString *)textureName withExtension:(NSString *)extension flipped:(BOOL)flipped;
- (id<MTLTexture>)loadTexture:(NSString *)textureName withExtension:(NSString *)extension;

/**
 @method loadCubeTexture:
 @param textureNames    The Names. As NSString. Order: Right(+x), Left(-x), Top(+y), Bottom(-y), Front(+z), Back(-z).
 @return The cube Map
*/
- (id<MTLTexture>)loadCubeTexture:(NSArray<NSString *> *)textureNames;

- (void)cleanUp;

@end
