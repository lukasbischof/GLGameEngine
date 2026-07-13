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

float MathUtils_DegToRad(float deg)
{
    return deg * M_PI / 180;
}

float MathUtils_RadToDeg(float rad)
{
    return rad * 180 / M_PI;
}

Rotation MathUtils_RotationMake(float rx, float ry, float rz)
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

#pragma mark - Affine matrix constructors

simd_float4x4 MathUtils_MatrixMakeTranslation(float tx, float ty, float tz)
{
    return simd_matrix(simd_make_float4(1.f, 0.f, 0.f, 0.f),
                       simd_make_float4(0.f, 1.f, 0.f, 0.f),
                       simd_make_float4(0.f, 0.f, 1.f, 0.f),
                       simd_make_float4(tx, ty, tz, 1.f));
}

simd_float4x4 MathUtils_MatrixMakeScale(float sx, float sy, float sz)
{
    return simd_matrix(simd_make_float4(sx, 0.f, 0.f, 0.f),
                       simd_make_float4(0.f, sy, 0.f, 0.f),
                       simd_make_float4(0.f, 0.f, sz, 0.f),
                       simd_make_float4(0.f, 0.f, 0.f, 1.f));
}

simd_float4x4 MathUtils_MatrixMakeXRotation(float radians)
{
    float c = cosf(radians), s = sinf(radians);
    return simd_matrix(simd_make_float4(1.f, 0.f, 0.f, 0.f),
                       simd_make_float4(0.f, c, s, 0.f),
                       simd_make_float4(0.f, -s, c, 0.f),
                       simd_make_float4(0.f, 0.f, 0.f, 1.f));
}

simd_float4x4 MathUtils_MatrixMakeYRotation(float radians)
{
    float c = cosf(radians), s = sinf(radians);
    return simd_matrix(simd_make_float4(c, 0.f, -s, 0.f),
                       simd_make_float4(0.f, 1.f, 0.f, 0.f),
                       simd_make_float4(s, 0.f, c, 0.f),
                       simd_make_float4(0.f, 0.f, 0.f, 1.f));
}

simd_float4x4 MathUtils_MatrixMakeZRotation(float radians)
{
    float c = cosf(radians), s = sinf(radians);
    return simd_matrix(simd_make_float4(c, s, 0.f, 0.f),
                       simd_make_float4(-s, c, 0.f, 0.f),
                       simd_make_float4(0.f, 0.f, 1.f, 0.f),
                       simd_make_float4(0.f, 0.f, 0.f, 1.f));
}

simd_float4x4 MathUtils_MatrixMakePerspective(float fovyRadians, float aspect, float nearZ, float farZ)
{
    float cotan = 1.f / tanf(fovyRadians / 2.f);

    return simd_matrix(simd_make_float4(cotan / aspect, 0.f, 0.f, 0.f),
                       simd_make_float4(0.f, cotan, 0.f, 0.f),
                       simd_make_float4(0.f, 0.f, (farZ + nearZ) / (nearZ - farZ), -1.f),
                       simd_make_float4(0.f, 0.f, (2.f * farZ * nearZ) / (nearZ - farZ), 0.f));
}

simd_float3x3 MathUtils_Matrix4GetUpperLeft3x3(simd_float4x4 matrix)
{
    return simd_matrix(matrix.columns[0].xyz,
                       matrix.columns[1].xyz,
                       matrix.columns[2].xyz);
}

#pragma mark - Composite transforms

simd_float4x4 MathUtils_CreateTransformationMatrixrXYZ(simd_float3 translation, float rx, float ry, float rz, float scale)
{
    simd_float4x4 matrix = MathUtils_MatrixMakeTranslation(translation.x, translation.y, translation.z);

    matrix = simd_mul(matrix, MathUtils_MatrixMakeXRotation(MathUtils_DegToRad(rx)));
    matrix = simd_mul(matrix, MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(ry)));
    matrix = simd_mul(matrix, MathUtils_MatrixMakeZRotation(MathUtils_DegToRad(rz)));
    matrix = simd_mul(matrix, MathUtils_MatrixMakeScale(scale, scale, scale));

    return matrix;
}

simd_float4x4 MathUtils_CreateTransformationMatrixr(simd_float3 translation, Rotation rotation, float scale)
{
    return MathUtils_CreateTransformationMatrixrXYZ(translation, rotation.x, rotation.y, rotation.z, scale);
}

simd_float4x4 MathUtils_CreateGUITransformationMatrix(simd_float2 translation, simd_float2 scale)
{
    simd_float4x4 matrix = MathUtils_MatrixMakeTranslation(translation.x, translation.y, 0.f);
    matrix = simd_mul(matrix, MathUtils_MatrixMakeScale(scale.x, scale.y, 1.f));

    return matrix;
}

simd_float3x3 MathUtils_CreateNormalMatrix(simd_float4x4 transformationMatrix, simd_float4x4 viewMatrix)
{
    simd_float4x4 mvMatrix = simd_mul(viewMatrix, transformationMatrix);

    // simd_inverse has no invertibility flag and returns garbage for singular
    // matrices, so check the determinant first and keep the identity fallback.
    if (simd_determinant(mvMatrix) == 0.f) {
#if DEBUG
        // this runs per entity per pass — keep the log out of release builds
        NSLog(@"<< ERROR >>: mvMatrix isn't invertible");
#endif
        return matrix_identity_float3x3;
    }

    simd_float4x4 nMatrix = simd_transpose(simd_inverse(mvMatrix));

    return MathUtils_Matrix4GetUpperLeft3x3(nMatrix);
}

#pragma mark - Randomness

float MathUtils_RandomFloat(float min, float max)
{
    return (((float)[[GKLinearCongruentialRandomSource sharedRandom] nextUniform]) * (max - min)) + min;
}

float MathUtils_RandomMersenneTwisterFloat(float min, float max)
{
    return (((float)[[GKMersenneTwisterRandomSource sharedRandom] nextUniform]) * (max - min)) + min;
}

bool MathUtils_RandomBool(void)
{
    return [[GKARC4RandomSource sharedRandom] nextBool];
}

bool MathUtils_RandomBoolProb(float probability)
{
    if (probability >= 1.)
        return YES;

    return [[GKLinearCongruentialRandomSource sharedRandom] nextUniform] < probability;
}

float MathUtils_BarryCentric(simd_float3 p1, simd_float3 p2, simd_float3 p3, simd_float2 pos)
{
    float det = (p2.z - p3.z) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.z - p3.z);
    float l1 = ((p2.z - p3.z) * (pos.x - p3.x) + (p3.x - p2.x) * (pos.y - p3.z)) / det;
    float l2 = ((p3.z - p1.z) * (pos.x - p3.x) + (p1.x - p3.x) * (pos.y - p3.z)) / det;
    float l3 = 1.f - l1 - l2;

    return l1 * p1.y + l2 * p2.y + l3 * p3.y;
}
