//
//  MetalContext.h
//  GLGameEngine
//
//  Owns the Metal device, command queue and the per-frame command buffer /
//  render command encoder. Replaces the implicit global state of the
//  EAGLContext: "binding a framebuffer" becomes staging a render pass
//  descriptor; the encoder for it is created lazily on first use, so the
//  GL call order (bind FBO -> set clear color -> clear -> draw) keeps
//  working unchanged.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalContext : NSObject

@property (strong, nonatomic, readonly) id<MTLDevice> device;
@property (strong, nonatomic, readonly) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic, readonly) id<MTLLibrary> library;

@property (strong, nonatomic, readonly, nullable) id<MTLCommandBuffer> currentCommandBuffer;

// Depth-stencil states (the two glEnable/glDisable(GL_DEPTH_TEST) configurations)
@property (strong, nonatomic, readonly) id<MTLDepthStencilState> dsLessWrite;
@property (strong, nonatomic, readonly) id<MTLDepthStencilState> dsAlwaysNoWrite;

// Sampler states (the three glTexParameteri configurations used by the engine)
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerMipRepeat;
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerLinearClamp;
@property (strong, nonatomic, readonly) id<MTLSamplerState> samplerNearestClamp;

// glEnable/glDisable(GL_CULL_FACE) replacement; applies to the current encoder immediately
@property (assign, nonatomic) BOOL cullingEnabled;

+ (MetalContext *)sharedContext;

// Per-frame lifecycle
- (void)beginFrame;

// "glBindFramebuffer": ends the current encoder and stages the next pass.
// The descriptor's clear values may still be changed until the first draw.
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
