//
//  Terrain.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import "RawModel.h"
#import "ModelTexture.h"
#import "Loader.h"

@interface Terrain : NSObject

@property (assign, nonatomic) GLfloat x;
@property (assign, nonatomic) GLfloat z;
@property (strong, nonatomic, readonly, nonnull) RawModel *model;
@property (strong, nonatomic, readonly, nonnull) ModelTexture *texture;

+ (Terrain *_Nonnull)terrainWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *_Nonnull)loader andTexture:(ModelTexture *_Nonnull)texture;

- (_Nonnull instancetype)initWithGridX:(GLint)gridX gridZ:(GLint)gridZ loader:(Loader *_Nonnull)loader andTexture:(ModelTexture *_Nonnull)texture;

@end
