//
//  MasterRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.08.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticShaderProgram.h"
#import "Renderer.h"

@interface MasterRenderer : NSObject

@property (strong, nonatomic, nonnull) StaticShaderProgram *shader;
@property (strong, nonatomic, nonnull) Renderer *renderer;

+ (MasterRenderer *_Nonnull)renderer;

- (void)updateProjectionForAspect:(float)aspect;
- (void)processEntity:(Entity *_Nonnull)entity;
- (void)renderWithLight:(Light *_Nonnull)light andCamera:(Camera *_Nonnull)camera;
- (void)cleanUp;

@end
