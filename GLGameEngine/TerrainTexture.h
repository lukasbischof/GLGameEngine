//
//  TerrainTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture.h"

@interface TerrainTexture : Texture

- (instancetype)initWithID:(GLuint)textureID andTarget:(GLenum)target enableTiling:(BOOL)enableTiling NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTextureInfo:(GLKTextureInfo *)texInfo andTiling:(BOOL)enableTiling;

@end
