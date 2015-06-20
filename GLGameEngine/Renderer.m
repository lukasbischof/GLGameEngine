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
        [self setupProperties];
        [self createProjectionMatrix];
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
}

#pragma mark - Rendering
- (void)prepare
{
    glEnable(GL_DEPTH_TEST);
    glClearColor(self.clearColor.r, self.clearColor.g, self.clearColor.b, self.clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
}

- (void)render:(Entity *)entity withShaderProgram:(StaticShaderProgram *)shader
{
    TexturedModel *texturedModel = entity.model;
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    
    [shader loadTransformationMatrix:[entity getCurrentTransformationMatrix]];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(texturedModel.texture.textureTarget, texturedModel.texture.textureID);
    glDrawElements(GL_TRIANGLES, model.vertexCount, GL_UNSIGNED_INT, 0);
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    
    [model unbindVAO];
}

#pragma mark - private methods
- (void)createProjectionMatrix
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    float aspect = size.width / size.height;
    _projectionMatrix = GLKMatrix4MakePerspective(MathUtils_DegToRad(FOVY), aspect, NEARZ, FARZ);
}

@end
