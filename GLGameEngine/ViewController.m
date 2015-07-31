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

#define _ACTIVATE_SHADER_ [self.shader activate];
#define _DEACTIVATE_SHADER_ [self.shader deactivate];

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSDate *renderStartDate;

@property (strong, nonatomic) Loader *loader;
@property (strong, nonatomic) Renderer *renderer;
@property (strong, nonatomic) Entity *entity;
@property (strong, nonatomic) StaticShaderProgram *shader;
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) Light *light;

@end

@implementation ViewController {
    BOOL _pMatrixNeedsUpdate;
}

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

- (void)viewWillLayoutSubviews
{
    _pMatrixNeedsUpdate = YES;
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
    [self.shader cleanUp];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)initGLObjects
{    
    self.loader = [Loader loader];
    self.shader = [StaticShaderProgram staticShaderProgram];
    self.renderer = [Renderer rendererWithShaderProgram:self.shader];
    self.camera = [Camera camera];
    self.light = [Light light];
    self.renderStartDate = [NSDate date];
    
    GLKTextureInfo *texInfo = [[self loader] loadTexture:@"white" withExtension:@"png"];
    ModelTexture *texture = [[ModelTexture alloc] initWithTextureID:texInfo.name andTextureTarget:texInfo.target];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"dragon" withExtension:@"obj"];
    TexturedModel *texturedModel = [[OBJLoader2 alloc] initWithURL:modelURL
                                                           texture:texture
                                                         andLoader:self.loader].texturedModel;
    
    GLKVector3 position = GLKVector3Make(0.0, 0.0, -20.0);
    self.entity = [Entity entityWithTexturedModel:texturedModel
                                         position:position
                                         rotation:MathUtils_RotationMake(0.0, 0.0, 0.0)
                                         andScale:1.5];
    
    self.entity.model.texture.shineDamper = 30;
    self.entity.model.texture.reflectivity = 1;
    self.light.position = GLKVector3Make(0.0, 0.0, 2.0);
    self.light.color = GLKVector3Make(1.0, 0.0, 0.0);
}

#pragma mark GLKViewControllerDelegate

const float entityRotationFrequency = 1.0 / 0.25; // 0.25 s^-1

// This method gets called before the view renders
- (void)update
{
    if (self.camera.position.y <= 6.5)
        [self.camera move:GLKVector3Make(0, 0.004, 0)];
    
    NSTimeInterval time = [self.renderStartDate timeIntervalSinceNow] * -1;
    float rotations = time / entityRotationFrequency;
    [self.entity setRotationX:0.0 y:rotations * 360 andZ:0.0];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.renderer prepare];
    
    _ACTIVATE_SHADER_
    {
        if (_pMatrixNeedsUpdate) {
            [self.renderer updateProjectionWithAspect:rect.size.width / rect.size.height forShader:self.shader];
            _pMatrixNeedsUpdate = NO;
        }
        
        [self.shader loadLight:self.light];
        [self.shader loadNormalMatrixWithModelMatrix:[self.entity getCurrentTransformationMatrix]
                                       andViewMatrix:[self.camera getViewMatrix]];
        [self.shader loadViewMatrix:[self.camera getViewMatrix]];
        [self.renderer render:self.entity withShaderProgram:self.shader];
    }
    _DEACTIVATE_SHADER_
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
