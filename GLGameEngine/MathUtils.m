//
//  MathUtils.c
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <GameKit/GameKit.h>
#include "MathUtils.h"

const Rotation MathUtils_ZeroRotation = (Rotation) { 0.0, 0.0, 0.0 };

GLfloat MathUtils_DegToRad(GLfloat deg)
{
    return deg * M_PI / 180;
}

GLfloat MathUtils_RadToDeg(GLfloat rad)
{
    return rad * 180 / M_PI;
}

Rotation MathUtils_RotationMake(GLfloat rx, GLfloat ry, GLfloat rz)
{
    return (Rotation) {
        rx, ry, rz
    };
}

Rotation MathUtils_ConvertRotationToRadians(Rotation rotation)
{
    return (Rotation) {
        MathUtils_DegToRad(rotation.x),
        MathUtils_DegToRad(rotation.y),
        MathUtils_DegToRad(rotation.z)
    };
}

Rotation MathUtils_ConvertRotationToDegrees(Rotation rotation)
{
    return (Rotation) {
        MathUtils_RadToDeg(rotation.x),
        MathUtils_RadToDeg(rotation.y),
        MathUtils_RadToDeg(rotation.z)
    };
}

GLKMatrix4 MathUtils_CreateTransformationMatrixrXYZ(GLKVector3 translation, float rx, float ry, float rz, float scale)
{
    GLKMatrix4 matrix = GLKMatrix4Identity;
    
    matrix = GLKMatrix4Translate(matrix, translation.x, translation.y, translation.z);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(rx), 1, 0, 0);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(ry), 0, 1, 0);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(rz), 0, 0, 1);
    matrix = GLKMatrix4Scale(matrix, scale, scale, scale);
    
    return matrix;
}

GLKMatrix4 MathUtils_CreateTransformationMatrixr(GLKVector3 translation, Rotation rotation, float scale)
{
    GLKMatrix4 matrix = GLKMatrix4Identity;
    
    matrix = GLKMatrix4Translate(matrix, translation.x, translation.y, translation.z);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(rotation.x), 1, 0, 0);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(rotation.y), 0, 1, 0);
    matrix = GLKMatrix4Rotate(matrix, MathUtils_DegToRad(rotation.z), 0, 0, 1);
    matrix = GLKMatrix4Scale(matrix, scale, scale, scale);
    
    return matrix;
}

GLKMatrix3 MathUtils_CreateNormalMatrix(GLKMatrix4 transformationMatrix, GLKMatrix4 viewMatrix)
{
    bool isInvertible;
    GLKMatrix4 mvMatrix = GLKMatrix4Multiply(viewMatrix, transformationMatrix);
    GLKMatrix4 nMatrix = GLKMatrix4Invert(mvMatrix, &isInvertible);
    
    if (!isInvertible) {
        NSLog(@"<< ERROR >>: mvMatrix isn't invertible");
        return GLKMatrix3Identity;
    }
    
    nMatrix = GLKMatrix4Transpose(nMatrix);
    
    return GLKMatrix4GetMatrix3(nMatrix);
    
}

GLfloat MathUtils_RandomFloat(GLfloat min, GLfloat max)
{
    float diff = max - min;
    return (((GLfloat)[[GKARC4RandomSource sharedRandom] nextUniform]) * diff) + min;
}
