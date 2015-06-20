//
//  ViewController.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ViewController.h"
#import "Loader.h"
#import "Renderer.h"
#import "StaticShaderProgram.h"
#import "Entity.h"
#import "OBJLoader.h"
#import "OBJLoader2.h"
#import "Camera.h"

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

@property (strong, nonatomic) Loader *loader;
@property (strong, nonatomic) Renderer *renderer;
@property (strong, nonatomic) Entity *entity;
@property (strong, nonatomic) StaticShaderProgram *program;
@property (strong, nonatomic) Camera *camera;

@end

@implementation ViewController

#pragma mark - View methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initOpenGLESContext];
    [self initGLObjects];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Rendering / OpenGL related methods
- (void)initOpenGLESContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"SORRY, OPENGL ES 3.0 ISN'T AVAILABLE ON YOUR DEVICE :(");
        exit(EXIT_SUCCESS);
    } else
        NSLog(@"OpenGL ES 3.0 Context initialized.");
    
    self.glview.context = self.context;
    self.glview.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    // self.glview.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    // self.glview.drawableMultisample = GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:self.context];
    [self.glview bindDrawable];
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)tearDownOpenGLES
{
    [self.loader cleanUp];
    [self.program cleanUp];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)initGLObjects
{    
    self.loader = [Loader loader];
    self.program = [StaticShaderProgram staticShaderProgram];
    self.renderer = [Renderer rendererWithShaderProgram:self.program];
    self.camera = [Camera camera];
    
    GLKTextureInfo *texInfo = [[self loader] loadTexture:@"stallTexture" withExtension:@"png"];
    ModelTexture *texture = [[ModelTexture alloc] initWithTextureID:texInfo.name andTextureTarget:texInfo.target];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"stall" withExtension:@"obj"];
    TexturedModel *texturedModel = [[OBJLoader alloc] initWithURL:modelURL
                                                           texture:texture
                                                         andLoader:self.loader].texturedModel;
    
    GLKVector3 position = GLKVector3Make(0.0, 0.0, -20.0);
    self.entity = [Entity entityWithTexturedModel:texturedModel
                                         position:position
                                         rotation:MathUtils_RotationMake(0.0, 0.0, 0.0)
                                         andScale:1.5];
}

#pragma mark GLKViewControllerDelegate

// This method gets called before the view renders
- (void)update
{
    if (self.camera.position.y <= 6.5)
        [self.camera move:GLKVector3Make(0, 0.004, 0)];
    [self.entity increaseRotationByX:0.0 y:0.8 andZ:0.0];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.renderer prepare];
    
    [self.program activate];
    [self.program loadViewMatrix:[self.camera getViewMatrix]];
    [self.renderer render:self.entity withShaderProgram:self.program];
    [self.program deactivate];
}

#pragma mark - Getters
- (GLKView *)glview
{
    return (GLKView *)self.view;
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownOpenGLES];
    }
}

- (void)dealloc
{
    [self tearDownOpenGLES];
}

@end
