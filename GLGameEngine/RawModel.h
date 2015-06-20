//
//  RawModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/gltypes.h>

@interface RawModel : NSObject

@property (assign, nonatomic, readonly) GLuint vaoID;
@property (assign, nonatomic) GLuint vertexCount;

+ (RawModel *)modelByCreatingVAOWithVertexCount:(GLuint)vertexCount;
- (instancetype)initWithVAOID:(GLuint)vaoID andVertexCount:(GLuint)vertexCount;

- (void)bindVAO;
- (void)unbindVAO;

@end
