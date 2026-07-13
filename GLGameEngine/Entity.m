//
//  Entity.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Entity.h"

@interface Entity ()

@end

@implementation Entity {
    // The transformation matrix is read up to three times per frame (once per
    // render pass) for ~1000 static entities, so it is cached and only rebuilt
    // when position/rotation/scale change.
    simd_float4x4 _cachedTransformationMatrix;
    BOOL _transformationMatrixDirty;
}

#pragma mark - Initializer
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation scale:(float)scale andTextureIndex:(uint32_t)index
{
    return [[Entity alloc] initWithTexturedModel:model position:position rotation:rotation scale:scale andTextureIndex:index];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation andScale:(float)scale
{
    return [[Entity alloc] initWithTexturedModel:model position:position rotation:rotation andScale:scale];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(float)scale
{
    return [[Entity alloc] initWithTexturedModel:model rotation:rotation andScale:scale];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation
{
    return [[Entity alloc] initWithTexturedModel:model andRotation:rotation];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model
{
    return [[Entity alloc] initWithTexturedModel:model];
}

- (instancetype)init
{
    return [self initWithTexturedModel:nil];
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation scale:(float)scale andTextureIndex:(uint32_t)index
{
    if ((self = [super init])) {
        _model = model;
        _position = position;
        _rotation = rotation;
        _scale = scale;
        _textureIndex = index;
        _transformationMatrixDirty = YES;
    }
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model position:(simd_float3)position rotation:(Rotation)rotation andScale:(float)scale
{
    self = [self initWithTexturedModel:model position:position rotation:rotation scale:scale andTextureIndex:0];
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(float)scale
{
    self = [self initWithTexturedModel:model position:simd_make_float3(0, 0, 0) rotation:rotation scale:scale andTextureIndex:0];
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation
{
    self = [self initWithTexturedModel:model position:simd_make_float3(0, 0, 0) rotation:rotation scale:1.0 andTextureIndex:0];
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model
{
    self = [self initWithTexturedModel:model position:simd_make_float3(0, 0, 0) rotation:MathUtils_ZeroRotation scale:1.0 andTextureIndex:0];
    
    return self;
}

#pragma mark - Mutation (every path must invalidate the cached matrix)
- (void)setPosition:(simd_float3)position
{
    _position = position;
    _transformationMatrixDirty = YES;
}

- (void)setRotation:(Rotation)rotation
{
    _rotation = rotation;
    _transformationMatrixDirty = YES;
}

- (void)setScale:(float)scale
{
    _scale = scale;
    _transformationMatrixDirty = YES;
}

- (void)increasePositionByVector:(simd_float3)vec
{
    self.position = self.position + vec;
}

- (void)increaseRotationByX:(float)x y:(float)y andZ:(float)z
{
    self.rotation = MathUtils_RotationMake(_rotation.x + x, _rotation.y + y, _rotation.z + z);
}

- (void)increaseRotationByRotation:(Rotation)rot
{
    [self increaseRotationByX:rot.x y:rot.y andZ:rot.z];
}

- (void)setRotationX:(float)x y:(float)y andZ:(float)z
{
    self.rotation = MathUtils_RotationMake(x, y, z);
}

- (simd_float4x4)getCurrentTransformationMatrix
{
    if (_transformationMatrixDirty) {
        _cachedTransformationMatrix = MathUtils_CreateTransformationMatrixr(self.position, self.rotation, self.scale);
        _transformationMatrixDirty = NO;
    }

    return _cachedTransformationMatrix;
}

- (float)getTextureXOffset
{
    int32_t column = self.textureIndex % self.model.texture.numberOfRows;
    return (float)column / (float)self.model.texture.numberOfRows;
}

- (float)getTextureYOffset
{
    int32_t row = self.textureIndex / self.model.texture.numberOfRows;
    return (float)row / self.model.texture.numberOfRows;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p, position: { x: %f, y: %f, z: %f }>",
                                      NSStringFromClass([self class]),
                                      self,
                                      self.position.x,
                                      self.position.y,
                                      self.position.z];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    Entity *newEntity = [Entity entityWithTexturedModel:[self.model copyWithZone:zone]
                                               position:self.position
                                               rotation:self.rotation
                                               andScale:self.scale];
    
    return newEntity;
}

@end
