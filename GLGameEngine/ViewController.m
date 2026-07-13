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
#import "OBJLoader2.h"
#import "Camera.h"
#import "MasterRenderer.h"
#import "UIView+aspect.h"
#import "TimeController.h"
#import "WaterFrameBuffers.h"
#import "MetalContext.h"
#import <sys/utsname.h>

#define WATER_DEBUG 0

NSString *deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@interface ViewController ()

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
    float _movingDirectionX;
    float _movingDirectionY;
    float _oldYaw;
    float _oldPitch;
    CGPoint _startTouch;
    CFTimeInterval _lastUpdateTime;
}

#pragma mark - View methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self initMetalContext];
    [self initGLObjects];

    self.glview.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillLayoutSubviews
{
    _pMatrixNeedsUpdate = YES;
}

#pragma mark - Rendering / Metal related methods
- (void)initMetalContext
{
    MetalContext *context = [MetalContext sharedContext];
    if (!context.device) {
        NSLog(@"SORRY, METAL ISN'T AVAILABLE ON YOUR DEVICE :(");
        exit(EXIT_FAILURE);
    } else {
        NSLog(@"Metal context initialized for %@.", deviceName());
    }

    // [[clip_distance]] requires MTLGPUFamilyApple4 (A11) or later. The
    // simulator's paravirtual GPU doesn't report Apple-family support but
    // inherits the host GPU's capabilities, so only assert on real devices.
#if !TARGET_OS_SIMULATOR
    NSAssert([context.device supportsFamily:MTLGPUFamilyApple4],
             @"This device doesn't support clip distances");
#endif

    self.glview.device = context.device;
    self.glview.colorPixelFormat = MTLPixelFormatBGRA8Unorm;     // GLKViewDrawableColorFormatRGBA8888
    self.glview.depthStencilPixelFormat = MTLPixelFormatDepth32Float; // GLKViewDrawableDepthFormat24
    self.glview.clearDepth = 1.0;
    self.glview.preferredFramesPerSecond = 60;

    _lastUpdateTime = 0;
}

- (void)tearDownMetal
{
    [self.loader cleanUp];
    [self.renderer cleanUp];
    [self.fbos cleanUp];
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

    [self.camera move:simd_make_float3(TERRAIN_SIZE/2.0 + 60, 8.1, -TERRAIN_SIZE/2.0 - 30)];

    [self setupEntities];

    [[TimeController sharedController] setStartDate:[NSDate date]];
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

    fernModel.texture.hasAlpha = YES;
    grassModel.texture.hasAlpha = YES;
    flowerModel.texture.hasAlpha = YES;
    fernModel.texture.numberOfRows = 2;

    // FARM
    Entity *farmEntity = [Entity entityWithTexturedModel:farmModel];
    farmEntity.position = simd_make_float3(TERRAIN_SIZE/2.0, 0.0, -TERRAIN_SIZE/2.0 - 40.0);
    farmEntity.scale = 0.3;
    //farmEntity.rotation = MathUtils_RotationMake(0.0, 125., 0.0);

    [self.entities addObject:farmEntity];

    // BOAT
    Entity *boatEntity = [Entity entityWithTexturedModel:boatModel];
    boatEntity.position = simd_make_float3(TERRAIN_SIZE/2.0 + 60, -8.0, -TERRAIN_SIZE/2.0 - 100.0);
    boatEntity.scale = 0.01;
    //farmEntity.rotation = MathUtils_RotationMake(0.0, 125., 0.0);

    [self.entities addObject:boatEntity];

    // WAGEN
    Entity *wagenEntity = [Entity entityWithTexturedModel:wagenModel];
    wagenEntity.position = (simd_float3){ TERRAIN_SIZE/2.0 + 10, 0.0, -TERRAIN_SIZE / 2.0 - 20 };
    wagenEntity.scale = 1.6;

    [self.entities addObject:wagenEntity];

    wagenEntity = [wagenEntity copy];
    wagenEntity.position = (simd_float3){ TERRAIN_SIZE/2.0 + 8.25, 0.0, -TERRAIN_SIZE / 2.0 - 20 };

    [self.entities addObject:wagenEntity];

    // ROCK SETUP
    for (NSUInteger i = 0; i < 50; i++) {
        float x = MathUtils_RandomFloat(-50, 50) + TERRAIN_SIZE/2.;
        float z = MathUtils_RandomFloat(0, -100) - TERRAIN_SIZE/2.;
        simd_float3 position = simd_make_float3(x, [self.terrain getHeightAtWorldX:x worldZ:z], z);
        Entity *entity = [Entity entityWithTexturedModel:rockModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, MathUtils_RandomFloat(0.0, 360.0), 0.0)
                                                andScale:MathUtils_RandomFloat(.3, .6)];

        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = .1;

        [self.entities addObject:entity];
    }

    // TREE SETUP
    NSUInteger numb = [deviceName() isEqualToString:@"iPad5,3"] ? 75 : 50;
    for (NSUInteger i = 0; i < numb; i++) {
        float x = MathUtils_RandomFloat(-60, 40) + TERRAIN_SIZE/2.;
        float z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        simd_float3 position = simd_make_float3(x, [self.terrain getHeightAtWorldX:x worldZ:z] - 0.5, z);

        float rot = MathUtils_RandomFloat(0.0, 360);
        Entity *entity = [Entity entityWithTexturedModel:treeModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, rot, 0.0)
                                                andScale:MathUtils_RandomFloat(0.3, 0.8)];

        entity.model.texture.shineDamper = 0;
        entity.model.texture.reflectivity = 0;

        [self.entities addObject:entity];
    }

    // GRASS SETUP
    numb = [deviceName() isEqualToString:@"iPad5,3"] ? 850 : 650;
    for (NSUInteger i = 0; i < numb; i++) {
        float x = MathUtils_RandomFloat(-80, 20) + TERRAIN_SIZE/2.;
        float z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        simd_float3 position = simd_make_float3(x, [self.terrain getHeightAtWorldX:x worldZ:z] - 0.3, z);

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
        float x = MathUtils_RandomFloat(-60, 40) + TERRAIN_SIZE/2.;
        float z = MathUtils_RandomFloat(-90, 50) - TERRAIN_SIZE/2.;
        simd_float3 position = simd_make_float3(x, [self.terrain getHeightAtWorldX:x worldZ:z], z);

        BOOL isFlower = MathUtils_RandomBoolProb(.3);
        uint32_t texIndex = !isFlower ? (uint32_t)floorf(MathUtils_RandomFloat(0, 3)) : 0;
        Entity *entity = [Entity entityWithTexturedModel:isFlower ? flowerModel : fernModel
                                                position:position
                                                rotation:MathUtils_RotationMake(0.0, MathUtils_RandomFloat(0.0, 360.0), 0.0)
                                                   scale:isFlower ? 1.0 : 0.35
                                         andTextureIndex:texIndex];

        entity.model.texture.shineDamper = 30;
        entity.model.texture.reflectivity = 0;

        [self.entities addObject:entity];
    }


    simd_float3 sunPos1 = simd_make_float3(TERRAIN_SIZE/2.0 + 30, 100.0, -TERRAIN_SIZE/2.0 - 10);

    [self.lights addObject:[Light lightWithPosition:sunPos1
                                           andColor:simd_make_float3(0.5, 0.5, 0.5)]];

    uint32_t posCount = 3;
    simd_float3 positions[3] = {
        simd_make_float3(TERRAIN_SIZE/2.0 - 50, 0, -TERRAIN_SIZE/2.0 - 40.0),
        simd_make_float3(TERRAIN_SIZE/2.0, 0, -TERRAIN_SIZE/2.0 + 60.0),
        simd_make_float3(farmEntity.position.x + 7.0, 0.0, farmEntity.position.z),
    };

    for (uint32_t i = 0; i < posCount; i++) {
        simd_float3 pos = positions[i];
        pos.y = [self.terrain getHeightAtWorldX:pos.x worldZ:pos.z];

        Entity *lamp = [Entity entityWithTexturedModel:lampModel
                                              position:pos
                                              rotation:MathUtils_ZeroRotation
                                              andScale:.4];

        [self.entities addObject:lamp];

        [self.lights addObject:[Light lightWithPosition:simd_make_float3(pos.x, pos.y + 4.9f, pos.z)
                                                  color:simd_make_float3(.8f, .7f, .0f)
                                         andAttenuation:simd_make_float3(1.f, 0.01f, 0.002f)]];
    }

    self.renderer.skyColor = RGBAMake(.5, .5, .5, 1.);
    // self.renderer.fog = FogMake(0.010, 1.8);
    self.renderer.fog = kNoFog;

    self.renderer.skyboxRenderer.shader.rotation_speed = .5f;

    float x = TERRAIN_SIZE/2.0 + 80;
    float z = -TERRAIN_SIZE/2.0 - 106.3;

    self.water = [[WaterTile alloc] initWithX:x
                                            z:z
                                       height:-5.0
                                      andSize:68.];


#if WATER_DEBUG
    GUITexture *tex = [GUITexture textureWithMTLTexture:self.fbos.reflectionTexture
                                               position:simd_make_float2(-0.75, -0.75)
                                               andScale:simd_make_float2(0.25, 0.25)];
    GUITexture *tex2 = [GUITexture textureWithMTLTexture:self.fbos.refractionTexture
                                                position:simd_make_float2(0.75, -0.75)
                                                andScale:simd_make_float2(0.25, 0.25)];

    [self.guis addObject:tex];
    [self.guis addObject:tex2];
#endif
}

- (void)setupTerrainTexturePackage
{
    TerrainTexture *back = [[TerrainTexture alloc] initWithMTLTexture:[self.loader loadTexture:@"grass"
                                                                                 withExtension:@"jpg"]];

    TerrainTexture *rTex = [[TerrainTexture alloc] initWithMTLTexture:[self.loader loadTexture:@"mud"
                                                                                 withExtension:@"png"]];

    TerrainTexture *gTex = [[TerrainTexture alloc] initWithMTLTexture:[self.loader loadTexture:@"grassFlowers"
                                                                                 withExtension:@"png"]];

    TerrainTexture *bTex = [[TerrainTexture alloc] initWithMTLTexture:[self.loader loadTexture:@"asphalt"
                                                                                 withExtension:@"jpg"]];

    self.terrainTexturePack = [[TerrainTexturePackage alloc] initWithBackgroundTexture:back
                                                                              rTexture:rTex
                                                                              gTexture:gTex
                                                                              bTexture:bTex];

    self.terrainBlendMap = [[TerrainTexture alloc] initWithMTLTexture:[self.loader loadTexture:@"blendMap2" withExtension:@"png" flipped:YES] andTiling:NO];
}

#pragma mark MTKViewDelegate

// The former glkViewControllerUpdate: -- called before each render
- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate
{
    if (self->_isMoving) {
        self.camera.yaw = self->_oldYaw + self->_movingDirectionX * 0.27;
        self.camera.pitch = self->_oldPitch + self->_movingDirectionY * 0.27;

        float yawRadians = MathUtils_DegToRad(self.camera.yaw);
        float pitchRadians = MathUtils_DegToRad(self.camera.pitch);

        float scalar = timeSinceLastUpdate * 10;
        simd_float3 move = simd_make_float3(sinf(yawRadians) * scalar,
                                         -sinf(pitchRadians) * scalar,
                                         -cosf(yawRadians) * scalar);
        [self.camera move:move];
    }
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _pMatrixNeedsUpdate = YES;
}

- (void)drawInMTKView:(MTKView *)view
{
    // GLKViewController's update/draw split: timeSinceLastUpdate is 0 on the
    // first frame, then the time between draws
    CFTimeInterval now = CACurrentMediaTime();
    NSTimeInterval timeSinceLastUpdate = (_lastUpdateTime == 0) ? 0 : now - _lastUpdateTime;
    _lastUpdateTime = now;

    [self updateWithTimeSinceLastUpdate:timeSinceLastUpdate];

    [[MetalContext sharedContext] beginFrame];

    if (_pMatrixNeedsUpdate) {
        [self.renderer updateProjectionForAspect:[self glview].aspect];
        _pMatrixNeedsUpdate = NO;
    }

    for (Entity *entity in self.entities) {
        [self.renderer processEntity:entity];
    }

    [self.renderer processTerrain:self.terrain];
    [self.renderer processWaterTile:self.water];


    float distance = 2 * (self.camera.position.y - self.water.height);
    [self.camera move:simd_make_float3(0, -distance, 0)];
    [self.camera invertPitch];

    [self.fbos bindReflectionFrameBuffer];
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:simd_make_float4(0, 1, 0, -self.water.height + 0.5f)];

    [self.camera move:simd_make_float3(0, distance, 0)];
    [self.camera invertPitch];

    [self.fbos bindRefractionFrameBuffer];
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:simd_make_float4(0, -1, 0, self.water.height + 0.5f)];

    [self bindDrawable];

    // clipping stays active; this plane never clips visible geometry
    [self.renderer renderWithLights:self.lights camera:self.camera andClippingPlane:simd_make_float4(0, -1, 0, 100)];
    [self.renderer renderWaterWithCamera:self.camera andLight:self.lights[0]];
    #if WATER_DEBUG
        [self.renderer renderGUI:self.guis];
    #endif
    [self.renderer finishedFrame];

    [[MetalContext sharedContext] endFrameAndPresentDrawable:view.currentDrawable];
}

// The former [self.glview bindDrawable]: stages the drawable's render pass
- (void)bindDrawable
{
    [[MetalContext sharedContext] stagePassDescriptor:self.glview.currentRenderPassDescriptor];
}

#pragma mark - Getters
- (MTKView *)glview
{
    return (MTKView *)self.view;
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

        [self tearDownMetal];
    }
}

- (void)dealloc
{
    [self tearDownMetal];
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
