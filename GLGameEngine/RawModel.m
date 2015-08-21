//
//  RawModel.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "RawModel.h"

@implementation RawModel

+ (RawModel *)modelByCreatingVAOWithVertexCount:(GLuint)vertexCount
{
    GLuint vao = 0;
    glGenVertexArrays(1, &vao);
    RawModel *model = [[RawModel alloc] initWithVAOID:vao
                                       andVertexCount:vertexCount];
    
    return model;
}

- (instancetype)init
{
    if ((self = [self initWithVAOID:0 andVertexCount:0])) {
        
    }
    
    return self;
}

- (instancetype)initWithVAOID:(GLuint)vaoID andVertexCount:(GLuint)vertexCount
{
    if ((self = [super init])) {
        _vaoID = vaoID;
        self.vertexCount = vertexCount;
    }
    
    return self;
}

- (void)bindVAO
{
    glBindVertexArray(_vaoID);
}

- (void)unbindVAO
{
    glBindVertexArray(0);
}

@end
