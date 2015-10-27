//
//  TerrainTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

@interface TerrainTexture : NSObject

@property (assign, nonatomic) GLuint textureID;
@property (assign, nonatomic) GLenum textureTarget;

- (instancetype)initWithID:(GLuint)textureID andTarget:(GLenum)target enableTiling:(BOOL)enableTiling NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTexInfo:(GLKTextureInfo *)texInfo;
- (instancetype)initWithTexInfo:(GLKTextureInfo *)texInfo andTiling:(BOOL)enableTiling;

@end
