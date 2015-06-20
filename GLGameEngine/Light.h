//
//  Light.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Light : NSObject

@property (assign, nonatomic) GLKVector3 position;
@property (assign, nonatomic) GLKVector3 color;

+ (Light *)light;
+ (Light *)lightWithPosition:(GLKVector3)position andColor:(GLKVector3)color;

- (instancetype)initWithPosition:(GLKVector3)position andColor:(GLKVector3)color;

@end
