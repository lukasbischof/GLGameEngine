//
//  InstanceableTexturedModel.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 15.11.15.
//  Copyright © 2015 Lukas Bischof. All rights reserved.
//

#import "InstanceableTexturedModel.h"
#include <vector>
#include <stdio.h>
#include <iostream>

@implementation InstanceableTexturedModel {
    std::vector<GLKMatrix4> _matrices;
    GLuint _buffer;
}

- (instancetype)initWithRawModel:(RawModel *)rawModel andTexture:(ModelTexture *)texture
{
    if ((self = [super initWithRawModel:rawModel andTexture:texture])) {
        _instanceCount = 0;
        self->_matrices = std::vector<GLKMatrix4>();
    }
    
    return self;
}

- (void)updateTransformationMatrix:(GLKMatrix4)matrix forInstance:(GLuint)instanceID
{
    if (instanceID == self->_matrices.size()) {
        // add
        self->_matrices.push_back(matrix);
        _instanceCount++;
    } else if (instanceID > self->_matrices.size()) {
        std::cerr << "Invalid instance id " << instanceID << std::endl;
    } else {
        // update
        self->_matrices[instanceID] = matrix;
    }
}

- (void)lock
{
    if (self.instanceCount == 0) {
        NSLog(@"No Instances created!");
        return;
    }
    
    [self.rawModel bindVAO];
    glGenBuffers(1, &self->_buffer);
    [self bake];
    
    GLsizei vec4size = sizeof(GLKVector4);
    GLsizei mat4size = sizeof(GLKMatrix4);
    glVertexAttribPointer(3, 4, GL_FLOAT, GL_FALSE, mat4size, (GLvoid *)(0));
    glEnableVertexAttribArray(3);
    glVertexAttribPointer(4, 4, GL_FLOAT, GL_FALSE, mat4size, (GLchar *)NULL + (vec4size));
    glEnableVertexAttribArray(4);
    glVertexAttribPointer(5, 4, GL_FLOAT, GL_FALSE, mat4size, (GLchar *)NULL + (vec4size * 2));
    glEnableVertexAttribArray(5);
    glVertexAttribPointer(6, 4, GL_FLOAT, GL_FALSE, mat4size, (GLchar *)NULL + (vec4size * 3));
    glEnableVertexAttribArray(6);
    
    glVertexAttribDivisor(3, 1);
    glVertexAttribDivisor(4, 1);
    glVertexAttribDivisor(5, 1);
    glVertexAttribDivisor(6, 1);
    
    [self.rawModel unbindVAO];
}

- (void)bake
{
    glBindBuffer(GL_ARRAY_BUFFER, self->_buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLKMatrix4) * self->_matrices.size(), self->_matrices.data(), GL_STATIC_DRAW);
}

@end
