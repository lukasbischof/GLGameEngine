//
//  Renderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "EntityRenderer.h"
#import "MasterRenderer.h"

@interface EntityRenderer ()

@property (assign, nonnull) StaticShaderProgram *shaderProgram;

@end

@implementation EntityRenderer

#pragma mark - Initialization
- (instancetype)init
{
    if ((self = [super init])) {

    }
    
    return self;
}

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader
{
    if ((self = [super init])) {
        self.shaderProgram = shader;
    }
    
    return self;
}

+ (EntityRenderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader
{
    return [[EntityRenderer alloc] initWithShaderProgram:shader];
}

#pragma mark - Rendering
#pragma mark Master-Rendering
- (void)render:(NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> *)entities withCamera:(Camera *)camera
{
    [entities enumerateKeysAndObjectsUsingBlock:^(TexturedModel *_Nonnull key,
                                                  NSMutableArray<Entity *> *_Nonnull obj,
                                                  BOOL *_Nonnull stop) {
        [self prepareTexturedModel:key];
        
        for (Entity *entity in obj) {
            [self prepareInstance:entity withViewMatrix:camera.viewMatrix];
            glDrawElements(GL_TRIANGLES, key.rawModel.vertexCount, GL_UNSIGNED_INT, 0);
            GLenum err = glGetError();
            if (err != GL_NO_ERROR) {
                NSLog(@"render error: %u", err);
            }
        }
        
        [self unbindTexturedModel];
    }];
}

- (void)prepareTexturedModel:(TexturedModel *)texturedModel
{
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);

    [self.shaderProgram loadNumberOfRows:texturedModel.texture.numberOfRows];
    [self.shaderProgram loadDamper:texturedModel.texture.shineDamper andReflectivity:texturedModel.texture.reflectivity];
    
    if (texturedModel.texture.hasAlpha && glIsEnabled(GL_CULL_FACE)) {
        [MasterRenderer disableCulling];
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(texturedModel.texture.textureTarget, texturedModel.texture.textureID);
}

- (void)unbindTexturedModel
{
    if (!glIsEnabled(GL_CULL_FACE)) {
        [MasterRenderer enableCulling];
    }
    
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
}

- (void)prepareInstance:(Entity *)entity withViewMatrix:(GLKMatrix4)viewMat
{
    [self.shaderProgram loadTransformationMatrix:entity.currentTransformationMatrix];
    [self.shaderProgram loadNormalMatrixWithModelMatrix:entity.currentTransformationMatrix
                                          andViewMatrix:viewMat];
    [self.shaderProgram loadOffset:GLKVector2Make([entity getTextureXOffset], [entity getTextureYOffset])];
}

#pragma mark Old rendering
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

@end

