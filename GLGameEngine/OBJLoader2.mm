//
//  OBJLoader2.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 18.06.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "OBJLoader2.h"
#import <simd/simd.h>
#include <vector>

@interface OBJLoader2 () {
    std::vector<vector_float3> vertices;
    std::vector<vector_float2> textureCoordinates;
    std::vector<vector_float3> normals;
    std::vector<GLuint> indices;
}

@end

@implementation OBJLoader2

- (instancetype)initWithURL:(NSURL *)url texture:(ModelTexture *)texture andLoader:(Loader *)loader
{
    if ((self = [super init])) {
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfURL:url
                                                          encoding:NSASCIIStringEncoding
                                                             error:&error];
        
        if (error) {
            NSLog(@"[OBJLoader]: CAN'T LOAD FILE %@: %@", url, error);
            return nil;
        } else if ([fileContents isEqualToString:@""]) {
            NSLog(@"[OBJLoader]: CAN'T PARSE EMPTY FILE");
            return nil;
        }
        
        self.texturedModel = [self createTexturedModelWithOBJFileContent:fileContents
                                                                  loader:loader
                                                              andTexture:texture];
    }
    
    return self;
}

- (TexturedModel *)createTexturedModelWithOBJFileContent:(NSString *)content loader:(Loader *)loader andTexture:(ModelTexture *)texture
{
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    int i = 0;
    for (; i < lines.count; i++) {
        NSString *line = [lines objectAtIndex:i];
        NSArray *components = [line componentsSeparatedByString:@" "];
        
        if (components.count <= 1) {
            continue;
        }
        
        NSString *type = [components objectAtIndex:0];
        
        if ([type isEqualToString:@"v"]) {
            vector_float3 vertex = (vector_float3) {
                [(NSString *)[components objectAtIndex:1] floatValue],
                [(NSString *)[components objectAtIndex:2] floatValue],
                [(NSString *)[components objectAtIndex:3] floatValue],
            };
            vertices.push_back(vertex);
        } else if ([type isEqualToString:@"vt"]) {
            vector_float2 texCoord = (vector_float2) {
                [(NSString *)[components objectAtIndex:1] floatValue],
                [(NSString *)[components objectAtIndex:2] floatValue],
            };
            textureCoordinates.push_back(texCoord);
        } else if ([type isEqualToString:@"vn"]) {
            vector_float3 normal = (vector_float3) {
                [(NSString *)[components objectAtIndex:1] floatValue],
                [(NSString *)[components objectAtIndex:2] floatValue],
                [(NSString *)[components objectAtIndex:3] floatValue],
            };
            normals.push_back(normal);
        } else if ([type isEqualToString:@"f"]) {
            break;
        }
    }
    
    float normalArray[self->normals.size() * 3];
    float vertexArray[self->vertices.size() * 3];
    float textureCoordArray[self->textureCoordinates.size() * 2];
    GLuint indexArray[self->vertices.size()];
    
    for (i += 1; i < lines.count; i++) {
        NSLog(@"length: %lu", (unsigned long)lines.count);
        NSString *line = [lines objectAtIndex:i];
        NSArray *components = [line componentsSeparatedByString:@" "];
        
        if (components.count <= 1) {
            continue;
        }
        
        NSString *type = [components objectAtIndex:0];
        
        if (![type isEqualToString:@"f"])
            continue;
        
        NSArray *vertex1 = [(NSString *)components[1] componentsSeparatedByString:@"/"];
        NSArray *vertex2 = [(NSString *)components[2] componentsSeparatedByString:@"/"];
        NSArray *vertex3 = [(NSString *)components[3] componentsSeparatedByString:@"/"];
        
        [self processVertex:vertex1 withNormalArray:(float **)&(normalArray) andTextureCoordinateArray:(float **)&textureCoordArray];
        [self processVertex:vertex2 withNormalArray:(float **)&(normalArray) andTextureCoordinateArray:(float **)&textureCoordArray];
        [self processVertex:vertex3 withNormalArray:(float **)&(normalArray) andTextureCoordinateArray:(float **)&textureCoordArray];
    }
    
    int vertexPointer = 0;
    for (auto vertex : vertices) {
        vertexArray[vertexPointer++] = vertex[0];
        vertexArray[vertexPointer++] = vertex[1];
        vertexArray[vertexPointer++] = vertex[2];
    }
    
    for (int i = 0; i < indices.size(); i++) {
        indexArray[i] = indices[i];
    }
    
    return [loader createTexturedModelWithPositions:vertexArray
                                    positionsLength:sizeof(vertexArray)
                                            normals:normalArray
                                      normalsLength:sizeof(normalArray)
                                 textureCoordinates:textureCoordArray
                           textureCoordinatesLength:sizeof(textureCoordArray)
                                            indices:indexArray
                                      indicesLength:sizeof(indexArray)
                                         andTexture:texture];
}

- (void)processVertex:(NSArray *)vertexData withNormalArray:(float *[])normalArray andTextureCoordinateArray:(float **)texCoordArray
{
    GLuint currentVertexPointer = [[vertexData objectAtIndex:0] unsignedIntValue];
    indices.push_back(currentVertexPointer);
    
    vector_float2 currentTex = textureCoordinates[[[vertexData objectAtIndex:1] unsignedIntValue] - 1];
    *texCoordArray[currentVertexPointer * 2] = currentTex[0];
    *texCoordArray[currentVertexPointer * 2 + 1] = currentTex[1];
    
    vector_float3 currentNormal = normals[[[vertexData objectAtIndex:2] unsignedIntValue] - 1];
    *normalArray[currentVertexPointer * 3] = currentNormal[0];
    *normalArray[currentVertexPointer * 3 + 1] = currentNormal[1];
    *normalArray[currentVertexPointer * 3 + 2] = currentNormal[2];
}

@end
