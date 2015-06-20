//
//  Renderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import "TexturedModel.h"
#import "Entity.h"
#import "StaticShaderProgram.h"

#if !defined(INLINE)
    #if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
        #define INLINE static inline
    #elif defined(__cplusplus)
        #define INLINE static inline
    #elif defined(__GNUC__)
        #define INLINE static __inline__
    #else
        #define INLINE static
    #endif
#endif

struct _RGBA {
    GLfloat r, g, b, a;
};
typedef struct _RGBA RGBA;



@interface Renderer : NSObject

@property (assign, nonatomic) RGBA clearColor;

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader;

+ (Renderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader;

- (void)prepare;
- (void)render:(Entity *)entity withShaderProgram:(StaticShaderProgram *)shader;

@end



INLINE RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
    return (RGBA) {
        MAX(0., MIN(red, 1.)),
        MAX(0., MIN(green, 1.)),
        MAX(0., MIN(blue, 1.)),
        MAX(0., MIN(alpha, 1.)),
    };
}
