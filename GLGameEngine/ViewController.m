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
#import "MasterRenderer.h"
#import "GLKView+aspect.h"

#define _ACTIVATE_SHADER_ [self.shader activate];
#define _DEACTIVATE_SHADER_ [self.shader deactivate];

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSDate *renderStartDate;

@property (strong, nonatomic) Loader *loader;
@property (strong, nonatomic) MasterRenderer *renderer;
@property (strong, nonatomic) NSMutableArray<Entity *> *entities;
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
    [self.renderer cleanUp];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)initGLObjects
{
    self.renderer = [MasterRenderer renderer];
    self.loader = [Loader loader];
    self.camera = [Camera camera];
    self.light = [Light light];
    self.renderStartDate = [NSDate date];
    
    [self.renderer updateProjectionForAspect:[self glview].aspect];
    
    //[self.camera move:GLKVector3Make(0, 0.5, 0)];
    
    GLKTextureInfo *texInfo = [self.loader loadTexture:@"white" withExtension:@"png"];
    ModelTexture *texture = [[ModelTexture alloc] initWithTextureID:texInfo.name andTextureTarget:texInfo.target];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"cube" withExtension:@"obj"];
    TexturedModel *texturedModel = [[OBJLoader2 alloc] initWithURL:modelURL
                                                           texture:texture
                                                         andLoader:self.loader].texturedModel;
    
    /// @todo OpenGL 3D Game Tutorial 13: Optimizing
    /*!!
     @todo MasterRenderer implementiert. -> ViewController fertig machen:
      -   @resource OpenGL 3D Game Tutorial 13: Optimizing
      -   @stopped 10:50
      -   @implemented MasterRenderer
    */
    self.entities = [NSMutableArray<Entity *> new];
    for (NSUInteger i = 0; i <= 300; i++) {
        GLKVector3 position = GLKVector3Make(MathUtils_RandomFloat(-5.6, 5.6), MathUtils_RandomFloat(-1.5, 8), MathUtils_RandomFloat(-40, -5));
        Entity *entity = [Entity entityWithTexturedModel:texturedModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, 0.0, 0.0)
                                                andScale:.5];
        
        /// @todo Zurzeit werden nur statische Lichtparameter im Shader verwendet. Damper = Specular Higlights-Exponent, Reflectivity = Gewicht (Weight)
        /// => In den Shader laden und implementieren
        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = 1;
        entity.rotationSpeed = MathUtils_RandomFloat(0.01, 1.0);
        
        [self.entities addObject:entity];
    }
    
    self.light.position = GLKVector3Make(0.0, 0.0, 2.0);
    self.light.color = GLKVector3Make(1.0, 0.0, 0.0);
    
    printf("%s", [self getEntitiesDescription].UTF8String);
}

#pragma mark GLKViewControllerDelegate

// This method gets called before the view renders
- (void)update
{
    if (self.camera.position.y <= 8.7)
        [self.camera move:GLKVector3Make(0, 0.011, -0.017)];
    else if (self.camera.position.z >= -30)
        [self.camera move:GLKVector3Make(0, 0, -0.017)];
    else if (self.camera.yaw <= 180)
        self.camera.yaw += 0.11;
    else if (self.camera.pitch <= 20)
        self.camera.pitch += 0.14;
    
    NSTimeInterval time = (self.renderStartDate).timeIntervalSinceNow * -1;
    
    for (Entity *entity in self.entities) {
        const float entityRotationFrequency = 1.0 / entity.rotationSpeed; // x s^-1
        const float rotations = time / entityRotationFrequency;
        
        [entity setRotationX:0.0 y:rotations * 360 andZ:0.0];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (_pMatrixNeedsUpdate) {
        [self.renderer updateProjectionForAspect:[self glview].aspect];
        _pMatrixNeedsUpdate = NO;
    }
    
    for (Entity *entity in self.entities) {
        [self.renderer processEntity:entity];
    }
    
    [self.renderer renderWithLight:self.light andCamera:self.camera];
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
    
    if ([self isViewLoaded] && (self.view.window == nil)) {
        self.view = nil;
        
        [self tearDownOpenGLES];
    }
}

- (void)dealloc
{
    [self tearDownOpenGLES];
}

#pragma mark - Information / Debugging
- (NSString *)getEntitiesDescription
{
    NSMutableString *str = [(@"") mutableCopy];
    
    NSUInteger i = 0;
    for (Entity *entity in self.entities) {
        [str appendFormat:@"Entity %lu: %@\n", (unsigned long)++i, entity];
    }
    
    return str;
}

@end
