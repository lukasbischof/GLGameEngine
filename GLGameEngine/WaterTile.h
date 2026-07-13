//
//  WaterTile.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface WaterTile : NSObject

@property (assign, nonatomic) float x;
@property (assign, nonatomic) float z;
@property (assign, nonatomic) float height;
@property (assign, nonatomic, readonly) float size;

- (instancetype)initWithX:(float)x z:(float)z height:(float)height andSize:(float)size NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithX:(float)x z:(float)z andHeight:(float)height;

@end
