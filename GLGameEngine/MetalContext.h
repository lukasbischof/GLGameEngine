//
//  MetalContext.h
//  GLGameEngine
//
//  Owns the Metal device, command queue and the per-frame command buffer /
//  render command encoder. Render passes are staged as descriptors and the
//  encoder is created lazily on first use, so a pass's clear values can
//  still be configured after the pass is staged but before its first draw.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalContext : NSObject

@property (strong, nonatomic, readonly) id<MTLDevice> device;
@property (strong, nonatomic, readonly) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic, readonly) id<MTLLibrary> library;

@property (strong, nonatomic, readonly, nullable) id<MTLCommandBuffer> currentCommandBuffer;

// Prebuilt depth-stencil states: depth testing on (less + write) and off
@property (strong, nonatomic, readonly) id<MTLDepthStencilState> dsLessWrite;
@property (strong, nonatomic, readonly) id<MTLDepthStencilState> dsAlwaysNoWrite;

// Prebuilt sampler states (the three sampling configurations used by the engine)
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerMipRepeat;
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerLinearClamp;
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerNearestClamp;

// Back-face culling toggle; applies to the current encoder immediately
@property (assign, nonatomic) BOOL cullingEnabled;

+ (MetalContext *)sharedContext;

// Per-frame lifecycle
- (void)beginFrame;

// Ends the current encoder and stages the next render pass. The descriptor's
// clear values may still be changed until the pass's first draw.
- (void)stagePassDescriptor:(MTLRenderPassDescriptor *)passDescriptor;
@property (strong, nonatomic, readonly, nullable) MTLRenderPassDescriptor *stagedPassDescriptor;

// Lazily creates the encoder for the staged pass descriptor.
@property (strong, nonatomic, readonly) id<MTLRenderCommandEncoder> currentEncoder;

// YES when encoding is possible (an encoder exists or a pass is staged)
@property (assign, nonatomic, readonly) BOOL canEncode;

- (void)endCurrentEncoder;
- (void)endFrameAndPresentDrawable:(nullable id<MTLDrawable>)drawable;

@end

NS_ASSUME_NONNULL_END
