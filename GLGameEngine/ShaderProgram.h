//
//  ShaderProgram.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "ShaderTypes.h"

#ifndef MAX_LIGHTS
#define MAX_LIGHTS 4
#endif

/*!
 @class ShaderProgram
 @brief abstract class that represents a shader program: a Metal render
        pipeline state (the former GL program) plus the uniform values the
        subclasses accumulate via their load…: methods (the former glUniform
        state, which persists across draws exactly like it did per program).
*/
@interface ShaderProgram : NSObject

@property (strong, nonatomic, readonly) id<MTLRenderPipelineState> pipelineState;

- (instancetype)initWithVertexFunctionName:(NSString *)vertexName
                   andFragmentFunctionName:(NSString *)fragmentName NS_DESIGNATED_INITIALIZER;

// Needs to be implemented by subclasses (replaces bindAttributes / getAllUniformLocations)
- (MTLVertexDescriptor *)createVertexDescriptor;

// Optional subclass hook for pipeline configuration (e.g. blending)
- (void)configurePipelineDescriptor:(MTLRenderPipelineDescriptor *)descriptor;

// Writes the accumulated uniform structs onto the current render command
// encoder. Called immediately before each draw call.
- (void)uploadUniforms;

// "Binds" the program; sets the pipeline state on the current encoder
- (void)activate;

- (void)cleanUp;

@end
