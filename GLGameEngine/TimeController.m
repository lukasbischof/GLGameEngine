//
//  TimeController.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TimeController.h"

@implementation TimeController

+ (TimeController *)sharedController
{
    static TimeController *con;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        con = [TimeController new];
    });
    
    return con;
}

- (NSTimeInterval)passedTime
{
    return -[self.startDate timeIntervalSinceNow];
}

@end
