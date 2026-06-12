//
//  GUIRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUIRenderer.h"
#import "MathUtils.h"
#import "MetalContext.h"

const float quad2DVertices[] = {
    -1,  1,
    -1, -1,
     1,  1,
     1, -1
};

@interface GUIRenderer ()

@property (strong, nonatomic) RawModel *quadModel;
@property (strong, nonatomic) GUIShader *shader;

@end

@implementation GUIRenderer

+ (GUIRenderer *)rendererWithLoader:(Loader *)loader
{
    return [[GUIRenderer alloc] initWithLoader:loader];
}

- (instancetype)init
{
    return [self initWithLoader:[Loader loader]];
}

- (instancetype)initWithLoader:(Loader *)loader
{
    if ((self = [super init])) {
        FloatBuffer positions = FloatBufferCreateWithDataNoCopy(quad2DVertices, sizeof(quad2DVertices));
        self.quadModel = [loader createRawModelWithPositions:positions dimensions:2];
        self.shader = [GUIShader GUIShaderProgram];
    }

    return self;
}

- (void)render:(NSArray<GUITexture *> *)guis
{
    MetalContext *context = [MetalContext sharedContext];
    id<MTLRenderCommandEncoder> encoder = context.currentEncoder;

    [self.shader activate];
    [self.quadModel bindVAO];
    // blending is baked into the GUI pipeline; glDisable(GL_DEPTH_TEST):
    [encoder setDepthStencilState:context.dsAlwaysNoWrite];

    for (GUITexture *gui in guis) {
        // mirror the per-texture GL sampling state: loader textures have
        // mipmaps + repeat, FBO textures (WATER_DEBUG) are linear + clamp
        id<MTLSamplerState> sampler = gui.texture.mipmapLevelCount > 1 ? context.samplerMipRepeat : context.samplerLinearClamp;
        [encoder setFragmentTexture:gui.texture atIndex:TextureIndexDiffuse];
        [encoder setFragmentSamplerState:sampler atIndex:TextureIndexDiffuse];
        [self.shader loadTransformationMatrix:MathUtils_CreateGUITransformationMatrix(gui.position, gui.scale)];
        [self.shader uploadUniforms];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:self.quadModel.vertexCount];
    }

    [encoder setDepthStencilState:context.dsLessWrite];
    [self.quadModel unbindVAO];
    [self.shader deactivate];
}

- (void)cleanUp
{
    [self.shader cleanUp];
}

@end
