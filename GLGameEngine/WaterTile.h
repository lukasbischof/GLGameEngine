//
//  WaterTile.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 03.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/gltypes.h>
#import <GLKit/GLKit.h>

@interface WaterTile : NSObject

@property (assign, nonatomic) GLfloat x;
@property (assign, nonatomic) GLfloat z;
@property (assign, nonatomic) GLfloat height;
@property (assign, nonatomic, readonly) GLfloat size;

- (instancetype)initWithX:(GLfloat)x z:(GLfloat)z height:(GLfloat)height andSize:(GLfloat)size NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithX:(GLfloat)x z:(GLfloat)z andHeight:(GLfloat)height;

@end
