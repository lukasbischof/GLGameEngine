//
//  RawModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

#define RAW_MODEL_MAX_VERTEX_BUFFERS 4

/*!
 @class RawModel
 @brief Geometry container: holds the vertex buffers (one per attribute,
        slots 0-3) and the index buffer. For indexed models, vertexCount
        stores the index count.
*/
@interface RawModel : NSObject <NSCopying>

@property (assign, nonatomic) uint32_t vertexCount;

@property (strong, nonatomic, nullable) id<MTLBuffer> indexBuffer;
@property (assign, nonatomic) NSUInteger indexBufferOffset;
@property (assign, nonatomic) MTLIndexType indexType;

+ (RawModel *_Nonnull)modelWithVertexCount:(uint32_t)vertexCount;
- (_Nonnull instancetype)initWithVertexCount:(uint32_t)vertexCount NS_DESIGNATED_INITIALIZER;

- (void)setVertexBuffer:(id<MTLBuffer> _Nonnull)buffer offset:(NSUInteger)offset atIndex:(NSUInteger)index;

// Sets all vertex buffers on the current render command encoder
- (void)bindBuffersToEncoder;

@end
