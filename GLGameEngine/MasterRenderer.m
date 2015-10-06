//
//  MasterRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.08.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "MasterRenderer.h"
#import "TexturedModel.h"
#import "Entity.h"

typedef NSMutableDictionary<TexturedModel *, NSMutableArray<Entity *> *> EntityMap;

@interface MasterRenderer ()

@property (strong, nonatomic, nonnull) EntityMap *entities;

@end

@implementation MasterRenderer

+ (MasterRenderer *)renderer
{
    return [[MasterRenderer alloc] init];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.shader = [StaticShaderProgram staticShaderProgram];
        self.renderer = [Renderer rendererWithShaderProgram:self.shader];
        
        _entities = [EntityMap dictionary];
    }
    
    return self;
}

- (void)updateProjectionForAspect:(float)aspect
{
    [self.renderer updateProjectionWithAspect:aspect forShader:self.shader];
}

#pragma mark - Rendering
- (void)renderWithLight:(Light *)light andCamera:(Camera *)camera
{
    [self.renderer prepare];
    [self.shader activate];
    
    [self.shader loadLight:light];
    [self.shader loadViewMatrix:[camera getViewMatrix]];
    
    [self.renderer render:self.entities withCamera:camera];
    
    [self.shader deactivate];
    [self clearEntities];
}

#pragma mark - Entity Map
- (void)processEntity:(Entity *)entity
{
    TexturedModel *entityModel = entity.model;
    NSMutableArray<Entity *> *batch = [self.entities objectForKey:entityModel];
    
    if (batch != nil) {
        [self.entities[entityModel] addObject:entity];
    } else {
        NSMutableArray<Entity *> *newBatch = [NSMutableArray array];
        [newBatch addObject:entity];
        
        [self.entities setObject:newBatch forKey:entityModel];
    }
}

- (void)clearEntities
{
    [self.entities removeAllObjects];
}

#pragma mark - Memory
- (void)cleanUp
{
    [self.shader cleanUp];
}

@end
