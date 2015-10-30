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
    if ((self = [self initWithID:0 andTarget:GL_INVALID_ENUM enableTiling:NO])) {
        
    }
    
    return self;
}

- (instancetype)initWithID:(GLuint)textureID andTarget:(GLenum)target enableTiling:(BOOL)enableTiling
{
    if ((self = [super init])) {
        self.textureID = textureID;
        self.textureTarget = target;
        
        if (enableTiling) {
            glBindTexture(target, textureID);
            // glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            // glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
    }
    
    return self;
}

- (instancetype)initWithTexInfo:(GLKTextureInfo *)texInfo
{
    self = [self initWithID:texInfo.name andTarget:texInfo.target enableTiling:YES];
    
    return self;
}

- (instancetype)initWithTexInfo:(GLKTextureInfo *)texInfo andTiling:(BOOL)enableTiling
{
    self = [self initWithID:texInfo.name andTarget:texInfo.target enableTiling:enableTiling];
    
    return self;
}

@end
