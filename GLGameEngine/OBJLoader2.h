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

@property (strong, nonatomic, nullable) TexturedModel *texturedModel;

/**
 @method loadModelsWithNames:textureNames:andLoader:
 @abstract Lädt mehrere Modelle 
 @param names   Die Namen der Dateien. OHNE .OBJ DATEIEXTENSION!
 @param textureNames    Die Namen der Texturen in gleicher Reihenfolge wie die Objektnamen. Das Array muss folgendes Array aufweisen: [[`name`, `extension`], [`name`, `extension`], ...]
 @param loader  Der Loader
 @return Ein Array mit den Modellen. In gleicher Reihenfolge wie die korrespondierenden Objektdateien
*/
+ (NSArray<TexturedModel *> *_Nullable)loadModelsWithNames:(NSArray<NSString *> *_Nonnull)names
                                              textureNames:(NSArray<NSArray<NSString *> *> *_Nonnull)textureNames
                                                 andLoader:(Loader *_Nonnull)loader;

+ (TexturedModel *_Nullable)loadModelWithName:(NSString *_Nonnull)name
                                      texture:(ModelTexture *_Nonnull)texture
                                    andLoader:(Loader *_Nonnull)loader;

/// Must initialize with resource data
- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithURL:(NSURL *__nonnull)url texture:(nonnull ModelTexture *)texture andLoader:(nonnull Loader *)loader NS_DESIGNATED_INITIALIZER;

@end
