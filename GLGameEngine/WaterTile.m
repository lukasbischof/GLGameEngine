//
//  WaterTile.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterTile.h"

@implementation WaterTile

- (instancetype)init
{
    return [self initWithX:0.0 z:0.0 height:0.0 andSize:60.0];
}

- (instancetype)initWithX:(float)x z:(float)z height:(float)height andSize:(float)size
{
    if ((self = [super init])) {
        self.x = x;
        self.z = z;
        self.height = height;
        _size = size;
    }
    
    return self;
}

- (instancetype)initWithX:(float)x z:(float)z andHeight:(float)height
{
    return [self initWithX:x z:z height:height andSize:60.0];
}

@end
