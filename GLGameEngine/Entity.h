//
//  Entity.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexturedModel.h"
#import "Camera.h"
#import "MathUtils.h"

@interface Entity : NSObject <NSCopying>

@property (assign, nonatomic) uint32_t textureIndex;
@property (strong, nonatomic, readonly) TexturedModel *model;
@property (assign, nonatomic) simd_float3 position;
@property (assign, nonatomic) Rotation rotation;
@property (assign, nonatomic) float scale;
@property (assign, nonatomic, readonly, getter=getCurrentTransformationMatrix) simd_float4x4 currentTransformationMatrix;

// Initializer
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                             position:(simd_float3)position
                             rotation:(Rotation)rotation
                                scale:(float)scale
                      andTextureIndex:(uint32_t)index NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                             position:(simd_float3)position
                             rotation:(Rotation)rotation
                             andScale:(float)scale;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                             rotation:(Rotation)rotation
                             andScale:(float)scale;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                          andRotation:(Rotation)rotation;
- (instancetype)initWithTexturedModel:(TexturedModel *)model;

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation scale:(float)scale andTextureIndex:(uint32_t)index;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation andScale:(float)scale;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(float)scale;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model;


- (void)increasePositionByVector:(simd_float3)vec;
- (void)increaseRotationByRotation:(Rotation)rot;
- (void)increaseRotationByX:(float)x y:(float)y andZ:(float)z;
- (void)setRotationX:(float)x y:(float)y andZ:(float)z;

- (float)getTextureXOffset;
- (float)getTextureYOffset;

@end
