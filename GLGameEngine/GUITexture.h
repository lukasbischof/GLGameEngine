//
//  GUITexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "Texture.h"

@interface GUITexture : Texture

@property (assign, nonatomic) simd_float2 position;
@property (assign, nonatomic) simd_float2 scale;

+ (GUITexture *)textureWithMTLTexture:(id<MTLTexture>)texture position:(simd_float2)position andScale:(simd_float2)scale;

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture position:(simd_float2)position andScale:(simd_float2)scale NS_DESIGNATED_INITIALIZER;

@end
