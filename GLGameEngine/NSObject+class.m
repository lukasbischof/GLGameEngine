//
//  NSObject+class.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "NSObject+class.h"

@implementation NSObject (class)

- (NSString *)className
{
    return NSStringFromClass([self class]);
}

@end
