//
//  GUITexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture.h"

@interface GUITexture : Texture

@property (assign, nonatomic) GLKVector2 position;
@property (assign, nonatomic) GLKVector2 scale;

+ (GUITexture *)textureWithTexInfo:(GLKTextureInfo *)info position:(GLKVector2)position andScale:(GLKVector2)scale;
+ (GUITexture *)textureWithTextureID:(GLuint)textureID textureTarget:(GLenum)textureTarget position:(GLKVector2)position andScale:(GLKVector2)scale;

- (instancetype)initWithTextureID:(GLuint)textureID textureTarget:(GLenum)textureTarget position:(GLKVector2)position andScale:(GLKVector2)scale NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexInfo:(GLKTextureInfo *)info position:(GLKVector2)position andScale:(GLKVector2)scale;

@end
