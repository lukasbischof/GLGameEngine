//
//  Light.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Light.h"

@implementation Light

- (instancetype)init
{
    if ((self = [self initWithPosition:GLKVector3Make(0, 0, 0)
                                 color:GLKVector3Make(1, 1, 1)
                        andAttenuation:GLKVector3Make(1.0, 0.0, 0.0)])) {
        
    }
    
    return self;
}

+ (Light *)light
{
    return [[Light alloc] init];
}

+ (Light *)lightWithPosition:(GLKVector3)position color:(GLKVector3)color andAttenuation:(GLKVector3)attenuation
{
    return [[Light alloc] initWithPosition:position color:color andAttenuation:attenuation];
}

+ (Light *)lightWithPosition:(GLKVector3)position andColor:(GLKVector3)color
{
    return [[Light alloc] initWithPosition:position color:color andAttenuation:GLKVector3Make(1.0, 0.0, 0.0)];
}

- (instancetype)initWithPosition:(GLKVector3)position color:(GLKVector3)color andAttenuation:(GLKVector3)attenuation
{
    if ((self = [super init])) {
        self.position = position;
        self.color = color;
        self.attenuation = attenuation;
    }
    
    return self;
}

@end
