
//
//  GUITexture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUITexture.h"
#import "NSObject+class.h"

@implementation GUITexture

+ (GUITexture *)textureWithMTLTexture:(id<MTLTexture>)texture position:(GLKVector2)position andScale:(GLKVector2)scale
{
    return [[GUITexture alloc] initWithMTLTexture:texture
                                         position:position
                                         andScale:scale];
}

- (instancetype)init
{
    return [self initWithMTLTexture:nil position:GLKVector2Make(0, 0) andScale:GLKVector2Make(0, 0)];
}

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture position:(GLKVector2)position andScale:(GLKVector2)scale
{
    if ((self = [super initWithMTLTexture:texture])) {
        self.position = position;
        self.scale = scale;
    }

    return self;
}

@end
