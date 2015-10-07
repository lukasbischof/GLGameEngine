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

@interface MasterRenderer () {
    BOOL _pMatrixDirty;
    float _pMatrixAspect;
}

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
    _pMatrixDirty = true;
    _pMatrixAspect = aspect;
}

#pragma mark - Rendering
- (void)renderWithLight:(Light *)light andCamera:(Camera *)camera
{
    [self.renderer prepare];
    [self.shader activate];
    
    if (self->_pMatrixDirty) {
        [self.renderer updateProjectionWithAspect:self->_pMatrixAspect forShader:self.shader];
        self->_pMatrixDirty = false;
    }
    
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
