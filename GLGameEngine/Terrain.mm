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

+ (Terrain *)terrainWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *)loader andTexture:(ModelTexture *)texture
{
    return [[Terrain alloc] initWithGridX:gridX
                                    gridZ:gridZ
                                   loader:loader
                               andTexture:texture];
}

- (instancetype)initWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *)loader andTexture:(ModelTexture *)texture
{
    if ((self = [super init])) {
        _texture = texture;
        self.x = gridX * TERRAIN_SIZE;
        self.z = gridZ * TERRAIN_SIZE;
        _model = [self generateTerrain:loader];
        
        glBindTexture(self.texture.textureTarget, self.texture.textureID);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(self.texture.textureTarget, GL_TEXTURE_WRAP_T, GL_REPEAT);
    }
    
    return self;
}

- (RawModel *)generateTerrain:(Loader *)loader
{
    /*
    GLfloat vertices[] = {
        -50.0, 0.0, -50.0,
         50.0, 0.0, -50.0,
        -50.0, 0.0,  50.0,
         50.0, 0.0,  50.0
    };
    
    GLfloat normals[] = {
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
        0.0, 1.0, 0.0,
    };
    
    GLfloat texCoords[] = {
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0,
    };
    
    GLuint indices[] = {
        0, 1, 2,
        1, 2, 3
    };
    
    FloatBuffer positions = FloatBufferCreateWithDataNoCopy(vertices, sizeof(vertices));
    FloatBuffer normalsBuf = FloatBufferCreateWithDataNoCopy(normals, sizeof(normals));
    FloatBuffer texCoordsBuf = FloatBufferCreateWithDataNoCopy(texCoords, sizeof(texCoords));
    UintBuffer indicesBuf = UintBufferCreateWithDataNoCopy(indices, sizeof(indices));
    
    return [loader createRawModelWithPositions:positions normals:normalsBuf textureCoords:texCoordsBuf andIndices:indicesBuf];*/
    
    
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


/*
 private RawModel generateTerrain(Loader loader){
    int count = VERTEX_COUNT * VERTEX_COUNT;
    float[] vertices = new float[count * 3];
    float[] normals = new float[count * 3];
    float[] textureCoords = new float[count*2];
    int[] indices = new int[6*(VERTEX_COUNT-1)*(VERTEX_COUNT-1)];
    int vertexPointer = 0;
        for(int i=0;i<VERTEX_COUNT;i++){
            for(int j=0;j<VERTEX_COUNT;j++){
                vertices[vertexPointer*3] = (float)j/((float)VERTEX_COUNT - 1) * SIZE;
                vertices[vertexPointer*3+1] = 0;
                vertices[vertexPointer*3+2] = (float)i/((float)VERTEX_COUNT - 1) * SIZE;
                normals[vertexPointer*3] = 0;
                normals[vertexPointer*3+1] = 1;
                normals[vertexPointer*3+2] = 0;
                textureCoords[vertexPointer*2] = (float)j/((float)VERTEX_COUNT - 1);
                textureCoords[vertexPointer*2+1] = (float)i/((float)VERTEX_COUNT - 1);
                vertexPointer++;
            }
        }
    int pointer = 0;
    for(int gz=0;gz<VERTEX_COUNT-1;gz++){
        for(int gx=0;gx<VERTEX_COUNT-1;gx++){
            int topLeft = (gz*VERTEX_COUNT)+gx;
            int topRight = topLeft + 1;
            int bottomLeft = ((gz+1)*VERTEX_COUNT)+gx;
            int bottomRight = bottomLeft + 1;
            indices[pointer++] = topLeft;
            indices[pointer++] = bottomLeft;
            indices[pointer++] = topRight;
            indices[pointer++] = topRight;
            indices[pointer++] = bottomLeft;
            indices[pointer++] = bottomRight;
        }
    }
 return loader.loadToVAO(vertices, textureCoords, normals, indices);
}
*/