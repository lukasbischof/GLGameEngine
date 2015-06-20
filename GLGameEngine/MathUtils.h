//
//  MathUtils.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 30.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#ifndef __GLGameEngine__MathUtils__
#define __GLGameEngine__MathUtils__

#include <stdio.h>
#import <GLKit/GLKit.h>
#import "Buffer.h"

struct MathUtils_Rotation {
    GLfloat x;
    GLfloat y;
    GLfloat z;
};
typedef struct MathUtils_Rotation Rotation;

EXPORT
Rotation const MathUtils_ZeroRotation;

EXPORT
Rotation MathUtils_RotationMake(GLfloat rx, GLfloat ry, GLfloat rz);

/**
 @function MathUtils_ConvertRotationToRadians
 @abstract Konvertiert die Parameter eine Rotations-Struktur zu Bogenmassen
*/
EXPORT
Rotation MathUtils_ConvertRotationToRadians(Rotation rotation);

/**
 @function MathUtils_ConvertRotationToDegrees
 @abstract Konvertiert die Parameter eine Rotations-Struktur zu Grad
 */
EXPORT
Rotation MathUtils_ConvertRotationToDegrees(Rotation rotation);

EXPORT
GLfloat MathUtils_DegToRad(GLfloat deg);

EXPORT
GLfloat MathUtils_RadToDeg(GLfloat rad);

/**
 @function MathUtils_CreateTransformationMatrixrXYZ
 @abstract Generiert eine neue Transformationsmatrix
 @param translation Die translation in x,y und z Richtung
 @param rx  Die Rotation um die X-Achse in Radians
 @param ry  Die Rotation um die Y-Achse in Radians
 @param rz  Die Rotation um die Z-Achse in Radians
 @param scale   Die Skalation, die proportional auf das Objekt wirkt
 @return Die neue Transformationsmatrix
*/
EXPORT
GLKMatrix4 MathUtils_CreateTransformationMatrixrXYZ(GLKVector3 translation, float rx, float ry, float rz, float scale);

/**
 @function MathUtils_CreateTransformationMatrixr
 @abstract Generiert eine neue Transformationsmatrix
 @param translation Die translation in x,y und z Richtung
 @param rotation    Die Rotation in Radians
 @param scale   Die Skalation, die proportional auf das Objekt wirkt
 @return Die neue Transformationsmatrix
*/
EXPORT
GLKMatrix4 MathUtils_CreateTransformationMatrixr(GLKVector3 translation, Rotation rotation, float scale);

#endif /* defined(__GLGameEngine__MathUtils__) */
