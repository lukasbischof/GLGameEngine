//
//  SkyboxRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "SkyboxRenderer.h"
#import "NSObject+class.h"

#define SIZE 100.f

/*const float vertices[] = {
    0.0, SIZE, 0.0,
    -SIZE, -SIZE, 0.0,
    SIZE, -SIZE, 0.0
};*/

const float vertices[] = {
    -SIZE,  SIZE, -SIZE,
    -SIZE, -SIZE, -SIZE,
    SIZE, -SIZE, -SIZE,
    SIZE, -SIZE, -SIZE,
    SIZE,  SIZE, -SIZE,
    -SIZE,  SIZE, -SIZE,
    
    -SIZE, -SIZE,  SIZE,
    -SIZE, -SIZE, -SIZE,
    -SIZE,  SIZE, -SIZE,
    -SIZE,  SIZE, -SIZE,
    -SIZE,  SIZE,  SIZE,
    -SIZE, -SIZE,  SIZE,
    
    SIZE, -SIZE, -SIZE,
    SIZE, -SIZE,  SIZE,
    SIZE,  SIZE,  SIZE,
    SIZE,  SIZE,  SIZE,
    SIZE,  SIZE, -SIZE,
    SIZE, -SIZE, -SIZE,
    
    -SIZE, -SIZE,  SIZE,
    -SIZE,  SIZE,  SIZE,
    SIZE,  SIZE,  SIZE,
    SIZE,  SIZE,  SIZE,
    SIZE, -SIZE,  SIZE,
    -SIZE, -SIZE,  SIZE,
    
    -SIZE,  SIZE, -SIZE,
    SIZE,  SIZE, -SIZE,
    SIZE,  SIZE,  SIZE,
    SIZE,  SIZE,  SIZE,
    -SIZE,  SIZE,  SIZE,
    -SIZE,  SIZE, -SIZE,
    
    -SIZE, -SIZE, -SIZE,
    -SIZE, -SIZE,  SIZE,
    SIZE, -SIZE, -SIZE,
    SIZE, -SIZE, -SIZE,
    -SIZE, -SIZE,  SIZE,
    SIZE, -SIZE,  SIZE
};

static inline NSString *bundleURL(NSString *file, NSString *ext) {
    return [[NSBundle mainBundle] pathForResource:file ofType:ext];
}

// Right(+x), Left(-x), Top(+y), Bottom(-y), Front(+z), Back(-z).
static inline NSArray<NSString *> *getTextureFiles() {
    return @[
        bundleURL(@"right", @"jpg"),
        bundleURL(@"left", @"jpg"),
        bundleURL(@"top", @"jpg"),
        bundleURL(@"bottom", @"jpg"),
        bundleURL(@"back", @"jpg"),
        bundleURL(@"front", @"jpg"),
    ];
};

@interface SkyboxRenderer ()

@property (strong, nonatomic) RawModel *cube;
@property (strong, nonatomic) GLKTextureInfo *cubeTexture;
@property (strong, nonatomic) SkyboxShader *shader;

@end

@implementation SkyboxRenderer

+ (SkyboxRenderer *)skyboxRendererWithLoader:(Loader *)loader
{
    return [[SkyboxRenderer alloc] initWithLoader:loader];
}

- (instancetype)initWithLoader:(Loader *)loader
{
    if ((self = [super init])) {
        FloatBuffer positions = FloatBufferCreateWithDataNoCopy(vertices, sizeof(vertices));
        self.cube = [loader createRawModelWithPositions:positions dimensions:3];
        
        if (!self.cube) {
            NSLog(@"<< ERROR [%@] >>: Can't create cube. Loader failure", [self className]);
            return nil;
        }
        
        NSArray *files = getTextureFiles();
        // NSLog(@"files: %@", files);
        self.cubeTexture = [loader loadCubeTexture:files];
        
        self.shader = [SkyboxShader skyboxShaderProgram];
    }
    
    return self;
}

- (void)updateProjectionMatrix:(GLKMatrix4)projMat
{
    [self.shader activate];
    [self.shader loadProjectionMatrix:projMat];
    [self.shader deactivate];
}

- (void)renderWithCamera:(Camera *)camera
{
    [self.shader activate];
    [self.shader loadViewMatrix:camera.viewMatrix];
    
    glBindVertexArray(self.cube.vaoID);
    glEnableVertexAttribArray(0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(self.cubeTexture.target, self.cubeTexture.name);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glDrawArrays(GL_TRIANGLES, 0, self.cube.vertexCount);
    glDisableVertexAttribArray(0);
    glBindVertexArray(0);
    glEnable(GL_DEPTH_TEST);
    
    [self.shader deactivate];
}

@end

