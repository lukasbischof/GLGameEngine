//
//  Camera.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif
#import <GLKit/GLKit.h>
#import "MathUtils.h"

@interface Camera : NSObject

@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) GLfloat yaw;
@property (assign, nonatomic) GLfloat pitch;
@property (assign, nonatomic) GLfloat roll;
@property (assign, nonatomic, readonly, getter=getViewMatrix) GLKMatrix4 viewMatrix;

+ (Camera *)camera;

- (void)move:(GLKVector3)vec;

@end
