//
//  Camera.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "MathUtils.h"

@interface Camera : NSObject

/**
 @property position
 @abstract The position of the camera.
 */
@property (assign, nonatomic) simd_float3 position;

/**
 @property yaw
 @abstract The yaw (rotation around the Y-axis) of the camera. In degrees
*/
@property (assign, nonatomic) float yaw;

/**
 @property pitch
 @abstract The pitch (rotation around the X-axis) of the camera. In degrees
 */
@property (assign, nonatomic) float pitch;

/**
 @property roll
 @abstract The roll (rotation around the Z-axis) of the camera. In degrees
 */
@property (assign, nonatomic) float roll;
@property (assign, nonatomic, readonly, getter=getViewMatrix) simd_float4x4 viewMatrix;

+ (Camera *)camera;

- (void)move:(simd_float3)vec;
- (void)invertPitch;

@end
