//
//  ViewController.m
//  GLGameEngine Mac
//
//  Created by Lukas Bischof on 31.07.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "ViewController.h"
#import "GameView.h"

@interface ViewController ()

@property (strong, nonatomic) NSOpenGLContext *openGLContext;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear
{

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
