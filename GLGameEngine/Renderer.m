//
//  Renderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Renderer.h"

// Field of View in degrees
static const GLfloat FOVY = 45;
static const GLfloat NEARZ = 0.1;
static const GLfloat FARZ = 100;

@interface Renderer ()

@property (assign, nonatomic) GLKMatrix4 projectionMatrix;

@end

@implementation Renderer

#pragma mark - Initialization
- (instancetype)init
{
    if ((self = [super init])) {
        [self setupProperties];
    }
    
    return self;
}

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader
{
    if ((self = [super init])) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        float aspect = size.width / size.height;
        
        [self setupProperties];
        [self createProjectionMatrixWithAspect:aspect];
        [shader activate];
        [shader loadProjectionMatrix:_projectionMatrix];
        [shader deactivate];
    }
    
    return self;
}

+ (Renderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader
{
    return [[Renderer alloc] initWithShaderProgram:shader];
}

- (void)setupProperties
{
    self.clearColor = RGBAMake(0.0, 0.0, 0.0, 0.0);
    
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);
}

- (void)updateProjectionWithAspect:(float)aspect forShader:(StaticShaderProgram *)shader
{
    [self createProjectionMatrixWithAspect:aspect];
    [shader loadProjectionMatrix:_projectionMatrix];
}

#pragma mark - Rendering
- (void)prepare
{
    glClearColor(self.clearColor.r, self.clearColor.g, self.clearColor.b, self.clearColor.a);
    glClearDepthf(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);
}

- (void)render:(Entity *)entity withShaderProgram:(StaticShaderProgram *)shader
{
    TexturedModel *texturedModel = entity.model;
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    
    [shader loadTransformationMatrix:entity.currentTransformationMatrix];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(texturedModel.texture.textureTarget, texturedModel.texture.textureID);
    glDrawElements(GL_TRIANGLES, model.vertexCount, GL_UNSIGNED_INT, 0);
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    
    [model unbindVAO];
}

#pragma mark - private methods
- (void)createProjectionMatrixWithAspect:(float)aspect
{
    _projectionMatrix = GLKMatrix4MakePerspective(MathUtils_DegToRad(FOVY), aspect, NEARZ, FARZ);
}

@end



EXPORT RGBA RGBAMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
    return (RGBA) {
        MAX(0., MIN(red, 1.)),
        MAX(0., MIN(green, 1.)),
        MAX(0., MIN(blue, 1.)),
        MAX(0., MIN(alpha, 1.)),
    };
}

EXPORT RGBA RGBAMakeFromRGBHex(uint32_t hex) {
    // 0x FF   AA   88
    //   red green blue
    
    return (RGBA) {
        (hex >> 16) / 255,
        ((hex >> 8) & 0x00FF) / 255,
        (hex & 0x0000FF) / 255,
        1.0
    };
}

EXPORT GLKVector4 RGBAGetGLKVector4(RGBA rgba) {
    return GLKVector4Make(rgba.r, rgba.g, rgba.b, rgba.a);
}

EXPORT GLKVector3 RGBAGetGLKVector3(RGBA rgba) {
    return GLKVector3Make(rgba.r, rgba.g, rgba.b);
}

