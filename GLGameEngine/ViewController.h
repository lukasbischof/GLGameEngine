//
//  ViewController.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <MTKViewDelegate>

@property (nonatomic, readonly) MTKView *glview;

@end
