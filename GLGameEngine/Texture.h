//
//  Texture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 06.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#   import <OpenGLES/ES3/gl.h>
#else
#   import <OpenGL/gl3.h>
#endif

@interface Texture : NSObject <NSCopying>

@property (assign, nonatomic, readonly) GLuint textureID;
@property (assign, nonatomic, readonly) GLenum textureTarget;

- (_Nonnull instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget;
- (_Nonnull instancetype)initWithTextureInfo:(GLKTextureInfo *_Nonnull)info;

@end
