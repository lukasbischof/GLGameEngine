//
//  GameView.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 31.07.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GameView.h"
#import <OpenGL/gl3.h>
#import <GLKit/GLKit.h>
#import "Loader.h"
#import "Renderer.h"
#import "StaticShaderProgram.h"
#import "Entity.h"
#import "OBJLoader.h"
#import "OBJLoader2.h"
#import "Camera.h"

#define _ACTIVATE_SHADER_ [self.shader activate];
#define _DEACTIVATE_SHADER_ [self.shader deactivate];


@interface GameView () {
    CVDisplayLinkRef _displayLink;
}

@property (strong, nonatomic) Loader *loader;
@property (strong, nonatomic) Renderer *renderer;
@property (strong, nonatomic) Entity *entity;
@property (strong, nonatomic) StaticShaderProgram *shader;
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) Light *light;

@end

@implementation GameView

#pragma mark - CVDisplayLink
- (void)prepareOpenGL
{
    const NSOpenGLPixelFormatAttribute attribs[] = {};
    NSOpenGLPixelFormat *pixForm = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    [self setPixelFormat:pixForm];
    
    CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    CVDisplayLinkSetOutputCallback(_displayLink, &cvcallback, (__bridge void *__nullable)(self));
    
    // Set the display link for the current renderer
    CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
    
    // Activate the display link
    CVDisplayLinkStart(_displayLink);
}

- (void)dealloc
{
    CVDisplayLinkRelease(_displayLink);
    
    [self.loader cleanUp];
    [self.shader cleanUp];
}

static CVReturn cvcallback(CVDisplayLinkRef displayLink,
                           const CVTimeStamp* now,
                           const CVTimeStamp* outputTime,
                           CVOptionFlags flagsIn,
                           CVOptionFlags* flagsOut,
                           void* displayLinkContext)
{
    CVReturn ret = [(__bridge GameView *)displayLinkContext drawFrameForTime:outputTime];
    return ret;
}

#pragma mark - GL
- (void)initGLObjects
{
    self.loader = [Loader loader];
    self.shader = [StaticShaderProgram staticShaderProgram];
    self.renderer = [Renderer rendererWithShaderProgram:self.shader];
    self.camera = [Camera camera];
    self.light = [Light light];
    
    GLKTextureInfo *texInfo = [[self loader] loadTexture:@"white" withExtension:@"png"];
    ModelTexture *texture = [[ModelTexture alloc] initWithTextureID:texInfo.name andTextureTarget:texInfo.target];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"dragon" withExtension:@"obj"];
    TexturedModel *texturedModel = [[OBJLoader2 alloc] initWithURL:modelURL
                                                           texture:texture
                                                         andLoader:self.loader].texturedModel;
    
    GLKVector3 position = GLKVector3Make(0.0, 0.0, -20.0);
    self.entity = [Entity entityWithTexturedModel:texturedModel
                                         position:position
                                         rotation:MathUtils_RotationMake(0.0, 0.0, 0.0)
                                         andScale:1.5];
    
    self.entity.model.texture.shineDamper = 30;
    self.entity.model.texture.reflectivity = 1;
    self.light.position = GLKVector3Make(0.0, -2.0, 0.0);
}

- (void)reshape
{
    NSLog(@"reshape");
    
    [self.renderer updateProjectionWithAspect:self.frame.size.width / self.frame.size.height forShader:self.shader];
}

- (CVReturn)drawFrameForTime:(const CVTimeStamp *)time
{
    [self.renderer prepare];
    
    _ACTIVATE_SHADER_
    {
        
        [self.shader loadLight:self.light];
        [self.shader loadNormalMatrixWithModelMatrix:[self.entity getCurrentTransformationMatrix]
                                       andViewMatrix:[self.camera getViewMatrix]];
        [self.shader loadViewMatrix:[self.camera getViewMatrix]];
        [self.renderer render:self.entity withShaderProgram:self.shader];
    }
    _DEACTIVATE_SHADER_
    
    return kCVReturnSuccess;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
