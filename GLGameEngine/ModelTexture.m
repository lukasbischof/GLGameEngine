//
//  ModelTexture.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ModelTexture.h"

@implementation ModelTexture

- (instancetype)initWithMTLTexture:(id<MTLTexture>)texture
{
    if ((self = [super initWithMTLTexture:texture])) {
        _numberOfRows = 1;
        _shineDamper = 45.0;
        _reflectivity = 0.0;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ModelTexture *copy = [[ModelTexture alloc] initWithMTLTexture:self.texture];

    copy.shineDamper = self.shineDamper;
    copy.reflectivity = self.reflectivity;
    copy.hasAlpha = self.hasAlpha;
    copy.numberOfRows = self.numberOfRows;

    return copy;
}

@end
