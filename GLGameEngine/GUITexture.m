
//
//  GUITexture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUITexture.h"
#import "NSObject+class.h"

@implementation GUITexture

+ (GUITexture *)textureWithTexInfo:(GLKTextureInfo *)info position:(GLKVector2)position andScale:(GLKVector2)scale
{
    return [[GUITexture alloc] initWithTexInfo:info position:position andScale:scale];
}

+ (GUITexture *)textureWithTextureID:(GLuint)textureID textureTarget:(GLenum)textureTarget position:(GLKVector2)position andScale:(GLKVector2)scale
{
    return [[GUITexture alloc] initWithTextureID:textureID
                                   textureTarget:textureTarget
                                        position:position
                                        andScale:scale];
}

- (instancetype)init
{
    return [self initWithTexInfo:nil position:GLKVector2Make(0, 0) andScale:GLKVector2Make(0, 0)];
}

- (instancetype)initWithTextureID:(GLuint)textureID textureTarget:(GLenum)textureTarget position:(GLKVector2)position andScale:(GLKVector2)scale
{
    if ((self = [super initWithTextureID:textureID andTextureTarget:textureTarget])) {
        self.position = position;
        self.scale = scale;
    }
    
    return self;
}

- (instancetype)initWithTexInfo:(GLKTextureInfo *)info position:(GLKVector2)position andScale:(GLKVector2)scale
{
    if ((self = [self initWithTextureID:info.name textureTarget:info.target position:position andScale:scale])) {
        
    }
    
    return self;
}

@end
