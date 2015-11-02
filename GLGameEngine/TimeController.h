//
//  TimeController.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeController : NSObject

@property (strong, nonatomic) NSDate *startDate;
@property (assign, nonatomic) NSTimeInterval passedTime;

+ (TimeController *)sharedController;

@end
