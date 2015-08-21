//
//  TexturedModel.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "TexturedModel.h"

@implementation TexturedModel

- (instancetype)init
{
    return [self initWithRawModel:nil andTexture:nil];
}

- (instancetype)initWithRawModel:(RawModel *)rawModel andTexture:(ModelTexture *)texture
{
    if ((self = [super init])) {
        _rawModel = rawModel;
        _texture = texture;
    }
    
    return self;
}

@end
