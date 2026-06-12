//
//  GUITexture.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>
#import "Texture.h"

@interface GUITexture : Texture

@property (assign, nonatomic) GLKVector2 position;
@property (assign, nonatomic) GLKVector2 scale;

+ (GUITexture *)textureWithMTLTexture:(id<MTLTexture>)texture position:(GLKVector2)position andScale:(GLKVector2)scale;

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture position:(GLKVector2)position andScale:(GLKVector2)scale NS_DESIGNATED_INITIALIZER;

@end
