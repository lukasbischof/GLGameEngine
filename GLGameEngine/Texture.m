//
//  Texture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 06.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "Texture.h"

@interface Texture ()

@property (strong, nonatomic, readwrite, nullable) id<MTLTexture> texture;

@end

@implementation Texture

- (instancetype)init
{
    self = [self initWithMTLTexture:nil];
    return self;
}

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture
{
    if ((self = [super init])) {
        _texture = texture;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Texture *newTex = [[Texture alloc] initWithMTLTexture:self.texture];

    return newTex;
}

@end
