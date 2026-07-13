//
//  Texture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 06.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

@interface Texture : NSObject <NSCopying>

// The texture object; its textureType encodes what the GL textureTarget did
// (2D vs. cube map).
@property (strong, nonatomic, readonly, nullable) id<MTLTexture> texture;

- (_Nonnull instancetype)initWithMTLTexture:(id<MTLTexture> _Nullable)texture;

@end
