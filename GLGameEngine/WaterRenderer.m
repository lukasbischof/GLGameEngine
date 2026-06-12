//
//  WaterRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterRenderer.h"
#import "MathUtils.h"
#import "TimeController.h"
#import "MetalContext.h"

const float quadVertices[] = {
    -1, 0, -1,
     1, 0, -1,
    -1, 0,  1,
     1, 0,  1
};

static NSString *const DUDV_MAP_NAME = @"waterDuDv";
static NSString *const DUDV_MAP_EXT = @"png";
static NSString *const NORMAL_MAP_NAME = @"waterNormal";
static NSString *const NORMAL_MAP_EXT = @"png";
static const GLfloat WAVE_SPEED = 0.015f;

@interface WaterRenderer ()

@property (strong, nonatomic) RawModel *quadModel;
@property (strong, nonatomic) WaterShader *shader;
@property (strong, nonatomic) WaterFrameBuffers *fbos;
@property (strong, nonatomic) Texture *dudvMap;
@property (strong, nonatomic) Texture *normalMap;

@end

@implementation WaterRenderer

+ (WaterRenderer *)waterRendererWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)waterFrameBuffers
{
    return [[WaterRenderer alloc] initWithLoader:loader andFBOs:waterFrameBuffers];
}

- (instancetype)initWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)waterFrameBuffers
{
    if ((self = [super init])) {
        FloatBuffer positionBuffer = FloatBufferCreateWithDataNoCopy(quadVertices, sizeof(quadVertices));
        self.quadModel = [loader createRawModelWithPositions:positionBuffer dimensions:3];

        self.shader = [WaterShader waterShaderProgram];
        self.fbos = waterFrameBuffers;

        // GL_REPEAT wrapping is part of the sampler state (samplerMipRepeat)
        self.dudvMap = [[Texture alloc] initWithMTLTexture:[loader loadTexture:DUDV_MAP_NAME withExtension:DUDV_MAP_EXT]];
        self.normalMap = [[Texture alloc] initWithMTLTexture:[loader loadTexture:NORMAL_MAP_NAME withExtension:NORMAL_MAP_EXT]];

        [self.shader bind:^{
            [self.shader loadTextureUnits];
        }];
    }

    return self;
}

#pragma mark - rendering
- (void)updateProjectionMatrix:(GLKMatrix4)projMat
{
    [self.shader bind:^{
        [[self shader] loadProjectionMatrix:projMat];
    }];
}

- (void)render:(NSArray<WaterTile *> *)tiles withCamera:(Camera *)camera andLight:(Light *)light
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    [self prepareForRenderingWithCam:camera andLight:light];

    for (WaterTile *tile in tiles) {
        GLKMatrix4 modelMatrix = MathUtils_CreateTransformationMatrixr(GLKVector3Make(tile.x, tile.height, tile.z), MathUtils_ZeroRotation, tile.size);

        [self.shader loadTransformationMatrix:modelMatrix];

        [self.shader uploadUniforms];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:self.quadModel.vertexCount];
    }

    [self unbind];
}

- (void)prepareForRenderingWithCam:(Camera *)cam andLight:(Light *)light
{
    MetalContext *context = [MetalContext sharedContext];
    id<MTLRenderCommandEncoder> encoder = context.currentEncoder;

    [self.shader activate];
    [self.shader loadViewMatrix:cam];
    [self.shader loadMoveFactor:fmodf(WAVE_SPEED * [[TimeController sharedController] passedTime], 1.0)];
    [self.shader loadLight:light];

    [self.quadModel bindVAO];

    [encoder setFragmentTexture:self.fbos.reflectionTexture atIndex:TextureIndexReflection];
    [encoder setFragmentTexture:self.fbos.refractionTexture atIndex:TextureIndexRefraction];
    [encoder setFragmentTexture:self.dudvMap.texture atIndex:TextureIndexDuDvMap];
    [encoder setFragmentTexture:self.normalMap.texture atIndex:TextureIndexNormalMap];
    [encoder setFragmentTexture:self.fbos.refractionDepthTexture atIndex:TextureIndexDepthMap];

    [encoder setFragmentSamplerState:context.samplerLinearClamp atIndex:TextureIndexReflection];
    [encoder setFragmentSamplerState:context.samplerMipRepeat atIndex:TextureIndexDuDvMap];
    [encoder setFragmentSamplerState:context.samplerNearestClamp atIndex:TextureIndexDepthMap];

    // blending (srcAlpha / oneMinusSrcAlpha) is baked into the water pipeline
    // glDisable(GL_CULL_FACE):
    context.cullingEnabled = NO;
}

- (void)unbind
{
    // glEnable(GL_CULL_FACE)
    [MetalContext sharedContext].cullingEnabled = YES;
    [self.shader deactivate];
}

- (void)cleanUp
{
    [self.shader cleanUp];
}

@end
