//
//  InstanceableTexturedModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <simd/simd.h>
#import "TexturedModel.h"

@interface InstanceableTexturedModel : TexturedModel

@property (assign, nonatomic, readonly) uint32_t instanceCount;

- (void)updateTransformationMatrix:(simd_float4x4)matrix forInstance:(uint32_t)instanceID;
- (void)lock;
- (void)bake;

@end
