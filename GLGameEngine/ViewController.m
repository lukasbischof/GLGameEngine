//
//  ViewController.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ViewController.h"
#import "Loader.h"
#import "EntityRenderer.h"
#import "StaticShaderProgram.h"
#import "Entity.h"
#import "OBJLoader.h"
#import "OBJLoader2.h"
#import "Camera.h"
#import "MasterRenderer.h"
#import "GLKView+aspect.h"
#import "TimeController.h"
#import "WaterFrameBuffers.h"
#import <sys/utsname.h>

#define WATER_DEBUG 0

NSString *deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@interface ViewController () <GLKViewControllerDelegate>

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSDate *renderStartDate;

@property (strong, nonatomic) Loader *loader;
@property (strong, nonatomic) MasterRenderer *renderer;
@property (strong, nonatomic) NSMutableArray<Entity *> *entities;
@property (strong, nonatomic) NSMutableArray<InstanceableTexturedModel *> *instanceableModels;
@property (strong, nonatomic) Terrain *terrain;
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) NSMutableArray<Light *> *lights;
@property (strong, nonatomic) TerrainTexturePackage *terrainTexturePack;
@property (strong, nonatomic) TerrainTexture *terrainBlendMap;
@property (strong, nonatomic) NSMutableArray<GUITexture *> *guis;
@property (strong, nonatomic) WaterTile *water;
@property (strong, nonatomic) WaterFrameBuffers *fbos;

@end

@implementation ViewController {
    BOOL _pMatrixNeedsUpdate;
    BOOL _isMoving;
    GLfloat _movingDirectionX;
    GLfloat _movingDirectionY;
    GLfloat _oldYaw;
    GLfloat _oldPitch;
    CGPoint _startTouch;
    GLint defaultFBO;
}

#pragma mark - View methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initOpenGLESContext];
    [self initGLObjects];
    
    self.delegate = self;
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
    } else {
        NSLog(@"OpenGL ES 3.0 context initialized for %@.", deviceName());
    }
    
    self.glview.context = self.context;
    self.glview.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.glview.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //self.glview.drawableMultisample = GLKViewDrawableMultisampleNone;
    
    [EAGLContext setCurrentContext:self.context];
    [self.glview bindDrawable];
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)tearDownOpenGLES
{
    [self.loader cleanUp];
    [self.renderer cleanUp];
    [self.fbos cleanUp];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context = nil;
}

- (void)initGLObjects
{
    self.loader = [Loader loader];
    self.fbos = [[WaterFrameBuffers alloc] init];
    self.renderer = [MasterRenderer rendererWithLoader:self.loader andFBOs:self.fbos];
    self.camera = [Camera camera];
    self.lights = [NSMutableArray array];
    self.guis = [NSMutableArray array];
    self.renderStartDate = [NSDate date];
    
    [self.camera move:GLKVector3Make(TERRAIN_SIZE/2.0 + 60, 8.1, -TERRAIN_SIZE/2.0 - 30)];
    
    [self setupEntities];
    
    [[TimeController sharedController] setStartDate:[NSDate date]];
    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        NSLog(@"An error occured while initializing OpenGL objects: %d", err);
    }
}

- (void)setupEntities
{
    // TERRAIN
    [self setupTerrainTexturePackage];
    self.terrain = [Terrain terrainWithGridX:0
                                       gridZ:-1
                                      loader:self.loader
                                 texturePack:self.terrainTexturePack
                               heightMapName:@"heightmap3_vlow"
                                 andBlendMap:self.terrainBlendMap];
    
    // ENTITIES
    self.entities = [NSMutableArray<Entity *> new];
    self.instanceableModels = [NSMutableArray<InstanceableTexturedModel *> new];
    
    NSLog(@"err before: %d", glGetError());
    NSArray<NSString *> *names = @[@"Rock", @"pine", @"grass2",
                                   @"grassModel", @"Farmhouse", @"wagen",
                                   @"fern", @"lamp", @"boat"];
    NSArray *textureNames = @[@[@"Rock", @"jpg"], @[@"pine", @"png"], @[@"grassTexture", @"png"],
                              @[@"flower", @"png"], @[@"Farmhouse", @"jpg"], @[@"wagen", @"jpg"],
                              @[@"fernAtlas", @"png"], @[@"lamp", @"png"], @[@"boat", @"jpg"]];
    NSArray<TexturedModel *> *models = [OBJLoader2 loadModelsWithNames:names
                                                          textureNames:textureNames
                                                             andLoader:self.loader];
    
    if (models.count != names.count)
        abort();
    
    TexturedModel *rockModel   = models[0],
                  *treeModel   = models[1],
                  *grassModel  = models[2],
                  *flowerModel = models[3],
                  *farmModel   = models[4],
                  *wagenModel  = models[5],
                  *fernModel   = models[6],
                  *lampModel   = models[7],
                  *boatModel   = models[8];
    /*InstanceableTexturedModel *rockModel = [[InstanceableTexturedModel alloc] initWithRawModel:models[0].rawModel
                                                                                    andTexture:models[0].texture];
    InstanceableTexturedModel *treeModel = [[InstanceableTexturedModel alloc] initWithRawModel:models[1].rawModel
                                                                                    andTexture:models[1].texture];
    TexturedModel *rockModel   = models[0],
                  *grassModel  = models[2],
                  *flowerModel = models[3],
                  *farmModel   = models[4],
                  *wagenModel  = models[5],
                  *fernModel   = models[6],
                  *lampModel   = models[7];*/
    
    fernModel.texture.hasAlpha = YES;
    grassModel.texture.hasAlpha = YES;
    flowerModel.texture.hasAlpha = YES;
    fernModel.texture.numberOfRows = 2;
    
    // FARM
    Entity *farmEntity = [Entity entityWithTexturedModel:farmModel];
    farmEntity.position = GLKVector3Make(TERRAIN_SIZE/2.0, 0.0, -TERRAIN_SIZE/2.0 - 40.0);
    farmEntity.scale = 0.3;
    //farmEntity.rotation = MathUtils_RotationMake(0.0, 125., 0.0);
    
    [self.entities addObject:farmEntity];
    
    // BOAT
    Entity *boatEntity = [Entity entityWithTexturedModel:boatModel];
    boatEntity.position = GLKVector3Make(TERRAIN_SIZE/2.0 + 60, -8.0, -TERRAIN_SIZE/2.0 - 100.0);
    boatEntity.scale = 0.01;
    //farmEntity.rotation = MathUtils_RotationMake(0.0, 125., 0.0);
    
    [self.entities addObject:boatEntity];
    
    // WAGEN
    Entity *wagenEntity = [Entity entityWithTexturedModel:wagenModel];
    wagenEntity.position = (GLKVector3){ TERRAIN_SIZE/2.0 + 10, 0.0, -TERRAIN_SIZE / 2.0 - 20 };
    wagenEntity.scale = 1.6;
    
    [self.entities addObject:wagenEntity];
    
    wagenEntity = [wagenEntity copy];
    wagenEntity.position = (GLKVector3){ TERRAIN_SIZE/2.0 + 8.25, 0.0, -TERRAIN_SIZE / 2.0 - 20 };
    
    [self.entities addObject:wagenEntity];
    
    // ROCK SETUP
    for (NSUInteger i = 0; i < 50; i++) {
        GLfloat x = MathUtils_RandomFloat(-50, 50) + TERRAIN_SIZE/2.;
        GLfloat z = MathUtils_RandomFloat(0, -100) - TERRAIN_SIZE/2.;
        GLKVector3 position = GLKVector3Make(x, [self.terrain getHeightAtWorldX:x worldZ:z], z);
        Entity *entity = [Entity entityWithTexturedModel:rockModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, MathUtils_RandomFloat(0.0, 360.0), 0.0)
                                                andScale:MathUtils_RandomFloat(.3, .6)];
        
        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = .1;
        
        [self.entities addObject:entity];
        //[rockModel updateTransformationMatrix:entity.currentTransformationMatrix forInstance:(GLuint)i];
    }
    
    //[rockModel lock];
    //[self.instanceableModels addObject:rockModel];
    
    // TREE SETUP
    NSUInteger numb = [deviceName() isEqualToString:@"iPad5,3"] ? 75 : 50;
    for (NSUInteger i = 0; i < numb; i++) {
        GLfloat x = MathUtils_RandomFloat(-60, 40) + TERRAIN_SIZE/2.;
        GLfloat z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        GLKVector3 position = GLKVector3Make(x, [self.terrain getHeightAtWorldX:x worldZ:z] - 0.5, z);
        
        GLfloat rot = MathUtils_RandomFloat(0.0, 360);
        Entity *entity = [Entity entityWithTexturedModel:treeModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, rot, 0.0)
                                                andScale:MathUtils_RandomFloat(0.3, 0.8)];
        
        entity.model.texture.shineDamper = 0;
        entity.model.texture.reflectivity = 0;
        
        [self.entities addObject:entity];
        //[treeModel updateTransformationMatrix:entity.currentTransformationMatrix forInstance:(GLuint)i];
    }
    
    //[treeModel lock];
    //[self.instanceableModels addObject:treeModel];
    
    // GRASS SETUP
    numb = [deviceName() isEqualToString:@"iPad5,3"] ? 850 : 650;
    for (NSUInteger i = 0; i < numb; i++) {
        GLfloat x = MathUtils_RandomFloat(-80, 20) + TERRAIN_SIZE/2.;
        GLfloat z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        GLKVector3 position = GLKVector3Make(x, [self.terrain getHeightAtWorldX:x worldZ:z] - 0.3, z);
        
        Entity *entity = [Entity entityWithTexturedModel:grassModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, MathUtils_RandomFloat(0.0, 360.0), 0.0)
                                                andScale:MathUtils_RandomFloat(1.0, 1.3)];
        
        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = 0;
        
        [self.entities addObject:entity];
    }
    
    // FLOWER / FERN SETUP
    for (NSUInteger i = 0; i < 80; i++) {
        GLfloat x = MathUtils_RandomFloat(-60, 40) + TERRAIN_SIZE/2.;
        GLfloat z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        GLKVector3 position = GLKVector3Make(x, [self.terrain getHeightAtWorldX:x worldZ:z], z);
        
        BOOL isFlower = MathUtils_RandomBoolProb(.3);
        GLuint texIndex = !isFlower ? (GLuint)floorf(MathUtils_RandomFloat(0, 3)) : 0;
        Entity *entity = [Entity entityWithTexturedModel:isFlower ? flowerModel : fernModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, MathUtils_RandomFloat(0.0, 360.0), 0.0)
                                                   scale:isFlower ? 1.0 : 0.35
                                         andTextureIndex:texIndex];
        
        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = 0;
        
        [self.entities addObject:entity];
    }
    
    
    GLKVector3 sunPos1 = GLKVector3Make(TERRAIN_SIZE/2.0 + 30, 100.0, -TERRAIN_SIZE/2.0 - 10);
    
    [self.lights addObject:[Light lightWithPosition:sunPos1
                                           andColor:GLKVector3Make(0.5, 0.5, 0.5)]];
    
    GLuint posCount = 3;
    GLKVector3 positions[3] = {
        GLKVector3Make(TERRAIN_SIZE/2.0 - 50, 0, -TERRAIN_SIZE/2.0 - 40.0),
        GLKVector3Make(TERRAIN_SIZE/2.0, 0, -TERRAIN_SIZE/2.0 + 60.0),
        GLKVector3Make(farmEntity.position.x + 7.0, 0.0, farmEntity.position.z),
    };
    
    for (GLuint i = 0; i < posCount; i++) {
        GLKVector3 pos = positions[i];
        pos.y = [self.terrain getHeightAtWorldX:pos.x worldZ:pos.z];
        
        Entity *lamp = [Entity entityWithTexturedModel:lampModel
                                              position:pos
                                              rotation:MathUtils_ZeroRotation
                                              andScale:.4];
        
        [self.entities addObject:lamp];
        
        [self.lights addObject:[Light lightWithPosition:GLKVector3Make(pos.x, pos.y + 4.9f, pos.z)
                                                  color:GLKVector3Make(.8f, .7f, .0f)
                                         andAttenuation:GLKVector3Make(1.f, 0.01f, 0.002f)]];
    }
    
    self.renderer.skyColor = RGBAMake(.5, .5, .5, 1.);
    // self.renderer.fog = FogMake(0.010, 1.8);
    self.renderer.fog = kNoFog;
    
    self.renderer.skyboxRenderer.shader.rotation_speed = .5f;
    
    GLfloat x = TERRAIN_SIZE/2.0 + 80;
    GLfloat z = -TERRAIN_SIZE/2.0 - 106.3;
    
    self.water = [[WaterTile alloc] initWithX:x
                                            z:z
                                       height:-5.0
                                      andSize:68.];
    
    
#if WATER_DEBUG
    GUITexture *tex = [GUITexture textureWithTextureID:self.fbos.reflectionTexture
                                         textureTarget:GL_TEXTURE_2D
                                              position:GLKVector2Make(-0.75, -0.75)
                                              andScale:GLKVector2Make(0.25, 0.25)];
    GUITexture *tex2 = [GUITexture textureWithTextureID:self.fbos.refractionTexture
                                          textureTarget:GL_TEXTURE_2D
                                               position:GLKVector2Make(0.75, -0.75)
                                               andScale:GLKVector2Make(0.25, 0.25)];
    
    [self.guis addObject:tex];
    [self.guis addObject:tex2];
#endif
}

- (void)setupTerrainTexturePackage
{
    TerrainTexture *back = [[TerrainTexture alloc] initWithTextureInfo:[self.loader loadTexture:@"grass"
                                                                                  withExtension:@"jpg"]];
    
    TerrainTexture *rTex = [[TerrainTexture alloc] initWithTextureInfo:[self.loader loadTexture:@"mud"
                                                                                  withExtension:@"png"]];
    
    TerrainTexture *gTex = [[TerrainTexture alloc] initWithTextureInfo:[self.loader loadTexture:@"grassFlowers"
                                                                                  withExtension:@"png"]];
    
    TerrainTexture *bTex = [[TerrainTexture alloc] initWithTextureInfo:[self.loader loadTexture:@"asphalt"
                                                                                  withExtension:@"jpg"]];
    
    self.terrainTexturePack = [[TerrainTexturePackage alloc] initWithBackgroundTexture:back
                                                                              rTexture:rTex
                                                                              gTexture:gTex
                                                                              bTexture:bTex];
    
    self.terrainBlendMap = [[TerrainTexture alloc] initWithTextureInfo:[self.loader loadTexture:@"blendMap2" withExtension:@"png" flipped:YES] andTiling:NO];
}

#pragma mark GLKViewControllerDelegate

// This method gets called before the view renders
- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    if (self->_isMoving) {
        self.camera.yaw = self->_oldYaw + self->_movingDirectionX * 0.27;
        self.camera.pitch = self->_oldPitch + self->_movingDirectionY * 0.27;
        
        GLfloat yawRadians = MathUtils_DegToRad(self.camera.yaw);
        GLfloat pitchRadians = MathUtils_DegToRad(self.camera.pitch);
        
        GLfloat scalar = controller.timeSinceLastUpdate * 10;
        GLKVector3 move = GLKVector3Make(sinf(yawRadians) * scalar,
                                         -sinf(pitchRadians) * scalar,
                                         -cosf(yawRadians) * scalar);
        [self.camera move:move];
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
    
    /*for (InstanceableTexturedModel *model in self.instanceableModels) {
        [self.renderer processInstanceableModel:model];
    }*/
    
    [self.renderer processTerrain:self.terrain];
    [self.renderer processWaterTile:self.water];
    
    
    GLfloat distance = 2 * (self.camera.position.y - self.water.height);
    [self.camera move:GLKVector3Make(0, -distance, 0)];
    [self.camera invertPitch];
    
    [self.fbos bindReflectionFrameBuffer];
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:GLKVector4Make(0, 1, 0, -self.water.height + 0.5f)];
    
    [self.camera move:GLKVector3Make(0, distance, 0)];
    [self.camera invertPitch];
    
    [self.fbos bindRefractionFrameBuffer];
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:GLKVector4Make(0, -1, 0, self.water.height + 0.5f)];
    
    [self.glview bindDrawable];
    
    glDisable(GL_CLIP_DISTANCE0_APPLE);
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:GLKVector4Make(0, -1, 0, 100)];
    [self.renderer renderWaterWithCamera:self.camera andLight:self.lights[0]];
    #if WATER_DEBUG
        [self.renderer renderGUI:self.guis];
    #endif
    [self.renderer finishedFrame];
}

#pragma mark - Getters
- (GLKView *)glview
{
    return (GLKView *)self.view;
}

#pragma mark - Interaction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self->_isMoving = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    self->_startTouch = location;
    
    CGPoint diff = CGPointMake(location.x - self->_startTouch.x,
                               location.y - self->_startTouch.y);
    
    self->_movingDirectionX = diff.x;
    self->_movingDirectionY = diff.y;
    
    self->_oldPitch = self.camera.pitch;
    self->_oldYaw = self.camera.yaw;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    CGPoint diff = CGPointMake(location.x - self->_startTouch.x,
                               location.y - self->_startTouch.y);
    
    self->_movingDirectionX = diff.x;
    self->_movingDirectionY = diff.y;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self->_isMoving = NO;
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
