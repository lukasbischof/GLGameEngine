//
//  SkyboxRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Loader.h"
#import "SkyboxShader.h"
#import "Camera.h"

@interface SkyboxRenderer : NSObject

@property (strong, nonatomic) SkyboxShader *shader;

+ (SkyboxRenderer *)skyboxRendererWithLoader:(Loader *)loader;

- (instancetype)initWithLoader:(Loader *)loader;

- (void)updateProjectionMatrix:(simd_float4x4)projMat;
- (void)updateFogColor:(simd_float3)fogColor;
- (void)renderWithCamera:(Camera *)camera;

- (void)cleanUp;

@end
