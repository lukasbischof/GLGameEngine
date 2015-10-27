//
//  TerrainTexturePackage.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 27.10.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TerrainTexture.h"

@interface TerrainTexturePackage : NSObject

@property (strong, nonatomic) TerrainTexture *backgroundTexture;
@property (strong, nonatomic) TerrainTexture *rTexture;
@property (strong, nonatomic) TerrainTexture *gTexture;
@property (strong, nonatomic) TerrainTexture *bTexture;

- (instancetype)initWithBackgroundTexture:(TerrainTexture *)backgroundTexture
                                 rTexture:(TerrainTexture *)rTexture
                                 gTexture:(TerrainTexture *)gTexture
                                 bTexture:(TerrainTexture *)bTexture;

@end
