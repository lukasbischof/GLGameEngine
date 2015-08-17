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
@property (strong, nonatomic) NSMutableArray<Entity *> *entities;
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
    
    self.renderer.clearColor = RGBAMakeFromRGBHex(0x1122FF);
    
    GLKTextureInfo *texInfo = [[self loader] loadTexture:@"white" withExtension:@"png"];
    ModelTexture *texture = [[ModelTexture alloc] initWithTextureID:texInfo.name andTextureTarget:texInfo.target];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"cube" withExtension:@"obj"];
    TexturedModel *texturedModel = [[OBJLoader2 alloc] initWithURL:modelURL
                                                           texture:texture
                                                         andLoader:self.loader].texturedModel;
    
    /// @todo OpenGL 3D Game Tutorial 13: Optimizing
    self.entities = [NSMutableArray<Entity *> new];
    for (NSUInteger i = 0; i <= 20; i++) {
        GLKVector3 position = GLKVector3Make(MathUtils_RandomFloat(-5, 5), MathUtils_RandomFloat(-3, 5), MathUtils_RandomFloat(-20, 30));
        Entity *entity = [Entity entityWithTexturedModel:texturedModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, 0.0, 0.0)
                                                andScale:1.5];
        
        /// @todo Zurzeit werden nur statische Lichtparameter im Shader verwendet. Damper = Specular Higlights-Exponent, Reflectivity = Gewicht (Weight)
        /// => In den Shader laden und implementieren
        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = 1;
        
        [self.entities addObject:entity];
    }
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
    
    for (Entity *entity in self.entities) {
        [entity setRotationX:0.0 y:rotations * 360 andZ:0.0];
    }
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
        
        for (Entity *entity in self.entities) {
            [self.shader loadLight:self.light];
            [self.shader loadViewMatrix:[self.camera getViewMatrix]];
            [self.shader loadNormalMatrixWithModelMatrix:[entity getCurrentTransformationMatrix]
                                           andViewMatrix:[self.camera getViewMatrix]];
            [self.renderer render:entity withShaderProgram:self.shader];
        }
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
