//
//  Light.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Light.h"

@implementation Light

+ (Light *)light
{
    return [Light new];
}

+ (Light *)lightWithPosition:(GLKVector3)position andColor:(GLKVector3)color
{
    return [[Light alloc] initWithPosition:position andColor:color];
}

- (instancetype)initWithPosition:(GLKVector3)position andColor:(GLKVector3)color
{
    if ((self = [super init])) {
        self.position = position;
        self.color = color;
    }
    
    return self;
}

@end
