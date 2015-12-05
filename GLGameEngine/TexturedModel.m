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
        _UUID = [NSUUID UUID];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TexturedModel *copy = [[TexturedModel alloc] initWithRawModel:[self.rawModel copy] andTexture:[self.texture copy]];
    copy.UUID = self.UUID;
    copy.debugLabel = self.debugLabel;
    
    return copy;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TexturedModel class]] && object != nil) {
        if ([((TexturedModel *)object).UUID isEqual:self.UUID]) {
            return YES;
        }
    }
    
    return NO;
}

@end
