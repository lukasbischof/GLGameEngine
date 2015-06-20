//
//  OBJLoader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "OBJLoader.h"
#import <GLKit/GLKit.h>
#include <vector>
#include <map>

struct Face {
    uint32_t vi, ni, ti;
    
    Face() : vi(0), ni(0), ti(0)
    {
        
    }
};

@interface OBJLoader () {
    std::vector<GLKVector3> vertices;
    std::vector<GLKVector2> texCoords;
    std::vector<GLKVector3> normals;
//    std::vector<GLuint> indices; // std::__1::vector<unsigned int, std::__1::allocator<unsigned int>>
    std::vector<Face> faces;
}

@end

@implementation OBJLoader

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
        
        vertices = std::vector<GLKVector3>();
        normals = std::vector<GLKVector3>();
        texCoords = std::vector<GLKVector2>();
        
        self.texturedModel = [self parseModelWithFileContents:fileContents
                                                   withLoader:loader
                                                   andTexture:texture];
    }
    
    return self;
}

- (TexturedModel *)parseModelWithFileContents:(NSString *)contents withLoader:(Loader *)loader andTexture:(ModelTexture *)texture
{
    NSScanner *scanner = [NSScanner scannerWithString:contents];
    NSCharacterSet *skipSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *consumeSet = [skipSet invertedSet];
    
    scanner.charactersToBeSkipped = skipSet;
    
    while (![scanner isAtEnd]) {
        NSString *currentType;
        if (![scanner scanCharactersFromSet:consumeSet intoString:&currentType])
            break;
        
        if ([currentType isEqualToString:@"v"]) {
            // Vertex
            
            float x = 0, y = 0, z = 0;
            [scanner scanFloat:&x];
            [scanner scanFloat:&y];
            [scanner scanFloat:&z];
            
            vertices.push_back(GLKVector3Make(x, y, z));
        } else if ([currentType isEqualToString:@"vt"]) {
            // Vertex texture
            
            float u = 0, v = 0;
            [scanner scanFloat:&u];
            [scanner scanFloat:&v];
            
            texCoords.push_back(GLKVector2Make(u, v));
        } else if ([currentType isEqualToString:@"vn"]) {
            // Vertex normal
            
            float x = 0, y = 0, z = 0;
            [scanner scanFloat:&x];
            [scanner scanFloat:&y];
            [scanner scanFloat:&z];
            
            normals.push_back(GLKVector3Make(x, y, z));
        } else if ([currentType isEqualToString:@"f"]) {
            // Face
            
            while (true) {
                uint32_t vi, ni, ti;
                
                if (![scanner scanHexInt:&vi])
                    break;
                
                if ([scanner scanString:@"/" intoString:NULL]) {
                    [scanner scanHexInt:&ti];
                    
                    if ([scanner scanString:@"/" intoString:NULL]) {
                        [scanner scanHexInt:&ni];
                    }
                }
                
                Face face = Face();
                
                //face.vi = (vi < 0) ? (vertices.size() + vi - 1) : (vi - 1);
                //face.ti = (ti < 0) ? (texCoords.size() + ti - 1) : (ti - 1);
                //face.ni = (ni < 0) ? (vertices.size() + ni - 1) : (ni - 1);
                face.vi = vi - 1;
                face.ti = ti - 1;
                face.ni = ni - 1;
                
                faces.push_back(face);
            }
        }
    }
    
    @try {
        GLfloat finalTexCoords[self->vertices.size() * 2];
        GLfloat finalNormals[self->vertices.size() * 3];
        GLfloat finalVertices[self->vertices.size() * 3];
        GLuint finalIndices[self->faces.size()];
        
        //std::vector<GLuint> indices(self->faces.size());
        
        NSUInteger i = 0;
        for (auto face : faces) {
            GLuint currentVertexIndex = (GLuint)face.vi;
            //indices.push_back(currentVertexIndex);
            finalIndices[i++] = currentVertexIndex;
            
            GLKVector3 currentVertex = vertices[currentVertexIndex];
            finalVertices[currentVertexIndex * 3] = currentVertex.x;
            finalVertices[currentVertexIndex * 3 + 1] = currentVertex.y;
            finalVertices[currentVertexIndex * 3 + 2] = currentVertex.z;
            
            GLKVector2 currentTexCoord = texCoords[face.ti];
            finalTexCoords[currentVertexIndex * 2] = currentTexCoord.x;
            finalTexCoords[currentVertexIndex * 2 + 1] = 1 - currentTexCoord.y;
            
            GLKVector3 currentNormal = normals[face.ni];
            finalNormals[currentVertexIndex * 3] = currentNormal.x;
            finalNormals[currentVertexIndex * 3 + 1] = currentNormal.y;
            finalNormals[currentVertexIndex * 3 + 2] = currentNormal.z;
        }
        
        TexturedModel *model = [loader createTexturedModelWithPositions:finalVertices
                                                        positionsLength:sizeof(finalVertices)
                                                                normals:finalNormals
                                                          normalsLength:sizeof(finalNormals)
                                                     textureCoordinates:finalTexCoords
                                               textureCoordinatesLength:sizeof(finalTexCoords)
                                                                indices:finalIndices
                                                          indicesLength:sizeof(finalIndices)
                                                             andTexture:texture];
        
        return model;
    } @catch (NSException *exception) {
        NSLog(@"[OBJLoader]: CAN'T PARSE FILE; EXCEPTION %@", exception);
        return nil;
    }
}

@end


