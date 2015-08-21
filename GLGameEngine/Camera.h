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

/**
 @property position
 @abstract The position of the camera.
 */
@property (assign, nonatomic) GLKVector3 position;

/**
 @property yaw
 @abstract The yaw (rotation around the Y-axis) of the camera. In degrees
*/
@property (assign, nonatomic) GLfloat yaw;

/**
 @property pitch
 @abstract The pitch (rotation around the X-axis) of the camera. In degrees
 */
@property (assign, nonatomic) GLfloat pitch;

/**
 @property roll
 @abstract The roll (rotation around the Z-axis) of the camera. In degrees
 */
@property (assign, nonatomic) GLfloat roll;
@property (assign, nonatomic, readonly, getter=getViewMatrix) GLKMatrix4 viewMatrix;

+ (Camera *)camera;

- (void)move:(GLKVector3)vec;

@end
