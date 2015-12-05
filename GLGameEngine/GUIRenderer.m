//
//  GUIRenderer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 05.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "GUIRenderer.h"
#import "MathUtils.h"

const float quad2DVertices[] = {
    -1,  1,
    -1, -1,
     1,  1,
     1, -1
};

@interface GUIRenderer ()

@property (strong, nonatomic) RawModel *quadModel;
@property (strong, nonatomic) GUIShader *shader;

@end

@implementation GUIRenderer

+ (GUIRenderer *)rendererWithLoader:(Loader *)loader
{
    return [[GUIRenderer alloc] initWithLoader:loader];
}

- (instancetype)init
{
    return [self initWithLoader:[Loader loader]];
}

- (instancetype)initWithLoader:(Loader *)loader
{
    if ((self = [super init])) {
        FloatBuffer positions = FloatBufferCreateWithDataNoCopy(quad2DVertices, sizeof(quad2DVertices));
        self.quadModel = [loader createRawModelWithPositions:positions dimensions:2];
        self.shader = [GUIShader GUIShaderProgram];
    }
    
    return self;
}

- (void)render:(NSArray<GUITexture *> *)guis
{
    [self.shader activate];
    [self.quadModel bindVAO];
    //glEnableVertexAttribArray(0);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_DEPTH_TEST);
    
    for (GUITexture *gui in guis) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(gui.textureTarget, gui.textureID);
        [self.shader loadTransformationMatrix:MathUtils_CreateGUITransformationMatrix(gui.position, gui.scale)];
        glDrawArrays(GL_TRIANGLE_STRIP, 0, self.quadModel.vertexCount);
    }
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    //glDisableVertexAttribArray(0);
    [self.quadModel unbindVAO];
    [self.shader deactivate];
}

- (void)cleanUp
{
    [self.shader cleanUp];
}

@end
