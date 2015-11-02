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

+ (SkyboxRenderer *)skyboxRendererWithLoader:(Loader *)loader;

- (instancetype)initWithLoader:(Loader *)loader;

- (void)updateProjectionMatrix:(GLKMatrix4)projMat;
- (void)renderWithCamera:(Camera *)camera;

@end
