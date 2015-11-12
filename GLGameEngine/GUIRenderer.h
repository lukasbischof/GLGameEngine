//
//  GUIRenderer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Loader.h"
#import "GUITexture.h"
#import "GUIShader.h"

NS_ASSUME_NONNULL_BEGIN
@interface GUIRenderer : NSObject

+ (GUIRenderer *)rendererWithLoader:(Loader *)loader;

- (instancetype)initWithLoader:(Loader *)loader NS_DESIGNATED_INITIALIZER;

- (void)render:(NSArray<GUITexture *> *)guis;
- (void)cleanUp;

@end
NS_ASSUME_NONNULL_END
