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
    if ((self = [self initWithPosition:simd_make_float3(0, 0, 0)
                                 color:simd_make_float3(1, 1, 1)
                        andAttenuation:simd_make_float3(1.0, 0.0, 0.0)])) {
        
    }
    
    return self;
}

+ (Light *)light
{
    return [[Light alloc] init];
}

+ (Light *)lightWithPosition:(simd_float3)position color:(simd_float3)color andAttenuation:(simd_float3)attenuation
{
    return [[Light alloc] initWithPosition:position color:color andAttenuation:attenuation];
}

+ (Light *)lightWithPosition:(simd_float3)position andColor:(simd_float3)color
{
    return [[Light alloc] initWithPosition:position color:color andAttenuation:simd_make_float3(1.0, 0.0, 0.0)];
}

- (instancetype)initWithPosition:(simd_float3)position color:(simd_float3)color andAttenuation:(simd_float3)attenuation
{
    if ((self = [super init])) {
        self.position = position;
        self.color = color;
        self.attenuation = attenuation;
    }
    
    return self;
}

@end
