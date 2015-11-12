//
//  Texture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 06.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "Texture.h"

@implementation Texture

- (instancetype)init
{
    self = [self initWithTextureID:0 andTextureTarget:GL_INVALID_ENUM];
    return self;
}

- (instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget
{
    if ((self = [super init])) {
        _textureID = textureID;
        _textureTarget = textureTarget;
    }
    
    return self;
}

- (instancetype)initWithTextureInfo:(GLKTextureInfo *__nonnull)info
{
    if ((self = [self initWithTextureID:info.name andTextureTarget:info.target])) {
        
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Texture *newTex = [[Texture alloc] initWithTextureID:self.textureID andTextureTarget:self.textureTarget];
    
    return newTex;
}

@end
