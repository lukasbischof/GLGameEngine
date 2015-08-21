//
//  ModelTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

@interface ModelTexture : NSObject

@property (assign, nonatomic) float shineDamper;
@property (assign, nonatomic) float reflectivity;
@property (assign, nonatomic, readonly) GLuint textureID;
@property (assign, nonatomic, readonly) GLenum textureTarget;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTextureID:(GLuint)textureID andTextureTarget:(GLenum)textureTarget NS_DESIGNATED_INITIALIZER;

@end
