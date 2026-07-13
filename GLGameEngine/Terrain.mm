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

static const float MAX_HEIGHT = 20.f;
static const int32_t MAX_PIXEL_COLOR = 256 + 256 + 256;

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
+ (Terrain *)terrainWithGridX:(int32_t)gridX
                        gridZ:(int32_t)gridZ
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

- (instancetype)initWithGridX:(int32_t)gridX
                        gridZ:(int32_t)gridZ
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

- (instancetype)initWithGridX:(int32_t)gridX
                        gridZ:(int32_t)gridZ
                heightMapData:(const uint8_t *)data
                        width:(NSUInteger)width
                       height:(NSUInteger)height
{
    if ((self = [super init])) {
        self.x = gridX * TERRAIN_SIZE;
        self.z = gridZ * TERRAIN_SIZE;

        _width = width;
        _height = height;
        _bytesPerRow = 4 * width;
        _data = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
        memcpy(_data, data, height * width * 4);
    }

    return self;
}

- (void)dealloc
{
    // _data is the calloc'd heightmap bitmap from getBinaryDataForImage:flipped:
    free(_data);
    _data = NULL;
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
- (float)getHeightAtX:(int32_t)x y:(int32_t)y
{
    if (x < 0 || y < 0 || x >= _width || y >= _height) {
        return 0.;
    }
    
    //uint32_t offset = _bytesPerRow * (float)y + (float)x * 4;
    uint32_t offset = 4 * (_width * y + x);
    uint32_t r = _data[offset];
    uint32_t g = _data[offset + 1];
    uint32_t b = _data[offset + 2];
    
    float sum = (float)(r + g + b);
    sum = ((sum / (float)MAX_PIXEL_COLOR) * MAX_HEIGHT * 2) - MAX_HEIGHT;
    
    return sum;
}

- (float)getHeightAtWorldX:(float)worldX worldZ:(float)worldZ
{
    float terrainX = worldX - self.x;
    float terrainZ = worldZ - self.z;
    float gridSquareSize = TERRAIN_SIZE / (_height - 1);
    int32_t gridX = floorf(terrainX / gridSquareSize);
    int32_t gridZ = floorf(terrainZ / gridSquareSize);
    
    if (gridX >= _height - 1 || gridZ >= _height - 1 || gridX < 0 || gridZ < 0) {
        std::cerr << "[Terrain.mm]: Out of bounds (Accessing x=" << worldX << ", z=" << worldZ << ")\n";
        return 0.f;
    }
    
    float xCoord = fmodf(terrainX, gridSquareSize) / gridSquareSize;
    float zCoord = fmodf(terrainZ, gridSquareSize) / gridSquareSize;
    
    float ret = 0.0f;
    if (xCoord <= (1 - zCoord)) {
        ret = MathUtils_BarryCentric(simd_make_float3(0, [self getHeightAtX:gridX y:gridZ], 0),
                                     simd_make_float3(1, [self getHeightAtX:gridX + 1 y:gridZ], 0),
                                     simd_make_float3(0, [self getHeightAtX:gridX y:gridZ + 1], 1),
                                     simd_make_float2(xCoord, zCoord));
    } else {
        ret = MathUtils_BarryCentric(simd_make_float3(1, [self getHeightAtX:gridX + 1 y:gridZ], 0),
                                     simd_make_float3(1, [self getHeightAtX:gridX + 1 y:gridZ + 1], 1),
                                     simd_make_float3(0, [self getHeightAtX:gridX y:gridZ + 1], 1),
                                     simd_make_float2(xCoord, zCoord));
    }
    
    return ret;
}

#pragma mark - Generation
- (simd_float3)calculateNormalAtX:(int32_t)x y:(int32_t)y
{
    float heightL = [self getHeightAtX:x-1 y:y];
    float heightR = [self getHeightAtX:x+1 y:y];
    float heightD = [self getHeightAtX:x   y:y-1];
    float heightU = [self getHeightAtX:x   y:y+1];
    simd_float3 normal = simd_make_float3(heightL - heightR, 2.f, heightD - heightU);
    
    return simd_normalize(normal);
}

- (RawModel *)generateTerrain:(Loader *)loader
{
    uint32_t VERTEX_COUNT = _height;
    uint32_t count = VERTEX_COUNT * VERTEX_COUNT;
    NSMutableData *vertices = [NSMutableData dataWithCapacity:count * 3 * sizeof(float)];
    NSMutableData *normals = [NSMutableData dataWithCapacity:count * 3 * sizeof(float)];
    NSMutableData *textureCoords = [NSMutableData dataWithCapacity:count * 2 * sizeof(float)];
    NSMutableData *indices = [NSMutableData dataWithCapacity:6 * (VERTEX_COUNT - 1) * (VERTEX_COUNT - 1) * sizeof(uint32_t)];
    
    for (uint32_t i = 0; i < VERTEX_COUNT; i++) {
        for (uint32_t j = 0; j < VERTEX_COUNT; j++) {
            float x = (float)j / ((float)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            float y = [self getHeightAtX:j y:i];
            float z = (float)i / ((float)VERTEX_COUNT - 1) * TERRAIN_SIZE;
            
            [vertices appendBytes:&x length:sizeof(float)];
            [vertices appendBytes:&y length:sizeof(float)];
            [vertices appendBytes:&z length:sizeof(float)];
            
            simd_float3 normal = [self calculateNormalAtX:j y:i];
            // simd vector elements are not addressable; append packed floats
            float normalComponents[3] = { normal.x, normal.y, normal.z };
            [normals appendBytes:normalComponents length:sizeof(normalComponents)];
            
            float u = (float)j / ((float)VERTEX_COUNT - 1);
            float v = (float)i / ((float)VERTEX_COUNT - 1);
            
            [textureCoords appendBytes:&u length:sizeof(float)];
            [textureCoords appendBytes:&v length:sizeof(float)];
        }
    }
    
    for (uint32_t gz = 0; gz < VERTEX_COUNT - 1; gz++) {
        for (uint32_t gx = 0; gx < VERTEX_COUNT - 1; gx++) {
            uint32_t topLeft = (gz * VERTEX_COUNT) + gx;
            uint32_t topRight = topLeft + 1;
            uint32_t bottomLeft = ((gz + 1) * VERTEX_COUNT) + gx;
            uint32_t bottomRight = bottomLeft + 1;
            
            [indices appendBytes:&topLeft length:sizeof(uint32_t)];
            [indices appendBytes:&bottomLeft length:sizeof(uint32_t)];
            [indices appendBytes:&topRight length:sizeof(uint32_t)];
            [indices appendBytes:&topRight length:sizeof(uint32_t)];
            [indices appendBytes:&bottomLeft length:sizeof(uint32_t)];
            [indices appendBytes:&bottomRight length:sizeof(uint32_t)];
        }
    }
    
    FloatBuffer positionsBuffer = FloatBufferCreateWithDataNoCopy((const float *)[vertices bytes], [vertices length]);
    FloatBuffer normalsBuffer = FloatBufferCreateWithDataNoCopy((const float *)normals.bytes, normals.length);
    FloatBuffer texCoordsBuffer = FloatBufferCreateWithDataNoCopy((const float *)textureCoords.bytes, textureCoords.length);
    UintBuffer indicesBuffer = UintBufferCreateWithDataNoCopy((const uint32_t *)indices.bytes, indices.length);
    
    return [loader createRawModelWithPositions:positionsBuffer normals:normalsBuffer textureCoords:texCoordsBuffer andIndices:indicesBuffer];
}

@end
