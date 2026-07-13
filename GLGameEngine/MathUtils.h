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
#include <stdbool.h>
#include <simd/simd.h>
#import "Buffer.h"

struct MathUtils_Rotation {
    float x;
    float y;
    float z;
};

/**
 @typedef Rotation
 @abstract Repräsentiert eine Rotation. Alle Winkel sind in Grad
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
Rotation MathUtils_RotationMake(float rx, float ry, float rz);

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
float MathUtils_DegToRad(float deg);

/**
 @function MathUtils_RadToDeg
 @abstract Konvertiert vom Bogenmass ins Gradmass
 @param rad Die Fliesszahl im bogenmass
 @return Der konvertierte Winkel
 */
EXPORT
float MathUtils_RadToDeg(float rad);

#pragma mark Affine matrix constructors
// simd provides multiply/inverse/transpose but no affine constructors.
// These replicate the standard column-major (right-handed) conventions the
// engine has always used, so all existing transforms stay bit-identical.

EXPORT
simd_float4x4 MathUtils_MatrixMakeTranslation(float tx, float ty, float tz);

EXPORT
simd_float4x4 MathUtils_MatrixMakeScale(float sx, float sy, float sz);

EXPORT
simd_float4x4 MathUtils_MatrixMakeXRotation(float radians);

EXPORT
simd_float4x4 MathUtils_MatrixMakeYRotation(float radians);

EXPORT
simd_float4x4 MathUtils_MatrixMakeZRotation(float radians);

/**
 @function MathUtils_MatrixMakePerspective
 @abstract Right-handed perspective projection with z mapped to [-1, 1].
           MasterRenderer multiplies its own conversion matrix on top to reach
           Metal's [0, 1] clip space, so this stays in the historic convention.
*/
EXPORT
simd_float4x4 MathUtils_MatrixMakePerspective(float fovyRadians, float aspect, float nearZ, float farZ);

EXPORT
simd_float3x3 MathUtils_Matrix4GetUpperLeft3x3(simd_float4x4 matrix);

/**
 @function MathUtils_CreateTransformationMatrixrXYZ
 @abstract Generiert eine neue Transformationsmatrix
 @param translation Die translation in x,y und z Richtung
 @param rx  Die Rotation um die X-Achse in Grad
 @param ry  Die Rotation um die Y-Achse in Grad
 @param rz  Die Rotation um die Z-Achse in Grad
 @param scale   Die Skalation, die proportional auf das Objekt wirkt
 @return Die neue Transformationsmatrix
*/
EXPORT
simd_float4x4 MathUtils_CreateTransformationMatrixrXYZ(simd_float3 translation, float rx, float ry, float rz, float scale);

/**
 @function MathUtils_CreateTransformationMatrixr
 @abstract Generiert eine neue Transformationsmatrix
 @param translation Die translation in x,y und z Richtung
 @param rotation    Die Rotation in Grad
 @param scale   Die Skalation, die proportional auf das Objekt wirkt
 @return Die neue Transformationsmatrix
*/
EXPORT
simd_float4x4 MathUtils_CreateTransformationMatrixr(simd_float3 translation, Rotation rotation, float scale);

/**
 @function MathUtils_CreateNormalMatrix
 @abstract Generiert eine neue Normalenmatrix
 @param transformationMatrix Die Transformationsmatrix (bzw. die ModelMatrix) der Entität, für die die Normalenmatrix berechnet werden soll
 @param viewMatrix Die Viewmatrix oder Kameramatrix mit der die Entität "gefilmt" wird, bzw. einfach nur die Bezugsmatrix
 @return Die neue Normalenmatrix
*/
EXPORT
simd_float3x3 MathUtils_CreateNormalMatrix(simd_float4x4 transformationMatrix, simd_float4x4 viewMatrix);

/**
 @function MathUtils_RandomFloat
 @abstract Generiert eine zufällige Zahl zwischen min und max
 @param min Die kleinste Grenze
 @param max Die grösste Grenze
 @return Die Zufallszahl
*/
EXPORT
float MathUtils_RandomFloat(float min, float max);

/**
 @function MathUtils_RandomMersenneTwisterFloat
 @abstract Generiert eine zufällige Zahl zwischen min und max mit dem mersenne twister Algorithmus
 @param min Die kleinste Grenze
 @param max Die grösste Grenze
 @return Die Zufallszahl
 */
EXPORT
float MathUtils_RandomMersenneTwisterFloat(float min, float max);

/**
 @function MathUtils_RandomBool
 @abstract Generiert ein zufälligen Boolean
 @return Der Zufallsboolean
*/
EXPORT
bool MathUtils_RandomBool(void);

/**
 @function MathUtils_RandomBoolProb
 @abstract Generiert ein zufälligen Boolean mit einer Wahrscheinlichkeit von 0 bis 1, dass er true ist
 @param probability Die Wahrscheinlichkeit
 @return Der Zufallsboolean
*/
EXPORT
bool MathUtils_RandomBoolProb(float probability);

/**
 @function MathUtils_BarryCentric
 @abstract Gibt die Höhe des Dreiecks △(p1, p2, p3) an der Position pos zurück.
 @param p1  Dreieckskoordinate 1
 @param p2  Dreieckskoordinate 2
 @param p3  Dreieckskoordinate 3
 @param pos Die Position
 @return Die Höhe
*/
EXPORT
float MathUtils_BarryCentric(simd_float3 p1, simd_float3 p2, simd_float3 p3, simd_float2 pos);

/**
 @function MathUtils_CreateGUITransformationMatrix
 @abstract Generiert eine neue Transformationsmatrix für GUI Texturen
 @param translation Die Verschiebung (Position) des Elements
 @param scale   Die Grösse des Elements
 @return Die Matrix
*/
EXPORT
simd_float4x4 MathUtils_CreateGUITransformationMatrix(simd_float2 translation, simd_float2 scale);

#endif /* defined(__GLGameEngine__MathUtils__) */
