//
//  TerrainTexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture.h"

@interface TerrainTexture : Texture

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture enableTiling:(BOOL)enableTiling NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture;
- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture andTiling:(BOOL)enableTiling;

@end
