//
//  InstanceableTexturedModel.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "InstanceableTexturedModel.h"
#import "MetalContext.h"
#import "ShaderTypes.h"
#include <vector>
#include <stdio.h>
#include <iostream>

@implementation InstanceableTexturedModel {
    std::vector<simd_float4x4> _matrices;
    id<MTLBuffer> _buffer;
}

- (instancetype)initWithRawModel:(RawModel *)rawModel andTexture:(ModelTexture *)texture
{
    if ((self = [super initWithRawModel:rawModel andTexture:texture])) {
        _instanceCount = 0;
        self->_matrices = std::vector<simd_float4x4>();
    }

    return self;
}

- (void)updateTransformationMatrix:(simd_float4x4)matrix forInstance:(uint32_t)instanceID
{
    if (instanceID == self->_matrices.size()) {
        // add
        self->_matrices.push_back(matrix);
        _instanceCount++;
    } else if (instanceID > self->_matrices.size()) {
        std::cerr << "Invalid instance id " << instanceID << std::endl;
    } else {
        // update
        self->_matrices[instanceID] = matrix;
    }
}

- (void)lock
{
    if (self.instanceCount == 0) {
        NSLog(@"No Instances created!");
        return;
    }

    // The per-instance layout (mat4 = attributes 3-6, stepFunction perInstance)
    // is part of the instancing pipeline's vertex descriptor; only the buffer
    // itself needs to be created here.
    [self bake];
}

- (void)bake
{
    _buffer = [[MetalContext sharedContext].device newBufferWithBytes:self->_matrices.data()
                                                               length:sizeof(simd_float4x4) * self->_matrices.size()
                                                              options:MTLResourceStorageModeShared];

    [self.rawModel setVertexBuffer:_buffer offset:0 atIndex:BufferIndexInstanceMatrices];
}

@end
