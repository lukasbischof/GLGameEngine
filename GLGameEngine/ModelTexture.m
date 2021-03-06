//
//  ModelTexture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ModelTexture.h"

@implementation ModelTexture

- (instancetype)init
{
    return [self initWithTextureID:0 andTextureTarget:GL_INVALID_ENUM];
}

- (instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget
{
    if ((self = [super initWithTextureID:textureID andTextureTarget:textureTarget])) {
        _numberOfRows = 1;
        _shineDamper = 45.0;
        _reflectivity = 0.0;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ModelTexture *copy = [[ModelTexture alloc] initWithTextureID:self.textureID andTextureTarget:self.textureTarget];
    
    copy.shineDamper = self.shineDamper;
    copy.reflectivity = self.reflectivity;
    copy.hasAlpha = self.hasAlpha;
    copy.numberOfRows = self.numberOfRows;
    
    return copy;
}

@end
