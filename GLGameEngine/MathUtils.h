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

/**
 @typedef Rotation
 @abstract Repräsentiert eine Rotation. Alle Winkel sind im Bogenmass
*/
typedef struct MathUtils_Rotation Rotation;

/**
 @const MathUtils_ZeroRotation
 @abstract Eine 0-Rotation, bzw. keine Rotation
*/
EXPORT
Rotation const MathUtils_ZeroRotation;

/**
 @function MathUtils_RotationMake
 @abstract Generiert eine neue Rotation
 @param rx Die Rotation um die x-Achse in grad
 @param ry Die Rotation um die y-Achse in grad
 @param rz Die Rotation um die z-Achse in grad
 @return Die neue Rotation
*/
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

/**
 @function MathUtils_DegToRad
 @abstract Konvertiert vom Gradmass ins Bogenmass
 @param deg Die Fliesszahl im gradmass
 @return Der konvertierte Winkel
*/
EXPORT
GLfloat MathUtils_DegToRad(GLfloat deg);

/**
 @function MathUtils_RadToDeg
 @abstract Konvertiert vom Bogenmass ins Gradmass
 @param rad Die Fliesszahl im bogenmass
 @return Der konvertierte Winkel
 */
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

/**
 @function MathUtils_CreateNormalMatrix
 @abstract Generiert eine neue Normalenmatrix
 @param transformationMatrix Die Transformationsmatrix (bzw. die ModelMatrix) der Entität, für die die Normalenmatrix berechnet werden soll
 @param viewMatrix Die Viewmatrix oder Kameramatrix mit der die Entität "gefilmt" wird, bzw. einfach nur die Bezugsmatrix
 @return Die neue Normalenmatrix
*/
EXPORT
GLKMatrix3 MathUtils_CreateNormalMatrix(GLKMatrix4 transformationMatrix, GLKMatrix4 viewMatrix);

#endif /* defined(__GLGameEngine__MathUtils__) */
