//
//  InstanceableTexturedModel.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "TexturedModel.h"

@interface InstanceableTexturedModel : TexturedModel

@property (assign, nonatomic, readonly) GLuint instanceCount;

- (void)updateTransformationMatrix:(GLKMatrix4)matrix forInstance:(GLuint)instanceID;
- (void)lock;
- (void)bake;

@end
