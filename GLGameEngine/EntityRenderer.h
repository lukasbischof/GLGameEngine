//
//  Renderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexturedModel.h"
#import "Entity.h"
#import "StaticShaderProgram.h"
#import "Buffer.h"


@interface EntityRenderer : NSObject

- (instancetype)initWithShaderProgram:(StaticShaderProgram *)shader;

+ (EntityRenderer *)rendererWithShaderProgram:(StaticShaderProgram *)shader;

/// program acitvation must be done before updating
- (void)render:(NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> *)entities withCamera:(Camera *)camera;
- (void)render:(Entity *)entity withShaderProgram:(StaticShaderProgram *)shader;

@end
