//
//  Camera.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Camera.h"
#import <OpenGLES/ES3/glext.h>

@implementation Camera

+ (Camera *)camera
{
    return [[Camera alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.position = GLKVector3Make(0., 0., 0.);
        _yaw = _pitch = _roll = 0.0f;
    }
    
    return self;
}

- (void)move:(GLKVector3)vec
{
    self.position = GLKVector3Add(self.position, vec);
}

- (void)invertPitch
{
    self.pitch = -self.pitch;
}

- (GLKMatrix4)getViewMatrix
{
    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
    
    viewMatrix = GLKMatrix4Rotate(viewMatrix, MathUtils_DegToRad(self.pitch), 1, 0, 0);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, MathUtils_DegToRad(self.yaw),   0, 1, 0);
    viewMatrix = GLKMatrix4Rotate(viewMatrix, MathUtils_DegToRad(self.roll),  0, 0, 1);
    
    GLKVector3 negCameraPosition = GLKVector3Make(-self.position.x, -self.position.y, -self.position.z);
    viewMatrix = GLKMatrix4TranslateWithVector3(viewMatrix, negCameraPosition);
    
    return viewMatrix;
}

@end
