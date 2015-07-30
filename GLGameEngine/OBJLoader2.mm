//
//  OBJLoader2.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 18.06.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "OBJLoader2.h"
#import <simd/simd.h>
#include <vector>

#define NO_RETURN __attribute__((noreturn))
#define report_error(e) ([self reportError:(e)])

@interface OBJLoader2 ()

@end

@implementation OBJLoader2

- (instancetype)initWithURL:(NSURL *)url texture:(ModelTexture *)texture andLoader:(Loader *)loader
{
    if ((self = [super init])) {
        if ([MDLAsset canImportFileExtension:@"obj"]) {
            MDLAsset *asset = [[MDLAsset alloc] initWithURL:url];
            NSLog(@"asset: %@", asset);
            
            MDLMesh *mesh = (MDLMesh *)[asset objectAtIndex:0];
            
            
            (^void(void){})();
        } else {
            report_error(@"Model I/O doesn't support obj?");
        }
    }
    
    return self;
}

- (void)reportError:(nonnull NSString *)error NO_RETURN
{
    NSAssert(NO, @"%@", error);
    abort();
}

@end
