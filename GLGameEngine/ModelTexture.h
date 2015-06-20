//
//  ModelTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

@interface ModelTexture : NSObject

@property (assign, nonatomic, readonly) GLuint textureID;
@property (assign, nonatomic, readonly) GLenum textureTarget;

- (instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget;

@end
