//
//  WaterFrameBuffers.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 08.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface WaterFrameBuffers : NSObject

@property (strong, nonatomic, readonly) id<MTLTexture> reflectionTexture;
@property (strong, nonatomic, readonly) id<MTLTexture> refractionTexture;
@property (strong, nonatomic, readonly) id<MTLTexture> refractionDepthTexture;

+ (WaterFrameBuffers *)frameBuffers;

- (void)bindReflectionFrameBuffer;
- (void)bindRefractionFrameBuffer;
- (void)cleanUp;

@end
