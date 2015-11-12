//
//  WaterRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Loader.h"
#import "WaterTile.h"
#import "WaterShader.h"
#import "Camera.h"
#import "WaterFrameBuffers.h"

@interface WaterRenderer : NSObject

+ (WaterRenderer *)waterRendererWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)waterFrameBuffers;

- (instancetype)initWithLoader:(Loader *)loader andFBOs:(WaterFrameBuffers *)waterFrameBuffers;

- (void)updateProjectionMatrix:(GLKMatrix4)projMat;
- (void)render:(NSArray<WaterTile *> *)tiles withCamera:(Camera *)camera;

- (void)cleanUp;

@end
