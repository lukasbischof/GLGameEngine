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

@implementation Entity

#pragma mark - Initializer
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation scale:(GLfloat)scale andTextureIndex:(GLuint)index
{
    return [[Entity alloc] initWithTexturedModel:model position:position rotation:rotation scale:scale andTextureIndex:index];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation andScale:(GLfloat)scale
{
    return [[Entity alloc] initWithTexturedModel:model position:position rotation:rotation andScale:scale];
}

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(GLfloat)scale
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

- (instancetype)initWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation scale:(GLfloat)scale andTextureIndex:(GLuint)index
{
    if ((self = [super init])) {
        _model = model;
        _position = position;
        _rotation = rotation;
        _scale = scale;
        _textureIndex = index;
    }
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation andScale:(GLfloat)scale
{
    self = [self initWithTexturedModel:model position:position rotation:rotation scale:scale andTextureIndex:0];
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(GLfloat)scale
{
    self = [self initWithTexturedModel:model position:GLKVector3Make(0, 0, 0) rotation:rotation scale:scale andTextureIndex:0];
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation
{
    self = [self initWithTexturedModel:model position:GLKVector3Make(0, 0, 0) rotation:rotation scale:1.0 andTextureIndex:0];
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model
{
    self = [self initWithTexturedModel:model position:GLKVector3Make(0, 0, 0) rotation:MathUtils_ZeroRotation scale:1.0 andTextureIndex:0];
    
    return self;
}

#pragma mark - Methods
- (void)increasePositionByVector:(GLKVector3)vec
{
    self.position = GLKVector3Add(self.position, vec);
}

- (void)increaseRotationByX:(GLfloat)x y:(GLfloat)y andZ:(GLfloat)z
{
    _rotation = MathUtils_RotationMake(_rotation.x + x, _rotation.y + y, _rotation.z + z);
}

- (void)increaseRotationByRotation:(Rotation)rot
{
    [self increaseRotationByX:rot.x y:rot.y andZ:rot.z];
}

- (void)setRotationX:(GLfloat)x y:(GLfloat)y andZ:(GLfloat)z
{
    _rotation = MathUtils_RotationMake(x, y, z);
}

- (GLKMatrix4)getCurrentTransformationMatrix
{
    GLKMatrix4 mat = MathUtils_CreateTransformationMatrixr(self.position, self.rotation, self.scale);
    return mat;
}

- (GLfloat)getTextureXOffset
{
    GLint column = self.textureIndex % self.model.texture.numberOfRows;
    return (GLfloat)column / (GLfloat)self.model.texture.numberOfRows;
}

- (GLfloat)getTextureYOffset
{
    GLint row = self.textureIndex / self.model.texture.numberOfRows;
    return (GLfloat)row / self.model.texture.numberOfRows;
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
