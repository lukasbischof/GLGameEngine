//
//  MetalContext.m
//  GLGameEngine
//

#import "MetalContext.h"

@interface MetalContext ()

@property (strong, nonatomic, readwrite) id<MTLDevice> device;
@property (strong, nonatomic, readwrite) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic, readwrite) id<MTLLibrary> library;
@property (strong, nonatomic, readwrite, nullable) id<MTLCommandBuffer> currentCommandBuffer;
@property (strong, nonatomic, readwrite, nullable) MTLRenderPassDescriptor *stagedPassDescriptor;
@property (strong, nonatomic, nullable) id<MTLRenderCommandEncoder> encoder;

@property (strong, nonatomic, readwrite) id<MTLDepthStencilState> dsLessWrite;
@property (strong, nonatomic, readwrite) id<MTLDepthStencilState> dsAlwaysNoWrite;

@property (strong, nonatomic, readwrite) id<MTLSamplerState> samplerMipRepeat;
@property (strong, nonatomic, readwrite) id<MTLSamplerState> samplerLinearClamp;
@property (strong, nonatomic, readwrite) id<MTLSamplerState> samplerNearestClamp;

@end

@implementation MetalContext

+ (MetalContext *)sharedContext
{
    static MetalContext *context = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[MetalContext alloc] init];
    });

    return context;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _device = MTLCreateSystemDefaultDevice();
        if (!_device) {
            NSLog(@"SORRY, METAL ISN'T AVAILABLE ON YOUR DEVICE :(");
            exit(EXIT_SUCCESS);
        }

        _commandQueue = [_device newCommandQueue];
        _library = [_device newDefaultLibrary];
        _cullingEnabled = YES;

        [self createDepthStencilStates];
        [self createSamplerStates];
    }

    return self;
}

- (void)createDepthStencilStates
{
    MTLDepthStencilDescriptor *descriptor = [[MTLDepthStencilDescriptor alloc] init];

    // glEnable(GL_DEPTH_TEST) + glDepthFunc(GL_LESS)
    descriptor.depthCompareFunction = MTLCompareFunctionLess;
    descriptor.depthWriteEnabled = YES;
    descriptor.label = @"less + write";
    self.dsLessWrite = [self.device newDepthStencilStateWithDescriptor:descriptor];

    // glDisable(GL_DEPTH_TEST) (disables both testing and writing)
    descriptor.depthCompareFunction = MTLCompareFunctionAlways;
    descriptor.depthWriteEnabled = NO;
    descriptor.label = @"always + no write";
    self.dsAlwaysNoWrite = [self.device newDepthStencilStateWithDescriptor:descriptor];
}

- (void)createSamplerStates
{
    MTLSamplerDescriptor *descriptor = [[MTLSamplerDescriptor alloc] init];

    // GLKTextureLoader with mipmaps: GL_LINEAR_MIPMAP_LINEAR / GL_LINEAR + GL_REPEAT
    descriptor.minFilter = MTLSamplerMinMagFilterLinear;
    descriptor.magFilter = MTLSamplerMinMagFilterLinear;
    descriptor.mipFilter = MTLSamplerMipFilterLinear;
    descriptor.sAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.tAddressMode = MTLSamplerAddressModeRepeat;
    descriptor.label = @"trilinear + repeat";
    self.samplerMipRepeat = [self.device newSamplerStateWithDescriptor:descriptor];

    // GL_LINEAR + GL_CLAMP_TO_EDGE (FBO color textures, cube maps)
    descriptor.mipFilter = MTLSamplerMipFilterNotMipmapped;
    descriptor.sAddressMode = MTLSamplerAddressModeClampToEdge;
    descriptor.tAddressMode = MTLSamplerAddressModeClampToEdge;
    descriptor.label = @"linear + clamp";
    self.samplerLinearClamp = [self.device newSamplerStateWithDescriptor:descriptor];

    // GL_NEAREST + GL_CLAMP_TO_EDGE (refraction depth texture)
    descriptor.minFilter = MTLSamplerMinMagFilterNearest;
    descriptor.magFilter = MTLSamplerMinMagFilterNearest;
    descriptor.label = @"nearest + clamp";
    self.samplerNearestClamp = [self.device newSamplerStateWithDescriptor:descriptor];
}

#pragma mark - Frame lifecycle
- (void)beginFrame
{
    self.currentCommandBuffer = [self.commandQueue commandBuffer];
}

- (void)stagePassDescriptor:(MTLRenderPassDescriptor *)passDescriptor
{
    [self endCurrentEncoder];
    self.stagedPassDescriptor = passDescriptor;
}

- (id<MTLRenderCommandEncoder>)currentEncoder
{
    if (self.encoder) {
        return self.encoder;
    }

    NSAssert(self.currentCommandBuffer, @"beginFrame must be called before encoding");
    NSAssert(self.stagedPassDescriptor, @"a render pass descriptor must be staged before encoding");

    self.encoder = [self.currentCommandBuffer renderCommandEncoderWithDescriptor:self.stagedPassDescriptor];

    // Global GL state from MasterRenderer: glFrontFace(GL_CCW) (Metal's default
    // winding is clockwise!), glCullFace(GL_BACK), glDepthFunc(GL_LESS).
    [self.encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [self.encoder setCullMode:self.cullingEnabled ? MTLCullModeBack : MTLCullModeNone];
    [self.encoder setDepthStencilState:self.dsLessWrite];

    return self.encoder;
}

- (BOOL)canEncode
{
    return self.currentCommandBuffer && (self.encoder || self.stagedPassDescriptor);
}

- (void)endCurrentEncoder
{
    if (self.encoder) {
        [self.encoder endEncoding];
        self.encoder = nil;
    }

    self.stagedPassDescriptor = nil;
}

- (void)endFrameAndPresentDrawable:(id<MTLDrawable>)drawable
{
    [self endCurrentEncoder];

    if (drawable) {
        [self.currentCommandBuffer presentDrawable:drawable];
    }

    [self.currentCommandBuffer commit];
    self.currentCommandBuffer = nil;
}

#pragma mark - Culling
- (void)setCullingEnabled:(BOOL)cullingEnabled
{
    _cullingEnabled = cullingEnabled;

    if (self.encoder) {
        [self.encoder setCullMode:cullingEnabled ? MTLCullModeBack : MTLCullModeNone];
    }
}

@end
