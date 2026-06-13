//
//  WaterFrameBuffers.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 08.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "WaterFrameBuffers.h"
#import "MetalContext.h"

static const NSUInteger REFLECTION_WIDTH = 512;
static const NSUInteger REFLECTION_HEIGHT = 512;

static const NSUInteger REFRACTION_WIDTH = 512;
static const NSUInteger REFRACTION_HEIGHT = 512;

@interface WaterFrameBuffers ()

@property (strong, nonatomic, readwrite) id<MTLTexture> reflectionTexture;
@property (strong, nonatomic, readwrite) id<MTLTexture> refractionTexture;
@property (strong, nonatomic, readwrite) id<MTLTexture> refractionDepthTexture;

@end

@implementation WaterFrameBuffers {
    id<MTLTexture> _reflectionDepthBuffer;

    MTLRenderPassDescriptor *_reflectionPassDescriptor;
    MTLRenderPassDescriptor *_refractionPassDescriptor;
}

+ (WaterFrameBuffers *)frameBuffers
{
    return [[WaterFrameBuffers alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self initReflectionFrameBuffer];
        [self initRefractionFrameBuffer];
    }

    return self;
}

- (void)initReflectionFrameBuffer
{
    self.reflectionTexture = [self createTextureAttachmentWithWidth:REFLECTION_WIDTH andHeight:REFLECTION_HEIGHT];
    _reflectionDepthBuffer = [self createDepthBufferAttachmentWithWidth:REFLECTION_WIDTH andHeight:REFLECTION_HEIGHT];

    _reflectionPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    _reflectionPassDescriptor.colorAttachments[0].texture = self.reflectionTexture;
    _reflectionPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    _reflectionPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    _reflectionPassDescriptor.depthAttachment.texture = _reflectionDepthBuffer;
    _reflectionPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    _reflectionPassDescriptor.depthAttachment.storeAction = MTLStoreActionDontCare;

    if (!self.reflectionTexture || !_reflectionDepthBuffer) {
        NSLog(@"Can't init reflection frame buffer");
    }
}

- (void)initRefractionFrameBuffer
{
    self.refractionTexture = [self createTextureAttachmentWithWidth:REFRACTION_WIDTH andHeight:REFRACTION_HEIGHT];
    self.refractionDepthTexture = [self createDepthTextureAttachmentWithWidth:REFRACTION_WIDTH andHeight:REFRACTION_HEIGHT];

    _refractionPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    _refractionPassDescriptor.colorAttachments[0].texture = self.refractionTexture;
    _refractionPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    _refractionPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    _refractionPassDescriptor.depthAttachment.texture = self.refractionDepthTexture;
    _refractionPassDescriptor.depthAttachment.loadAction = MTLLoadActionClear;
    // the depth texture is sampled by the water shader in the main pass
    _refractionPassDescriptor.depthAttachment.storeAction = MTLStoreActionStore;

    if (!self.refractionTexture || !self.refractionDepthTexture) {
        NSLog(@"Can't init refraction frame buffer");
    }
}

- (void)bindReflectionFrameBuffer
{
    [[MetalContext sharedContext] stagePassDescriptor:_reflectionPassDescriptor];
}

- (void)bindRefractionFrameBuffer
{
    [[MetalContext sharedContext] stagePassDescriptor:_refractionPassDescriptor];
}

- (id<MTLTexture>)createTextureAttachmentWithWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
    // GL_RGB8 color attachment, GL_LINEAR + GL_CLAMP_TO_EDGE (sampler state now).
    // BGRA8 to match the drawable, so every pipeline is valid in all passes.
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                          width:width
                                                                                         height:height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    descriptor.storageMode = MTLStorageModePrivate;

    return [[MetalContext sharedContext].device newTextureWithDescriptor:descriptor];
}

- (id<MTLTexture>)createDepthTextureAttachmentWithWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
    // GL_DEPTH_COMPONENT32F depth texture, sampled with GL_NEAREST
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                                          width:width
                                                                                         height:height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    descriptor.storageMode = MTLStorageModePrivate;

    return [[MetalContext sharedContext].device newTextureWithDescriptor:descriptor];
}

- (id<MTLTexture>)createDepthBufferAttachmentWithWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
    // GL_DEPTH_COMPONENT24 renderbuffer (never sampled)
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                                                          width:width
                                                                                         height:height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageRenderTarget;
    descriptor.storageMode = MTLStorageModePrivate;

    return [[MetalContext sharedContext].device newTextureWithDescriptor:descriptor];
}

- (void)cleanUp
{
    self.reflectionTexture = nil;
    self.refractionTexture = nil;
    self.refractionDepthTexture = nil;
    _reflectionDepthBuffer = nil;
    _reflectionPassDescriptor = nil;
    _refractionPassDescriptor = nil;
}

@end
