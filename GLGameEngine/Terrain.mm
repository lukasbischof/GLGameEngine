//
//  Terrain.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "Terrain.h"
#import "Buffer.h"
#include <stdio.h>
#include <iostream>

using namespace std;

static const GLfloat MAX_HEIGHT = 20.f;
static const GLint MAX_PIXEL_COLOR = 256 + 256 + 256;

@interface Terrain () <NSObject> {
    @package
}

@end

@implementation Terrain {
    uint8_t *_data;
    CGFloat  _width;
    CGFloat  _height;
    size_t   _bytesPerRow;
}

#pragma mark - Init
+ (Terrain *)terrainWithGridX:(GLint)gridX
                        gridZ:(GLint)gridZ
                       loader:(Loader *)loader
                  texturePack:(TerrainTexturePackage *)texturePack
                 heightMapName:(NSString *)heightMap
                  andBlendMap:(TerrainTexture *)blendMap
{
    return [[Terrain alloc] initWithGridX:gridX
                                    gridZ:gridZ
                                   loader:loader
                              texturePack:texturePack
                            heightMapName:heightMap
                              andBlendMap:blendMap];
}

- (instancetype)initWithGridX:(GLint)gridX
                        gridZ:(GLint)gridZ
                       loader:(Loader *)loader
                  texturePack:(TerrainTexturePackage *)texturePack
                 heightMapName:(NSString *)heightMap
                  andBlendMap:(TerrainTexture *)blendMap
{
    if ((self = [super init])) {
        _texturePack = texturePack;
        _blendMap = blendMap;
        self.x = gridX * TERRAIN_SIZE;
        self.z = gridZ * TERRAIN_SIZE;
        
        UIImage *heightMapImage = [UIImage imageNamed:heightMap];
        if (heightMapImage && [self getImageData:heightMapImage]) {
            NSLog(@"loaded map");
        } else {
            UIImage *heightMapImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", heightMap]];
            
            NSAssert((nil != heightMapImage), @"<< ERROR >>: CAN'T LOAD HEIGHTMAP '%@'", heightMap);
            
            #ifdef DEBUG
                NSLog(@"The heightmap %@ couldn't be loaded. But a map called %@.jpg could be loaded. Perhaps you forgot to write the extension? The second one will be used", heightMap, heightMap);
            #else
                // abort();
            #endif
            
            NSAssert([self getImageData:heightMapImage], @"<< ERROR >>: CAN'T LOAD HEIGHTMAP '%@'", heightMap);
        }
        
        _model = [self generateTerrain:loader];
    }
    
    return self;
}

#pragma mark - Image Processing
- (BOOL)getImageData:(UIImage *)image
{
    CGImageRef img = image.CGImage;
    NSUInteger width = CGImageGetWidth(img);
    NSUInteger height = CGImageGetHeight(img);
    
    _width = width;
    _height = height;
    _bytesPerRow = 4 * width;
    _data = [self getBinaryDataForImage:img flipped:YES];
    
    if (_data)
        return YES;
    else
        return NO;
}

- (uint8_t *)getBinaryDataForImage:(CGImageRef)image flipped:(BOOL)flipped
{
    NSUInteger width = CGImageGetWidth(image);
    NSUInteger height = CGImageGetHeight(image);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
#   if defined(DEBUG)
        NSLog(@"bytesPerRow: %zu, bitsPerComponent: %zu, bitsPerPixel: %zu", CGImageGetBytesPerRow(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image));
#   endif
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    if (flipped) {
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1, -1);
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    
    return rawData;
}

#pragma mark - Height getters
- (GLfloat)getHeightAtX:(GLint)x y:(GLint)y
{
    if (x < 0 || y < 0 || x >= _width || y >= _height) {
        return 0.;
    }
    
    //GLuint offset = _bytesPerRow * (GLfloat)y + (GLfloat)x * 4;
    GLuint offset = 4 * (_width * y + x);
    GLuint r = _data[offset];
    GLuint g = _data[offset + 1];
    GLuint b = _data[offset + 2];
    
    GLfloat sum = (GLfloat)(r + g + b);
    sum = ((sum / (GLfloat)MAX_PIXEL_COLOR) * MAX_HEIGHT * 2) - MAX_HEIGHT;
    
    return sum;
}

- (GLfloat)getHeightAtWorldX:(GLfloat)worldX worldZ:(GLfloat)worldZ
{
    GLfloat terrainX = worldX - self.x;
    GLfloat terrainZ = worldZ - self.z;
    GLfloat gridSquareSize = TERRAIN_SIZE / (_height - 1);
    GLint gridX = floorf(terrainX / gridSquareSize);
    GLint gridZ = floorf(terrainZ / gridSquareSize);
    
    if (gridX >= _height - 1 || gridZ >= _height - 1 || gridX < 0 || gridZ < 0) {
        std::cerr << "[Terrain.mm]: Out of bounds (Accessing x=" << worldX << ", z=" << worldZ << ")\n";
        return 0.f;
    }
    
    GLfloat xCoord = fmodf(terrainX, gridSquareSize) / gridSquareSize;
    GLfloat zCoord = fmodf(terrainZ, gridSquareSize) / gridSquareSize;
    
    GLfloat ret = 0.0f;
    if (xCoord <= (1 - zCoord)) {
        ret = MathUtils_BarryCentric(GLKVector3Make(0, [self getHeightAtX:gridX y:gridZ], 0),
                                     GLKVector3Make(1, [self getHeightAtX:gridX + 1 y:gridZ], 0),
                                     GLKVector3Make(0, [self getHeightAtX:gridX y:gridZ + 1], 1),
                                     GLKVector2Make(xCoord, zCoord));
    } else {
        ret = MathUtils_BarryCentric(GLKVector3Make(1, [self getHeightAtX:gridX + 1 y:gridZ], 0),
                                     GLKVector3Make(1, [self getHeightAtX:gridX + 1 y:gridZ + 1], 1),
                                     GLKVector3Make(0, [self getHeightAtX:gridX y:gridZ + 1], 1),
                                     GLKVector2Make(xCoord, zCoord));
    }
    
    return ret;
}

#pragma mark - Generation
- (GLKVector3)calculateNormalAtX:(GLint)x y:(GLint)y
{
    GLfloat heightL = [self getHeightAtX:x-1 y:y];
    GLfloat heightR = [self getHeightAtX:x+1 y:y];
    GLfloat heightD = [self getHeightAtX:x   y:y-1];
    GLfloat heightU = [self getHeightAtX:x   y:y+1];
    GLKVector3 normal = GLKVector3Make(heightL - heightR, 2.f, heightD - heightU);
    
    return GLKVector3Normalize(normal);
}

- (RawModel *)generateTerrain:(Loader *)loader
{
    GLuint VERTEX_COUNT = _height;
    GLuint count = VERTEX_COUNT * VERTEX_COUNT;
    NSMutableData *vertices = [NSMutableData dataWithCapacity:count * 3 * sizeof(GLfloat)];
    NSMutableData *normals = [NSMutableData dataWithCapacity:count * 3 * sizeof(GLfloat)];
    NSMutableData *textureCoords = [NSMutableData dataWithCapacity:count * 2 * sizeof(GLfloat)];
    NSMutableData *indices = [NSMutableData dataWithCapacity:6 * (VERTEX_COUNT - 1) * (VERTEX_COUNT - 1) * sizeof(GLuint)];
    
    for (GLuint i = 0; i < VERTEX_COUNT; i++) {
        for (GLuint j = 0; j < VERTEX_COUNT; j++) {
            GLfloat x = (GLfloat)j / ((GLfloat)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            GLfloat y = [self getHeightAtX:j y:i];
            GLfloat z = (GLfloat)i / ((GLfloat)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            
            [vertices appendBytes:&x length:sizeof(GLfloat)];
            [vertices appendBytes:&y length:sizeof(GLfloat)];
            [vertices appendBytes:&z length:sizeof(GLfloat)];
            
            GLKVector3 normal = [self calculateNormalAtX:j y:i];
            [normals appendBytes:&normal.x length:sizeof(GLfloat)];
            [normals appendBytes:&normal.y length:sizeof(GLfloat)];
            [normals appendBytes:&normal.z length:sizeof(GLfloat)];
            
            GLfloat u = (GLfloat)j / ((GLfloat)VERTEX_COUNT - 1);
            GLfloat v = (GLfloat)i / ((GLfloat)VERTEX_COUNT - 1);
            
            [textureCoords appendBytes:&u length:sizeof(GLfloat)];
            [textureCoords appendBytes:&v length:sizeof(GLfloat)];
        }
    }
    
    for (GLuint gz = 0; gz < VERTEX_COUNT - 1; gz++) {
        for (GLuint gx = 0; gx < VERTEX_COUNT - 1; gx++) {
            GLuint topLeft = (gz * VERTEX_COUNT) + gx;
            GLuint topRight = topLeft + 1;
            GLuint bottomLeft = ((gz + 1) * VERTEX_COUNT) + gx;
            GLuint bottomRight = bottomLeft + 1;
            
            [indices appendBytes:&topLeft length:sizeof(GLuint)];
            [indices appendBytes:&bottomLeft length:sizeof(GLuint)];
            [indices appendBytes:&topRight length:sizeof(GLuint)];
            [indices appendBytes:&topRight length:sizeof(GLuint)];
            [indices appendBytes:&bottomLeft length:sizeof(GLuint)];
            [indices appendBytes:&bottomRight length:sizeof(GLuint)];
        }
    }
    
    FloatBuffer positionsBuffer = FloatBufferCreateWithDataNoCopy((const GLfloat *)[vertices bytes], [vertices length]);
    FloatBuffer normalsBuffer = FloatBufferCreateWithDataNoCopy((const GLfloat *)normals.bytes, normals.length);
    FloatBuffer texCoordsBuffer = FloatBufferCreateWithDataNoCopy((const GLfloat *)textureCoords.bytes, textureCoords.length);
    UintBuffer indicesBuffer = UintBufferCreateWithDataNoCopy((const GLuint *)indices.bytes, indices.length);
    
    return [loader createRawModelWithPositions:positionsBuffer normals:normalsBuffer textureCoords:texCoordsBuffer andIndices:indicesBuffer];
}

@end
