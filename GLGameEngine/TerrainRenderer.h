//
//  TerrainRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 07.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TerrainShader.h"
#import "Terrain.h"
#import "Camera.h"

@interface TerrainRenderer : NSObject

+ (TerrainRenderer *)terrainRendererWithShader:(TerrainShader *)shader;

- (instancetype)initWithShader:(TerrainShader *)shader;

- (void)render:(NSArray<Terrain *> *)terrains withCamera:(Camera *)camera;

@end
