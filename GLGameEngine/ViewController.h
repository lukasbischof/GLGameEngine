//
//  ViewController.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#else
#import <OpenGL/OpenGL.h>
#endif
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : GLKViewController

@property (nonatomic) GLKView *glview;

@end

