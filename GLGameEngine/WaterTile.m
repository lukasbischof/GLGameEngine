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

- (instancetype)initWithX:(GLfloat)x z:(GLfloat)z height:(GLfloat)height andSize:(GLfloat)size
{
    if ((self = [super init])) {
        self.x = x;
        self.z = z;
        self.height = height;
        _size = size;
    }
    
    return self;
}

- (instancetype)initWithX:(GLfloat)x z:(GLfloat)z andHeight:(GLfloat)height
{
    return [self initWithX:x z:z height:height andSize:60.0];
}

@end
