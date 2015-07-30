//
//  Renderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexturedModel.h"
#import "Entity.h"
#import "StaticShaderProgram.h"
#import "Buffer.h"

struct _RGBA {
    GLfloat r, g, b, a;
};
typedef struct _RGBA RGBA;


@interface Renderer : NSObject

@property (assign, nonatomic) RGBA clearColor;

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader;

+ (Renderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader;

/// program acitvation must be done before updating
- (void)updateProjectionWithAspect:(float)aspect forShader:(StaticShaderProgram *)shader;
- (void)prepare;
- (void)render:(Entity *)entity withShaderProgram:(StaticShaderProgram *)shader;

@end


EXPORT RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
EXPORT RGBA RGBAMakeFromRGBHex(uint32_t hex);
EXPORT GLKVector4 RGBAGetGLKVector4(RGBA rgba);
EXPORT GLKVector3 RGBAGetGLKVector3(RGBA rgba);
