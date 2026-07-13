//
//  TerrainTexture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainTexture.h"

@implementation TerrainTexture

- (instancetype)init
{
    if ((self = [self initWithMTLTexture:nil enableTiling:NO])) {

    }

    return self;
}

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture enableTiling:(BOOL)enableTiling
{
    if ((self = [super initWithMTLTexture:texture])) {
        // Tiling (repeat address mode) is part of the sampler state; the
        // terrain sampler repeats, so there is nothing to configure here.
    }

    return self;
}

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture
{
    self = [self initWithMTLTexture:texture enableTiling:YES];

    return self;
}

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture andTiling:(BOOL)enableTiling
{
    self = [self initWithMTLTexture:texture enableTiling:enableTiling];

    return self;
}

@end
