//
//  WaterFrameBuffers.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 08.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

@interface WaterFrameBuffers : NSObject

@property (assign, nonatomic) GLuint reflectionTexture;
@property (assign, nonatomic) GLuint refractionTexture;
@property (assign, nonatomic) GLuint refractionDepthTexture;

+ (WaterFrameBuffers *)frameBuffers;

- (void)bindReflectionFrameBuffer;
- (void)bindRefractionFrameBuffer;
- (void)unbindCurrentFrameBuffer;
- (void)cleanUp;

@end
