//
//  RawModel.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "RawModel.h"
#import "MetalContext.h"

@implementation RawModel {
    id<MTLBuffer> _vertexBuffers[RAW_MODEL_MAX_VERTEX_BUFFERS];
    NSUInteger _vertexBufferOffsets[RAW_MODEL_MAX_VERTEX_BUFFERS];
}

+ (RawModel *)modelWithVertexCount:(uint32_t)vertexCount
{
    return [[RawModel alloc] initWithVertexCount:vertexCount];
}

- (instancetype)init
{
    return [self initWithVertexCount:0];
}

- (instancetype)initWithVertexCount:(uint32_t)vertexCount
{
    if ((self = [super init])) {
        self.vertexCount = vertexCount;
        self.indexType = MTLIndexTypeUInt32;
    }

    return self;
}

- (void)setVertexBuffer:(id<MTLBuffer>)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index
{
    NSAssert(index < RAW_MODEL_MAX_VERTEX_BUFFERS, @"vertex buffer index out of range");

    _vertexBuffers[index] = buffer;
    _vertexBufferOffsets[index] = offset;
}

- (void)bindVAO
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    for (NSUInteger i = 0; i < RAW_MODEL_MAX_VERTEX_BUFFERS; i++) {
        if (_vertexBuffers[i]) {
            [encoder setVertexBuffer:_vertexBuffers[i] offset:_vertexBufferOffsets[i] atIndex:i];
        }
    }
}

- (void)unbindVAO
{
    // glBindVertexArray(0) -- nothing to do in Metal
}

- (id)copyWithZone:(NSZone *)zone
{
    RawModel *copy = [[RawModel alloc] initWithVertexCount:self.vertexCount];

    for (NSUInteger i = 0; i < RAW_MODEL_MAX_VERTEX_BUFFERS; i++) {
        if (_vertexBuffers[i]) {
            [copy setVertexBuffer:_vertexBuffers[i] offset:_vertexBufferOffsets[i] atIndex:i];
        }
    }

    copy.indexBuffer = self.indexBuffer;
    copy.indexBufferOffset = self.indexBufferOffset;
    copy.indexType = self.indexType;

    return copy;
}

@end
