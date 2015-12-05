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
@property (assign, nonnull) InstancingShaderProgram *instancingShaderProgram;

@end

@implementation EntityRenderer

#pragma mark - Initialization
- (instancetype)init
{
    if ((self = [super init])) {

    }
    
    return self;
}

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader andInstancingShaderProgram:(InstancingShaderProgram *)instancingShader
{
    if ((self = [super init])) {
        self.shaderProgram = shader;
        self.instancingShaderProgram = instancingShader;
    }
    
    return self;
}

+ (EntityRenderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader andInstancingShaderProgram:(InstancingShaderProgram *)instancingShader
{
    return [[EntityRenderer alloc] initWithShaderProgram:shader andInstancingShaderProgram:instancingShader];
}

#pragma mark - Rendering
#pragma mark Master-Rendering
- (void)renderInstances:(NSMutableArray<InstanceableTexturedModel *> *)models withCamera:(Camera *)camera
{
    GLKMatrix4 viewMat = camera.viewMatrix;
    
    for (InstanceableTexturedModel *model in models) {
        [self prepareTexturedModel:model instancingEnabled:YES];
        
        glPushGroupMarkerEXT(0, "Draw Instanced Entities");
        
        [self.instancingShaderProgram loadNormalMatrixWithModelMatrix:GLKMatrix4Identity
                                                        andViewMatrix:viewMat];
        [self.instancingShaderProgram loadOffset:GLKVector2Make(0, 0)];
        
        glDrawElementsInstanced(GL_TRIANGLES, model.rawModel.vertexCount, GL_UNSIGNED_INT, 0, model.instanceCount);
        GLenum err = glGetError();
        if (err != GL_NO_ERROR) {
            NSLog(@"instanced render error: %u", err);
        }
        
        [self unbindInstancedTexturedModel];
        
        glPopGroupMarkerEXT();
    }
    
    glBindVertexArray(0);
}

- (void)render:(NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> *)entities withCamera:(Camera *)camera
{
    [entities enumerateKeysAndObjectsUsingBlock:^(TexturedModel *_Nonnull key,
                                                  NSMutableArray<Entity *> *_Nonnull obj,
                                                  BOOL *_Nonnull stop) {
        [self prepareTexturedModel:key instancingEnabled:NO];
        
        glPushGroupMarkerEXT(0, "Draw entites");
        for (Entity *entity in obj) {
            [self prepareInstance:entity withViewMatrix:camera.viewMatrix];
            
            glPushGroupMarkerEXT(0, key.debugLabel.UTF8String);
            glDrawElements(GL_TRIANGLES, key.rawModel.vertexCount, GL_UNSIGNED_INT, 0);
            glPopGroupMarkerEXT();
            
            GLenum err = glGetError();
            if (err != GL_NO_ERROR) {
                NSLog(@"render error: %u", err);
            }
        }
        glPopGroupMarkerEXT();
        
        [self unbindTexturedModel];
    }];
}

- (void)prepareTexturedModel:(TexturedModel *)texturedModel instancingEnabled:(BOOL)instancing
{
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];
    
    /*glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);
    
    if (instancing) {
        glEnableVertexAttribArray(3);
        glEnableVertexAttribArray(4);
        glEnableVertexAttribArray(5);
        glEnableVertexAttribArray(6);
    }*/

    if (!instancing) {
        [self.shaderProgram loadNumberOfRows:texturedModel.texture.numberOfRows];
        [self.shaderProgram loadDamper:texturedModel.texture.shineDamper
                       andReflectivity:texturedModel.texture.reflectivity];
    } else {
        [self.instancingShaderProgram loadNumberOfRows:texturedModel.texture.numberOfRows];
        [self.instancingShaderProgram loadDamper:texturedModel.texture.shineDamper
                                 andReflectivity:texturedModel.texture.reflectivity];
    }
    
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
    
    /*glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);*/
}

- (void)unbindInstancedTexturedModel
{
    if (!glIsEnabled(GL_CULL_FACE)) {
        [MasterRenderer enableCulling];
    }
    
    /*glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    glDisableVertexAttribArray(3);
    glDisableVertexAttribArray(4);
    glDisableVertexAttribArray(5);
    glDisableVertexAttribArray(6);*/
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

