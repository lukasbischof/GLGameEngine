//
//  RawModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

@interface RawModel : NSObject

@property (assign, nonatomic, readonly) GLuint vaoID;
@property (assign, nonatomic) GLuint vertexCount;

+ (RawModel *)modelByCreatingVAOWithVertexCount:(GLuint)vertexCount;
- (instancetype)initWithVAOID:(GLuint)vaoID andVertexCount:(GLuint)vertexCount NS_DESIGNATED_INITIALIZER;

- (void)bindVAO;
- (void)unbindVAO;

@end
