//
//  WaterFrameBuffers.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 08.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterFrameBuffers.h"
#import <UIKit/UIKit.h>

static const GLint REFLECTION_WIDTH = 512;
static const GLint REFLECTION_HEIGHT = 512;

static const GLint REFRACTION_WIDTH = 512;
static const GLint REFRACTION_HEIGHT = 512;

@implementation WaterFrameBuffers {
    GLuint _reflectionFrameBuffer,
    _reflectionDepthBuffer,
    _refractionFrameBuffer,
    _refractionDepthBuffer;
}

+ (WaterFrameBuffers *)frameBuffers
{
    return [[WaterFrameBuffers alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self initReflectionFrameBuffer];
        [self initRefractionFrameBuffer];
    }
    
    return self;
}

- (void)initReflectionFrameBuffer
{
    _reflectionFrameBuffer = [self createFrameBuffer];
    self.reflectionTexture = [self createTextureAttachmentWithWidth:REFLECTION_HEIGHT andHeight:REFLECTION_HEIGHT];
    _reflectionDepthBuffer = [self createDepthBufferAttachmentWithWidth:REFLECTION_WIDTH andHeight:REFLECTION_HEIGHT];
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Can't init reflection frame buffer: %d", err);
    }
    
    [self unbindCurrentFrameBuffer];
    
}

- (void)initRefractionFrameBuffer
{
    _refractionFrameBuffer = [self createFrameBuffer];
    _refractionTexture = [self createTextureAttachmentWithWidth:REFRACTION_WIDTH andHeight:REFRACTION_HEIGHT];
    _refractionDepthTexture = [self createDepthTextureAttachmentWithWidth:REFRACTION_WIDTH andHeight:REFRACTION_HEIGHT];
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Can't init refraction frame buffer: %d", err);
    }
    
    [self unbindCurrentFrameBuffer];
}

- (void)bindReflectionFrameBuffer
{
    [self bindFramebuffer:_reflectionFrameBuffer withWidth:REFLECTION_WIDTH andHeight:REFLECTION_HEIGHT];
}

- (void)bindRefractionFrameBuffer
{
    [self bindFramebuffer:_refractionFrameBuffer withWidth:REFRACTION_WIDTH andHeight:REFRACTION_HEIGHT];
}

- (void)unbindCurrentFrameBuffer
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, size.width, size.height);
}

- (void)bindFramebuffer:(GLuint)framebuffer withWidth:(GLsizei)width andHeight:(GLsizei)height
{
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glViewport(0, 0, width, height);
}

- (GLuint)createTextureAttachmentWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    
    return texture;
}

- (GLuint)createDepthTextureAttachmentWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32F, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texture, 0);
    
    return texture;
}

- (GLuint)createDepthBufferAttachmentWithWidth:(GLsizei)width andHeight:(GLsizei)height
{
    GLuint depthBuffer;
    glGenRenderbuffers(1, &depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
    
    return depthBuffer;
}

- (GLuint)createFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    GLenum buf = GL_COLOR_ATTACHMENT0;
    glDrawBuffers(1, &buf);
    
    return framebuffer;
}

- (void)cleanUp
{
    glDeleteFramebuffers(1, &_refractionFrameBuffer);
    glDeleteFramebuffers(1, &_reflectionFrameBuffer);
    glDeleteTextures(1, &_reflectionTexture);
    glDeleteTextures(1, &_refractionTexture);
    glDeleteTextures(1, &_refractionDepthTexture);
    glDeleteRenderbuffers(1, &_reflectionDepthBuffer);
}

@end

