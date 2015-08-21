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

#define NO_RETURN __attribute__((noreturn))
#define fatal_error(e) ([self reportFatalError:(e)])

@interface OBJLoader2 ()

@end

@implementation OBJLoader2

- (instancetype)init
{
    return nil;
}

- (nullable instancetype)initWithURL:(NSURL * _Nonnull)url texture:(nonnull ModelTexture *)texture andLoader:(nonnull Loader *)loader
{
    if ((self = [super init])) {
        if ([MDLAsset canImportFileExtension:@"obj"]) {
            
            GLKMeshBufferAllocator *_Nonnull allocator = [[GLKMeshBufferAllocator alloc] init];
            
            MDLAsset *asset = [[MDLAsset alloc] initWithURL:url
                                           vertexDescriptor:[self getVertexDescriptor]
                                            bufferAllocator:allocator];
            
            NSArray<GLKMesh *> *newMeshes    = nil;
            NSArray<MDLMesh *> *sourceMeshes = nil;
            NSError *error                   = nil;
            
            newMeshes = [GLKMesh newMeshesFromAsset:asset sourceMeshes:&sourceMeshes error:&error];
            
            if (error) {
                NSLog(@"<< [%@] Error >>: Can't create model: %@", NSStringFromClass([self class]), error);
                return nil;
            } else if (newMeshes.count <= 0) {
                NSLog(@"<< [%@] Error >>: Can't create model array: count <= 0", NSStringFromClass([self class]));
                return nil;
            }
            
            GLKMesh *mesh = newMeshes[0];
            NSArray<GLKMeshBuffer *> *vertexBuffers = mesh.vertexBuffers;
            
            if (vertexBuffers.count < 3 || vertexBuffers.count > 3) {
                NSLog(@"<< [%@] Error >>: Invalid vertex buffer count", NSStringFromClass([self class]));
                return nil;
            }
            
            GLKMeshBuffer *positionBuffer = vertexBuffers[0];
            GLKMeshBuffer *normalBuffer = vertexBuffers[1];
            GLKMeshBuffer *texCoordBuffer = vertexBuffers[2];
            
            TexturedModel *model = [loader createTexturedModelWithPositions:positionBuffer
                                                                    normlas:normalBuffer
                                                         textureCoordinates:texCoordBuffer
                                                                vertexCount:mesh.vertexCount
                                                                  submeshes:mesh.submeshes
                                                                 andTexture:texture];
            self.texturedModel = model;
        } else {
            fatal_error(@"Model I/O doesn't support obj?");
        }
    }
    
    return self;
}

- (MDLVertexDescriptor *_Nonnull)getVertexDescriptor
{
    MDLVertexDescriptor *descriptor = [MDLVertexDescriptor new];
    
    descriptor.attributes[0].name = MDLVertexAttributePosition;
    descriptor.attributes[0].format = MDLVertexFormatFloat3;
    descriptor.attributes[0].offset = 0;
    descriptor.attributes[0].bufferIndex = 0;
    
    NSUInteger size = sizeof(float) * 3;
    descriptor.layouts[0].stride = size;
    
    descriptor.attributes[1].name = MDLVertexAttributeNormal;
    descriptor.attributes[1].format = MDLVertexFormatFloat3;
    descriptor.attributes[1].offset = 0;
    descriptor.attributes[1].bufferIndex = 1;
    
    size = sizeof(float) * 3 ;
    descriptor.layouts[1].stride = size;
    
    descriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
    descriptor.attributes[2].format = MDLVertexFormatHalf2;
    descriptor.attributes[2].offset = 0;
    descriptor.attributes[2].bufferIndex = 2;
    
    size = sizeof(float);
    descriptor.layouts[2].stride = size;
    
    return descriptor;
}

- (void)reportFatalError:(nonnull NSString *)error NO_RETURN
{
    NSAssert(NO, @"%@", error);
    abort();
}

@end
