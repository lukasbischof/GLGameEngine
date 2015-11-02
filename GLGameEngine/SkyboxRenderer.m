//
//  SkyboxRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 02.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "SkyboxRenderer.h"
#import "NSObject+class.h"
#import "TimeController.h"

#define SIZE 100.f

static const GLfloat WHOLE_DAY_DURATION = 28;
static const GLfloat DAY_DURATION = 12;
static const GLfloat NIGHT_DURATION = 11;

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

static inline NSArray<NSString *> *getNightTextureFiles() {
    return @[
             bundleURL(@"nightRight", @"jpg"),
             bundleURL(@"nightLeft", @"jpg"),
             bundleURL(@"nightTop", @"jpg"),
             bundleURL(@"nightBottom", @"jpg"),
             bundleURL(@"nightBack", @"jpg"),
             bundleURL(@"nightFront", @"jpg"),
             ];
};

@interface SkyboxRenderer ()

@property (strong, nonatomic) RawModel *cube;
@property (strong, nonatomic) GLKTextureInfo *dayTexture;
@property (strong, nonatomic) GLKTextureInfo *nightTexture;

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
        self.dayTexture = [loader loadCubeTexture:files];
        self.nightTexture = [loader loadCubeTexture:getNightTextureFiles()];
        
        self.shader = [SkyboxShader skyboxShaderProgram];
        [self.shader activate];
        [self.shader loadTextureUnits];
        [self.shader deactivate];
    }
    
    return self;
}

- (void)updateProjectionMatrix:(GLKMatrix4)projMat
{
    [self.shader activate];
    [self.shader loadProjectionMatrix:projMat];
    [self.shader deactivate];
}

- (void)updateFogColor:(GLKVector3)fogColor
{
    [self.shader activate];
    [self.shader loadFogColor:fogColor];
    [self.shader deactivate];
}

- (void)renderWithCamera:(Camera *)camera
{
    [self.shader activate];
    [self.shader loadViewMatrix:camera.viewMatrix];
    
    glBindVertexArray(self.cube.vaoID);
    glEnableVertexAttribArray(0);
    
    [self bindTextures];
    
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glDrawArrays(GL_TRIANGLES, 0, self.cube.vertexCount);
    glDisableVertexAttribArray(0);
    glBindVertexArray(0);
    glEnable(GL_DEPTH_TEST);
    
    [self.shader deactivate];
}

- (void)bindTextures
{
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(self.dayTexture.target, self.dayTexture.name);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(self.nightTexture.target, self.nightTexture.name);
    
    [self.shader loadBlendFactor:[self getBlendFactor]];
}

- (GLfloat)getBlendFactor
{
    GLfloat currentTime = fmodf([TimeController sharedController].passedTime, WHOLE_DAY_DURATION);
    GLfloat transitionPeriod = (WHOLE_DAY_DURATION - DAY_DURATION - NIGHT_DURATION) / 2;
    
    if (currentTime < DAY_DURATION) {
        return 0.0;
    } else if (currentTime < DAY_DURATION + transitionPeriod) {
        return (currentTime - DAY_DURATION) / transitionPeriod;
    } else if (currentTime < DAY_DURATION + transitionPeriod + NIGHT_DURATION) {
        return 1.0;
    } else {
        return 1. - ((currentTime - (WHOLE_DAY_DURATION - transitionPeriod)) / transitionPeriod);
    }
}

@end

