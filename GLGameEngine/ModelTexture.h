//
//  ModelTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture.h"

@interface ModelTexture : Texture <NSCopying>

@property (assign, nonatomic) BOOL hasAlpha;
@property (assign, nonatomic) GLuint numberOfRows; // For texture atlases
@property (assign, nonatomic) float shineDamper;
@property (assign, nonatomic) float reflectivity;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget NS_DESIGNATED_INITIALIZER;

@end
