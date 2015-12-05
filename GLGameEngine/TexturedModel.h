//
//  TexturedModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RawModel.h"
#import "ModelTexture.h"

@interface TexturedModel : NSObject <NSCopying>

@property (strong, nonatomic, readonly) RawModel *rawModel;
@property (strong, nonatomic, readonly) ModelTexture *texture;
@property (strong, nonatomic) NSUUID *UUID;
@property (strong, nonatomic) NSString *debugLabel;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRawModel:(RawModel *)rawModel andTexture:(ModelTexture *)texture NS_DESIGNATED_INITIALIZER;

@end
