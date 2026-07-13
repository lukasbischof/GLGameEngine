//
//  TerrainRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainRenderer.h"
#import "MetalContext.h"

@interface TerrainRenderer ()

@property (strong, nonatomic) TerrainShader *shader;

@end

@implementation TerrainRenderer

+ (TerrainRenderer *)terrainRendererWithShader:(TerrainShader *)shader
{
    return [[TerrainRenderer alloc] initWithShader:shader];
}

- (instancetype)initWithShader:(TerrainShader *)shader
{
    if ((self = [super init])) {
        self.shader = shader;
    }

    return self;
}

- (void)render:(NSArray<Terrain *> *)terrains withCamera:(Camera *)camera
{
    id<MTLRenderCommandEncoder> encoder = [MetalContext sharedContext].currentEncoder;

    for (Terrain *terrain in terrains) {
        [self prepareTerrain:terrain];
        [self loadTerrainMatricesWithTerrain:terrain andViewMatrix:[camera getViewMatrix]];

        [self.shader uploadUniforms];
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:terrain.model.vertexCount
                             indexType:terrain.model.indexType
                           indexBuffer:terrain.model.indexBuffer
                     indexBufferOffset:terrain.model.indexBufferOffset];

        [self unbindTerrain];
    }
}

- (void)prepareTerrain:(Terrain *)terrain
{
    RawModel *model = terrain.model;
    [model bindBuffersToEncoder];

    [self bindTexturesForTerrain:terrain];
}

- (void)bindTexturesForTerrain:(Terrain *)terrain
{
    MetalContext *context = [MetalContext sharedContext];
    id<MTLRenderCommandEncoder> encoder = context.currentEncoder;
    TerrainTexturePackage *pack = terrain.texturePack;

    [encoder setFragmentTexture:pack.backgroundTexture.texture atIndex:TextureIndexBackground];
    [encoder setFragmentTexture:pack.rTexture.texture atIndex:TextureIndexR];
    [encoder setFragmentTexture:pack.gTexture.texture atIndex:TextureIndexG];
    [encoder setFragmentTexture:pack.bTexture.texture atIndex:TextureIndexB];
    [encoder setFragmentTexture:terrain.blendMap.texture atIndex:TextureIndexBlendMap];
    [encoder setFragmentSamplerState:context.samplerMipRepeat atIndex:0];
}

- (void)unbindTerrain
{

}

- (void)loadTerrainMatricesWithTerrain:(Terrain *)terrain andViewMatrix:(simd_float4x4)viewMat
{
    simd_float4x4 transformationMatrix = MathUtils_MatrixMakeTranslation(terrain.x, 0, terrain.z);
    [self.shader loadTransformationMatrix:transformationMatrix];
    [self.shader loadNormalMatrixWithModelMatrix:transformationMatrix
                                   andViewMatrix:viewMat];
}

@end
