//
//  Camera.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Camera.h"

@implementation Camera

+ (Camera *)camera
{
    return [[Camera alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.position = simd_make_float3(0., 0., 0.);
        _yaw = _pitch = _roll = 0.0f;
    }
    
    return self;
}

- (void)move:(simd_float3)vec
{
    self.position = self.position + vec;
}

- (void)invertPitch
{
    self.pitch = -self.pitch;
}

- (simd_float4x4)getViewMatrix
{
    simd_float4x4 viewMatrix = MathUtils_MatrixMakeXRotation(MathUtils_DegToRad(self.pitch));

    viewMatrix = simd_mul(viewMatrix, MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(self.yaw)));
    viewMatrix = simd_mul(viewMatrix, MathUtils_MatrixMakeZRotation(MathUtils_DegToRad(self.roll)));

    simd_float3 negCameraPosition = -self.position;
    viewMatrix = simd_mul(viewMatrix, MathUtils_MatrixMakeTranslation(negCameraPosition.x, negCameraPosition.y, negCameraPosition.z));

    return viewMatrix;
}

@end
