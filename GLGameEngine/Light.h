//
//  Light.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface Light : NSObject

@property (assign, nonatomic) simd_float3 position;
@property (assign, nonatomic) simd_float3 color;
@property (assign, nonatomic) simd_float3 attenuation;

+ (Light *)light;
+ (Light *)lightWithPosition:(simd_float3)position andColor:(simd_float3)color;
+ (Light *)lightWithPosition:(simd_float3)position color:(simd_float3)color andAttenuation:(simd_float3)attenuation;

- (instancetype)initWithPosition:(simd_float3)position color:(simd_float3)color andAttenuation:(simd_float3)attenuation NS_DESIGNATED_INITIALIZER;

@end
