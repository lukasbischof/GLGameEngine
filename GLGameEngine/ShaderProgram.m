//
//  ShaderProgram.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"
#import "MetalContext.h"

@interface ShaderProgram ()

@property (strong, nonatomic, readwrite) id<MTLRenderPipelineState> pipelineState;

@end

@implementation ShaderProgram

#pragma mark - Init
- (instancetype)init
{
    return [self initWithVertexFunctionName:@"" andFragmentFunctionName:@""];
}

- (instancetype)initWithVertexFunctionName:(NSString *)vertexName andFragmentFunctionName:(NSString *)fragmentName
{
    if ((self = [super init])) {
        MetalContext *context = [MetalContext sharedContext];

        id<MTLFunction> vertexFunction = [context.library newFunctionWithName:vertexName];
        if (!vertexFunction) {
            NSLog(@"ERROR: CANT LOAD VERTEX FUNCTION %@", vertexName);
            return nil;
        }

        id<MTLFunction> fragmentFunction = [context.library newFunctionWithName:fragmentName];
        if (!fragmentFunction) {
            NSLog(@"ERROR: CANT LOAD FRAGMENT FUNCTION %@", fragmentName);
            return nil;
        }

        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.label = NSStringFromClass([self class]);
        descriptor.vertexFunction = vertexFunction;
        descriptor.fragmentFunction = fragmentFunction;
        descriptor.vertexDescriptor = [self createVertexDescriptor];
        // All passes (water FBOs + drawable) share these formats, so one
        // pipeline per program is valid everywhere, like the GL program was.
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
        descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

        [self configurePipelineDescriptor:descriptor];

        NSError *error = nil;
        _pipelineState = [context.device newRenderPipelineStateWithDescriptor:descriptor error:&error];

        if (!_pipelineState) {
            NSLog(@"ERROR: FAILED TO CREATE PIPELINE STATE %@: %@", descriptor.label, error);
            return nil;
        }

        NSLog(@"created pipeline state %@", descriptor.label);
    }

    return self;
}

#pragma mark - abstract methods
- (MTLVertexDescriptor *)createVertexDescriptor __attribute__((noreturn))
{
    NSAssert(false, @"%s MUST BE IMPLEMENTED BY A SUBCLASS.", __PRETTY_FUNCTION__);
    abort();
}

- (void)configurePipelineDescriptor:(MTLRenderPipelineDescriptor *)descriptor
{
    // default: no blending, nothing to configure
}

- (void)uploadUniforms
{
    NSAssert(false, @"%s MUST BE IMPLEMENTED BY A SUBCLASS.", __PRETTY_FUNCTION__);
}

#pragma mark - binding
- (void)activate
{
    MetalContext *context = [MetalContext sharedContext];

    // Defensive: only meaningful inside a staged render pass. (The load…:
    // methods just write into the uniform structs and don't need the pipeline.)
    if (!context.canEncode)
        return;

    [context.currentEncoder setRenderPipelineState:self.pipelineState];
}

#pragma mark - Memory management
- (void)cleanUp
{
    self.pipelineState = nil;
}

@end
