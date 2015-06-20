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

- (instancetype)initWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation andScale:(GLfloat)scale
{
    if ((self = [super init])) {
        _model = model;
        _position = position;
        _rotation = rotation;
        _scale = scale;
    }
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(GLfloat)scale
{
    if ((self = [super init])) {
        _model = model;
        self.position = GLKVector3Make(0.0f, 0.0f, 0.0f);
        self.rotation = rotation;
        self.scale = scale;
    }
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation
{
    if ((self = [super init])) {
        _model = model;
        self.position = GLKVector3Make(0.0f, 0.0f, 0.0f);
        self.rotation = rotation;
        self.scale = 1.0f;
    }
    
    return self;
}

- (instancetype)initWithTexturedModel:(TexturedModel *)model
{
    if ((self = [super init])) {
        _model = model;
        self.position = GLKVector3Make(0.0f, 0.0f, 0.0f);
        self.rotation = MathUtils_ZeroRotation;
        self.scale = 1.f;
    }
    
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

- (GLKMatrix4)getCurrentTransformationMatrix
{
    GLKMatrix4 mat = MathUtils_CreateTransformationMatrixr(self.position, self.rotation, self.scale);
    return mat;
}

@end
