//
//  OBJLoader.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TexturedModel.h"
#import "Loader.h"

@interface OBJLoader : NSObject

@property (strong, nonatomic) TexturedModel *texturedModel;

- (instancetype)initWithURL:(NSURL *)url texture:(ModelTexture *)texture andLoader:(Loader *)loader;

@end
