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

@interface Entity : NSObject

@property (strong, nonatomic, readonly) TexturedModel *model;
@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) Rotation rotation;
@property (assign, nonatomic) GLfloat scale;
@property (assign, nonatomic, readonly, getter=getCurrentTransformationMatrix) GLKMatrix4 currentTransformationMatrix;

/// TEMPORARY
#warning remove this soon
@property (assign, nonatomic) float rotationSpeed;

// Initializer
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                             position:(GLKVector3)position
                             rotation:(Rotation)rotation
                             andScale:(GLfloat)scale NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                             rotation:(Rotation)rotation
                             andScale:(GLfloat)scale NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexturedModel:(TexturedModel *)model
                          andRotation:(Rotation)rotation NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexturedModel:(TexturedModel *)model NS_DESIGNATED_INITIALIZER;

+ (Entity *)entityWithTexturedModel:(TexturedModel *)model position:(GLKVector3)position rotation:(Rotation)rotation andScale:(GLfloat)scale;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model rotation:(Rotation)rotation andScale:(GLfloat)scale;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model andRotation:(Rotation)rotation;
+ (Entity *)entityWithTexturedModel:(TexturedModel *)model;


- (void)increasePositionByVector:(GLKVector3)vec;
- (void)increaseRotationByRotation:(Rotation)rot;
- (void)increaseRotationByX:(GLfloat)x y:(GLfloat)y andZ:(GLfloat)z;
- (void)setRotationX:(GLfloat)x y:(GLfloat)y andZ:(GLfloat)z;

@end
