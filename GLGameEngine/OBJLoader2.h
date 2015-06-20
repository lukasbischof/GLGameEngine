//
//  OBJLoader2.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 18.06.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ModelIO/ModelIO.h>
#import "TexturedModel.h"
#import "ModelTexture.h"
#import "Loader.h"

@interface OBJLoader2 : NSObject

@property (strong, nonatomic) TexturedModel *texturedModel;

- (instancetype)initWithURL:(NSURL *)url texture:(ModelTexture *)texture andLoader:(Loader *)loader;

@end
