//
//  Renderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "EntityRenderer.h"
#import "MasterRenderer.h"
#import "MetalContext.h"

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
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;
    GLKMatrix4 viewMat = camera.viewMatrix;

    for (InstanceableTexturedModel *model in models) {
        [self prepareTexturedModel:model instancingEnabled:YES];

        [encoder pushDebugGroup:@"Draw Instanced Entities"];

        [self.instancingShaderProgram loadNormalMatrixWithModelMatrix:GLKMatrix4Identity
                                                        andViewMatrix:viewMat];
        [self.instancingShaderProgram loadOffset:GLKVector2Make(0, 0)];

        [self.instancingShaderProgram uploadUniforms];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:model.rawModel.vertexCount
                             indexType:model.rawModel.indexType
                           indexBuffer:model.rawModel.indexBuffer
                     indexBufferOffset:model.rawModel.indexBufferOffset
                         instanceCount:model.instanceCount];

        [self unbindInstancedTexturedModel];

        [encoder popDebugGroup];
    }
}

- (void)render:(NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> *)entities withCamera:(Camera *)camera
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    [entities enumerateKeysAndObjectsUsingBlock:^(TexturedModel *_Nonnull key,
                                                  NSMutableArray<Entity *> *_Nonnull obj,
                                                  BOOL *_Nonnull stop) {
        [self prepareTexturedModel:key instancingEnabled:NO];

        [encoder pushDebugGroup:@"Draw entites"];
        for (Entity *entity in obj) {
            [self prepareInstance:entity withViewMatrix:camera.viewMatrix];

            [encoder pushDebugGroup:key.debugLabel ?: @"entity"];
            [self.shaderProgram uploadUniforms];
            [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                indexCount:key.rawModel.vertexCount
                                 indexType:key.rawModel.indexType
                               indexBuffer:key.rawModel.indexBuffer
                         indexBufferOffset:key.rawModel.indexBufferOffset];
            [encoder popDebugGroup];
        }
        [encoder popDebugGroup];

        [self unbindTexturedModel];
    }];
}

- (void)prepareTexturedModel:(TexturedModel *)texturedModel instancingEnabled:(BOOL)instancing
{
    MetalContext *context = [MetalContext sharedContext];
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];

    if (!instancing) {
        [self.shaderProgram loadNumberOfRows:texturedModel.texture.numberOfRows];
        [self.shaderProgram loadDamper:texturedModel.texture.shineDamper
                       andReflectivity:texturedModel.texture.reflectivity];
    } else {
        [self.instancingShaderProgram loadNumberOfRows:texturedModel.texture.numberOfRows];
        [self.instancingShaderProgram loadDamper:texturedModel.texture.shineDamper
                                 andReflectivity:texturedModel.texture.reflectivity];
    }

    if (texturedModel.texture.hasAlpha && context.cullingEnabled) {
        [MasterRenderer disableCulling];
    }

    [context.currentEncoder setFragmentTexture:texturedModel.texture.texture atIndex:TextureIndexDiffuse];
    [context.currentEncoder setFragmentSamplerState:context.samplerMipRepeat atIndex:TextureIndexDiffuse];
}

- (void)unbindTexturedModel
{
    if (![MetalContext sharedContext].cullingEnabled) {
        [MasterRenderer enableCulling];
    }
}

- (void)unbindInstancedTexturedModel
{
    if (![MetalContext sharedContext].cullingEnabled) {
        [MasterRenderer enableCulling];
    }
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
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;
    TexturedModel *texturedModel = entity.model;
    RawModel *model = texturedModel.rawModel;
    [model bindVAO];

    [shader loadTransformationMatrix:entity.currentTransformationMatrix];

    [encoder setFragmentTexture:texturedModel.texture.texture atIndex:TextureIndexDiffuse];
    [encoder setFragmentSamplerState:[MetalContext sharedContext].samplerMipRepeat atIndex:TextureIndexDiffuse];
    [shader uploadUniforms];
    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                        indexCount:model.vertexCount
                         indexType:model.indexType
                       indexBuffer:model.indexBuffer
                 indexBufferOffset:model.indexBufferOffset];

    [model unbindVAO];
}

@end
