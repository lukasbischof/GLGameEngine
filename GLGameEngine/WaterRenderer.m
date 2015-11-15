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
        
        GLKTextureInfo *info = [loader loadTexture:DUDV_MAP_NAME withExtension:DUDV_MAP_EXT];
        self.dudvMap = [[Texture alloc] initWithTextureInfo:info];
        
        info = [loader loadTexture:NORMAL_MAP_NAME withExtension:NORMAL_MAP_EXT];
        self.normalMap = [[Texture alloc] initWithTextureInfo:info];
        
        glBindTexture(self.dudvMap.textureTarget, self.dudvMap.textureID);
        glTexParameteri(self.dudvMap.textureTarget, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(self.dudvMap.textureTarget, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glBindTexture(self.normalMap.textureTarget, self.normalMap.textureID);
        glTexParameteri(self.normalMap.textureTarget, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(self.normalMap.textureTarget, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glBindTexture(GL_TEXTURE_2D, 0);
        
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
    [self prepareForRenderingWithCam:camera andLight:light];
    
    for (WaterTile *tile in tiles) {
        GLKMatrix4 modelMatrix = MathUtils_CreateTransformationMatrixr(GLKVector3Make(tile.x, tile.height, tile.z), MathUtils_ZeroRotation, tile.size);
        
        [self.shader loadTransformationMatrix:modelMatrix];
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.quadModel.vertexCount);
    }
    
    [self unbind];
}

- (void)prepareForRenderingWithCam:(Camera *)cam andLight:(Light *)light
{
    [self.shader activate];
    [self.shader loadViewMatrix:cam];
    [self.shader loadMoveFactor:fmodf(WAVE_SPEED * [[TimeController sharedController] passedTime], 1.0)];
    [self.shader loadLight:light];
    
    glBindVertexArray(self.quadModel.vaoID);
    glEnableVertexAttribArray(0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.fbos.reflectionTexture);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.fbos.refractionTexture);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(self.dudvMap.textureTarget, self.dudvMap.textureID);
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(self.normalMap.textureTarget, self.normalMap.textureID);
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, self.fbos.refractionDepthTexture);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisable(GL_CULL_FACE);
}

- (void)unbind
{
    glDisable(GL_BLEND);
    glDisableVertexAttribArray(0);
    glBindVertexArray(0);
    glEnable(GL_CULL_FACE);
    [self.shader deactivate];
}

- (void)cleanUp
{
    [self.shader cleanUp];
}

@end
