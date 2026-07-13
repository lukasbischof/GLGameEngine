//
//  Loader.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Loader.h"
#import "MetalContext.h"
#import <UIKit/UIKit.h>

@interface Loader () {
    // Metal objects are reference counted by ARC; these arrays keep
    // everything alive until cleanUp (the former GL id lists).
    NSMutableArray<id<MTLBuffer>> *buffers;
    NSMutableArray<id<MTLTexture>> *textures;

    MTKTextureLoader *textureLoader;
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
        textureLoader = [[MTKTextureLoader alloc] initWithDevice:[MetalContext sharedContext].device];
        [self restoreObjectsCreationLists];
    }

    return self;
}

// Initialisiert die Listen, die dafür zuständig sind, alle erstellten Objekte zu halten,    \
    damit wir sie auch wieder löschen können.
- (void)restoreObjectsCreationLists
{
    buffers = [NSMutableArray array];
    textures = [NSMutableArray array];
}

- (id<MTLTexture>)loadCubeTexture:(NSArray<NSString *> *)textureNames
{
    if (!textureNames) {
        NSLog(@"[Loader]: Can't load cube texture %@", textureNames);
        return nil;
    }

    // MTKTextureLoader can't build a cube map from six separate files, so the
    // faces are decoded to RGBA8 and copied into the slices directly. The file
    // order matches the Metal cube slice order: +X,-X,+Y,-Y,+Z,-Z.
    id<MTLTexture> cubeTexture = nil;

    for (NSUInteger face = 0; face < 6; face++) {
        UIImage *image = [UIImage imageWithContentsOfFile:textureNames[face]];
        CGImageRef cgImage = image.CGImage;

        if (!cgImage) {
            NSLog(@"[Loader]: Can't load texture: %@", textureNames[face]);
            return nil;
        }

        size_t size = CGImageGetWidth(cgImage);

        if (!cubeTexture) {
            MTLTextureDescriptor *descriptor = [MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                     size:size
                                                                                                mipmapped:NO];
            descriptor.usage = MTLTextureUsageShaderRead;
            cubeTexture = [[MetalContext sharedContext].device newTextureWithDescriptor:descriptor];
        }

        NSMutableData *pixelData = [NSMutableData dataWithLength:size * size * 4];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixelData.mutableBytes, size, size, 8, size * 4, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);

        if (!context) {
            NSLog(@"[Loader]: Can't decode cube face: %@", textureNames[face]);
            return nil;
        }

        CGContextDrawImage(context, CGRectMake(0, 0, size, size), cgImage);
        CGContextRelease(context);

        [cubeTexture replaceRegion:MTLRegionMake2D(0, 0, size, size)
                       mipmapLevel:0
                             slice:face
                         withBytes:pixelData.bytes
                       bytesPerRow:size * 4
                     bytesPerImage:size * size * 4];
    }

    [textures addObject:cubeTexture];

    return cubeTexture;
}

- (id<MTLTexture>)loadTexture:(NSString *)textureName withExtension:(NSString *)extension flipped:(BOOL)flipped
{
    NSString *path = [[NSBundle mainBundle] pathForResource:textureName ofType:extension];
    if (!path) {
        NSLog(@"[Loader]: Can't load texture %@.%@", textureName, extension);
        return nil;
    }

    NSError *error;
    NSDictionary *options = @{
        MTKTextureLoaderOptionOrigin: flipped ? MTKTextureLoaderOriginBottomLeft : MTKTextureLoaderOriginTopLeft,
        MTKTextureLoaderOptionGenerateMipmaps: @YES,
        // keep linear pixel formats; don't let image metadata opt into sRGB
        MTKTextureLoaderOptionSRGB: @NO,
        MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead)
    };
    id<MTLTexture> texture = [textureLoader newTextureWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                                options:options
                                                                  error:&error];

    if (error) {
        NSLog(@"[Loader]: Can't load texture: %@", error);
        return nil;
    }

    [textures addObject:texture];

    return texture;
}

- (id<MTLTexture>)loadTexture:(NSString *)textureName withExtension:(NSString *)extension
{
    return [self loadTexture:textureName withExtension:extension flipped:YES];
}

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions dimensions:(uint32_t)dimensions
{
    if (positions.data == NULL)
        return nil;

    uint32_t vertexCount = (uint32_t)(positions.length / sizeof(float) / dimensions);
    RawModel *model = [RawModel modelWithVertexCount:vertexCount];

    [self storeData:positions inAttributeSlot:0 ofModel:model];

    return model;
}

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions
                                  normals:(FloatBuffer)normals
                               andIndices:(UintBuffer)indices
{
    if (positions.data == NULL || indices.data == NULL || normals.data == NULL)
        return nil;

    uint32_t vertexCount = (uint32_t)(indices.length / UINT_BUFFER_ELEMENT_SIZE);
    RawModel *model = [RawModel modelWithVertexCount:vertexCount];

    [self bindIndicesBuffer:indices toModel:model];
    [self storeData:positions inAttributeSlot:0 ofModel:model];
    [self storeData:normals inAttributeSlot:2 ofModel:model];

    return model;
}

- (RawModel *)createRawModelWithPositions:(FloatBuffer)positions
                                  normals:(FloatBuffer)normals
                            textureCoords:(FloatBuffer)texCoords
                               andIndices:(UintBuffer)indices
{
    if (positions.data == NULL || indices.data == NULL || normals.data == NULL || texCoords.data == NULL)
        return nil;

    uint32_t vertexCount = (uint32_t)(indices.length / UINT_BUFFER_ELEMENT_SIZE);
    RawModel *model = [RawModel modelWithVertexCount:vertexCount];

    [self bindIndicesBuffer:indices toModel:model];
    [self storeData:positions inAttributeSlot:0 ofModel:model];
    [self storeData:texCoords inAttributeSlot:1 ofModel:model];
    [self storeData:normals inAttributeSlot:2 ofModel:model];

    return model;
}

- (TexturedModel *)createTexturedModelWithPositions:(FloatBuffer)positions
                                            normals:(FloatBuffer)normals
                                 textureCoordinates:(FloatBuffer)texCoords
                                            indices:(UintBuffer)indices
                                         andTexture:(ModelTexture *)texture
{
    RawModel *rawModel = [self createRawModelWithPositions:positions normals:normals andIndices:indices];

    [self storeData:texCoords inAttributeSlot:1 ofModel:rawModel];

    return [[TexturedModel alloc] initWithRawModel:rawModel andTexture:texture];
}

- (TexturedModel *)createTexturedModelWithPositions:(float *)positions
                                    positionsLength:(size_t)positionsLength
                                            normals:(float *)normals
                                      normalsLength:(size_t)normalsLength
                                 textureCoordinates:(float *)textureCoordinates
                           textureCoordinatesLength:(size_t)texCoordsLength
                                            indices:(uint32_t *)indices
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

- (TexturedModel *)createTexturedModelWithPositions:(MTKMeshBuffer *)positions
                                            normlas:(MTKMeshBuffer *)normals
                                 textureCoordinates:(MTKMeshBuffer *)texCoords
                                          submeshes:(NSArray<MTKSubmesh *> *)submeshes
                                         andTexture:(ModelTexture *)texture
{
    if (!positions || !normals || !texCoords || !submeshes || !texture) {
        NSLog(@"[Loader]: Can't create textured model in %s", __PRETTY_FUNCTION__);
        return nil;
    }

    MTKSubmesh *submesh = submeshes[0];
    RawModel *model = [RawModel modelWithVertexCount:(uint32_t)submesh.indexCount];

    [self setBuffer:positions inAttributeSlot:0 ofModel:model];
    [self setBuffer:texCoords inAttributeSlot:1 ofModel:model];
    [self setBuffer:normals inAttributeSlot:2 ofModel:model];

    model.indexBuffer = submesh.indexBuffer.buffer;
    model.indexBufferOffset = submesh.indexBuffer.offset;
    model.indexType = submesh.indexType;

    [buffers addObject:submesh.indexBuffer.buffer];

    return [[TexturedModel alloc] initWithRawModel:model andTexture:texture];
}

- (void)setBuffer:(MTKMeshBuffer *)buffer inAttributeSlot:(uint32_t)attribIndex ofModel:(RawModel *)model
{
    [buffers addObject:buffer.buffer];

    [model setVertexBuffer:buffer.buffer offset:buffer.offset atIndex:attribIndex];
}

- (void)storeData:(FloatBuffer)data inAttributeSlot:(uint32_t)attribIndex ofModel:(RawModel *)model
{
    id<MTLBuffer> buffer = [[MetalContext sharedContext].device newBufferWithBytes:data.data
                                                                            length:data.length
                                                                           options:MTLResourceStorageModeShared];

    [buffers addObject:buffer];

    [model setVertexBuffer:buffer offset:0 atIndex:attribIndex];
}

- (void)bindIndicesBuffer:(UintBuffer)indexBuffer toModel:(RawModel *)model
{
    id<MTLBuffer> buffer = [[MetalContext sharedContext].device newBufferWithBytes:indexBuffer.data
                                                                            length:indexBuffer.length
                                                                           options:MTLResourceStorageModeShared];

    [buffers addObject:buffer];

    model.indexBuffer = buffer;
    model.indexBufferOffset = 0;
    model.indexType = MTLIndexTypeUInt32;
}

- (void)cleanUp
{
    [buffers removeAllObjects];
    [textures removeAllObjects];
    [self restoreObjectsCreationLists];
}

@end
