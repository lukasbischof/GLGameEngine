//
//  TerrainTexturePackage.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TerrainTexturePackage.h"

@implementation TerrainTexturePackage

- (instancetype)initWithBackgroundTexture:(TerrainTexture *)backgroundTexture rTexture:(TerrainTexture *)rTexture gTexture:(TerrainTexture *)gTexture bTexture:(TerrainTexture *)bTexture
{
    if ((self = [super init])) {
        self.backgroundTexture = backgroundTexture;
        self.rTexture = rTexture;
        self.gTexture = gTexture;
        self.bTexture = bTexture;
    }
    
    return self;
}

@end
