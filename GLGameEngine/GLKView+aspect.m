//
//  GLKView+aspect.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 24.08.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GLKView+aspect.h"

@implementation GLKView (aspect)

- (float)aspect
{
    return self.frame.size.width / self.frame.size.height;
}

@end
