//
//  MathUtilsTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import "MathUtils.h"
#import "MatrixAssertions.h"

static const float kAccuracy = 1e-5f;

@interface MathUtilsTests : XCTestCase
@end

@implementation MathUtilsTests

#pragma mark - Angle conversion

- (void)testDegToRad
{
    XCTAssertEqualWithAccuracy(MathUtils_DegToRad(0.f), 0.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_DegToRad(180.f), (float)M_PI, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_DegToRad(-90.f), (float)(-M_PI_2), kAccuracy);
}

- (void)testRadToDeg
{
    XCTAssertEqualWithAccuracy(MathUtils_RadToDeg((float)M_PI), 180.f, 1e-4);
    XCTAssertEqualWithAccuracy(MathUtils_RadToDeg((float)M_PI_2), 90.f, 1e-4);
}

- (void)testDegRadRoundTrip
{
    for (float deg = -360.f; deg <= 360.f; deg += 45.f) {
        XCTAssertEqualWithAccuracy(MathUtils_RadToDeg(MathUtils_DegToRad(deg)), deg, 1e-3);
    }
}

#pragma mark - Rotation struct

- (void)testRotationMake
{
    Rotation rot = MathUtils_RotationMake(1.f, 2.f, 3.f);
    XCTAssertEqual(rot.x, 1.f);
    XCTAssertEqual(rot.y, 2.f);
    XCTAssertEqual(rot.z, 3.f);
}

- (void)testZeroRotation
{
    XCTAssertEqual(MathUtils_ZeroRotation.x, 0.f);
    XCTAssertEqual(MathUtils_ZeroRotation.y, 0.f);
    XCTAssertEqual(MathUtils_ZeroRotation.z, 0.f);
}

- (void)testConvertRotationToRadiansAndBack
{
    Rotation deg = MathUtils_RotationMake(90.f, 180.f, -45.f);
    Rotation rad = MathUtils_ConvertRotationToRadians(deg);

    XCTAssertEqualWithAccuracy(rad.x, (float)M_PI_2, kAccuracy);
    XCTAssertEqualWithAccuracy(rad.y, (float)M_PI, kAccuracy);
    XCTAssertEqualWithAccuracy(rad.z, (float)(-M_PI_4), kAccuracy);

    Rotation back = MathUtils_ConvertRotationToDegrees(rad);
    XCTAssertEqualWithAccuracy(back.x, deg.x, 1e-3);
    XCTAssertEqualWithAccuracy(back.y, deg.y, 1e-3);
    XCTAssertEqualWithAccuracy(back.z, deg.z, 1e-3);
}

#pragma mark - Barycentric interpolation

- (void)testBarryCentricAtTriangleCorners
{
    simd_float3 p1 = simd_make_float3(0.f, 10.f, 0.f);
    simd_float3 p2 = simd_make_float3(1.f, 20.f, 0.f);
    simd_float3 p3 = simd_make_float3(0.f, 30.f, 1.f);

    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, simd_make_float2(0.f, 0.f)), 10.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, simd_make_float2(1.f, 0.f)), 20.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, simd_make_float2(0.f, 1.f)), 30.f, kAccuracy);
}

- (void)testBarryCentricAtCentroid
{
    simd_float3 p1 = simd_make_float3(0.f, 3.f, 0.f);
    simd_float3 p2 = simd_make_float3(1.f, 6.f, 0.f);
    simd_float3 p3 = simd_make_float3(0.f, 9.f, 1.f);

    // The centroid weighs each corner equally
    simd_float2 centroid = simd_make_float2(1.f / 3.f, 1.f / 3.f);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, centroid), 6.f, 1e-4);
}

- (void)testBarryCentricOnFlatTriangleIsConstant
{
    simd_float3 p1 = simd_make_float3(0.f, 5.f, 0.f);
    simd_float3 p2 = simd_make_float3(1.f, 5.f, 0.f);
    simd_float3 p3 = simd_make_float3(0.f, 5.f, 1.f);

    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, simd_make_float2(0.25f, 0.25f)), 5.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, simd_make_float2(0.1f, 0.7f)), 5.f, kAccuracy);
}

#pragma mark - Affine constructors (numeric expectations, independent of the helpers)

- (void)testMatrixMakeTranslationLayout
{
    simd_float4x4 m = MathUtils_MatrixMakeTranslation(1.f, -2.f, 3.f);

    // column-major: translation lives in the last column
    simd_float4x4 expected = matrix_identity_float4x4;
    expected.columns[3] = simd_make_float4(1.f, -2.f, 3.f, 1.f);

    AssertMatrix4EqualWithAccuracy(m, expected, kAccuracy);
}

- (void)testMatrixMakeScaleLayout
{
    simd_float4x4 m = MathUtils_MatrixMakeScale(2.f, 3.f, 4.f);
    simd_float4x4 expected = simd_diagonal_matrix(simd_make_float4(2.f, 3.f, 4.f, 1.f));

    AssertMatrix4EqualWithAccuracy(m, expected, kAccuracy);
}

- (void)testRotationMatricesAt90Degrees
{
    // hand-derived expectations for right-handed 90° rotations
    simd_float4 rx = simd_mul(MathUtils_MatrixMakeXRotation(M_PI_2), simd_make_float4(0.f, 1.f, 0.f, 1.f));
    XCTAssertEqualWithAccuracy(rx.y, 0.f, kAccuracy); // +Y -> +Z
    XCTAssertEqualWithAccuracy(rx.z, 1.f, kAccuracy);

    simd_float4 ry = simd_mul(MathUtils_MatrixMakeYRotation(M_PI_2), simd_make_float4(1.f, 0.f, 0.f, 1.f));
    XCTAssertEqualWithAccuracy(ry.x, 0.f, kAccuracy); // +X -> -Z
    XCTAssertEqualWithAccuracy(ry.z, -1.f, kAccuracy);

    simd_float4 rz = simd_mul(MathUtils_MatrixMakeZRotation(M_PI_2), simd_make_float4(1.f, 0.f, 0.f, 1.f));
    XCTAssertEqualWithAccuracy(rz.x, 0.f, kAccuracy); // +X -> +Y
    XCTAssertEqualWithAccuracy(rz.y, 1.f, kAccuracy);
}

- (void)testMatrixMakePerspectiveLayout
{
    // GL-convention perspective: hand-computed for fovy=90°, aspect=2, near=1, far=3
    simd_float4x4 m = MathUtils_MatrixMakePerspective(M_PI_2, 2.f, 1.f, 3.f);

    XCTAssertEqualWithAccuracy(m.columns[0][0], 0.5f, kAccuracy);  // cot(45°)/2
    XCTAssertEqualWithAccuracy(m.columns[1][1], 1.f, kAccuracy);   // cot(45°)
    XCTAssertEqualWithAccuracy(m.columns[2][2], -2.f, kAccuracy);  // (f+n)/(n-f)
    XCTAssertEqualWithAccuracy(m.columns[2][3], -1.f, kAccuracy);
    XCTAssertEqualWithAccuracy(m.columns[3][2], -3.f, kAccuracy);  // 2fn/(n-f)
    XCTAssertEqualWithAccuracy(m.columns[3][3], 0.f, kAccuracy);
}

#pragma mark - Transformation matrices

// Note: the rotation parameters are interpreted as degrees.
- (void)testCreateTransformationMatrixTranslationOnly
{
    simd_float3 t = simd_make_float3(1.f, -2.f, 3.f);
    simd_float4x4 mat = MathUtils_CreateTransformationMatrixr(t, MathUtils_ZeroRotation, 1.f);

    AssertMatrix4EqualWithAccuracy(mat, MathUtils_MatrixMakeTranslation(t.x, t.y, t.z), kAccuracy);
}

- (void)testCreateTransformationMatrixComposition
{
    simd_float3 t = simd_make_float3(4.f, 5.f, 6.f);
    Rotation rotDeg = MathUtils_RotationMake(30.f, 60.f, 90.f);
    float scale = 2.5f;

    simd_float4x4 actual = MathUtils_CreateTransformationMatrixr(t, rotDeg, scale);

    // T * Rx * Ry * Rz * S composed from the individual constructors
    simd_float4x4 expected = MathUtils_MatrixMakeTranslation(t.x, t.y, t.z);
    expected = simd_mul(expected, MathUtils_MatrixMakeXRotation(MathUtils_DegToRad(rotDeg.x)));
    expected = simd_mul(expected, MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(rotDeg.y)));
    expected = simd_mul(expected, MathUtils_MatrixMakeZRotation(MathUtils_DegToRad(rotDeg.z)));
    expected = simd_mul(expected, MathUtils_MatrixMakeScale(scale, scale, scale));

    AssertMatrix4EqualWithAccuracy(actual, expected, 1e-4);
}

- (void)testCreateTransformationMatrixTransformsOrigin
{
    simd_float3 t = simd_make_float3(7.f, 8.f, 9.f);
    simd_float4x4 mat = MathUtils_CreateTransformationMatrixr(t, MathUtils_RotationMake(12.f, 34.f, 56.f), 3.f);

    // Rotation and scale never move the origin: it must land on the translation
    simd_float4 origin = simd_mul(mat, simd_make_float4(0.f, 0.f, 0.f, 1.f));
    XCTAssertEqualWithAccuracy(origin.x, t.x, 1e-4);
    XCTAssertEqualWithAccuracy(origin.y, t.y, 1e-4);
    XCTAssertEqualWithAccuracy(origin.z, t.z, 1e-4);
}

- (void)testCreateTransformationMatrixrXYZMatchesRotationStructVariant
{
    simd_float3 t = simd_make_float3(1.f, 2.f, 3.f);
    simd_float4x4 a = MathUtils_CreateTransformationMatrixrXYZ(t, 10.f, 20.f, 30.f, 1.5f);
    simd_float4x4 b = MathUtils_CreateTransformationMatrixr(t, MathUtils_RotationMake(10.f, 20.f, 30.f), 1.5f);

    AssertMatrix4EqualWithAccuracy(a, b, kAccuracy);
}

- (void)testCreateGUITransformationMatrix
{
    simd_float4x4 actual = MathUtils_CreateGUITransformationMatrix(simd_make_float2(0.5f, -0.25f),
                                                                   simd_make_float2(2.f, 4.f));

    simd_float4x4 expected = MathUtils_MatrixMakeTranslation(0.5f, -0.25f, 0.f);
    expected = simd_mul(expected, MathUtils_MatrixMakeScale(2.f, 4.f, 1.f));

    AssertMatrix4EqualWithAccuracy(actual, expected, kAccuracy);
}

#pragma mark - Normal matrix

- (void)testNormalMatrixOfIdentityIsIdentity
{
    simd_float3x3 n = MathUtils_CreateNormalMatrix(matrix_identity_float4x4, matrix_identity_float4x4);
    AssertMatrix3EqualWithAccuracy(n, matrix_identity_float3x3, kAccuracy);
}

- (void)testNormalMatrixOfPureRotationIsTheRotation
{
    // For a pure rotation R, inverse-transpose(R) == R
    simd_float4x4 rot = MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(90.f));
    simd_float3x3 n = MathUtils_CreateNormalMatrix(rot, matrix_identity_float4x4);

    AssertMatrix3EqualWithAccuracy(n, MathUtils_Matrix4GetUpperLeft3x3(rot), 1e-4);
}

- (void)testNormalMatrixOfUniformScaleIsInverseScale
{
    // inverse-transpose of diag(2,2,2) is diag(0.5,0.5,0.5)
    simd_float4x4 scale = MathUtils_MatrixMakeScale(2.f, 2.f, 2.f);
    simd_float3x3 n = MathUtils_CreateNormalMatrix(scale, matrix_identity_float4x4);

    simd_float3x3 expected = simd_matrix(simd_make_float3(0.5f, 0.f, 0.f),
                                         simd_make_float3(0.f, 0.5f, 0.f),
                                         simd_make_float3(0.f, 0.f, 0.5f));
    AssertMatrix3EqualWithAccuracy(n, expected, 1e-4);
}

- (void)testNormalMatrixOfNonInvertibleMatrixFallsBackToIdentity
{
    simd_float4x4 degenerate = MathUtils_MatrixMakeScale(0.f, 0.f, 0.f);
    simd_float3x3 n = MathUtils_CreateNormalMatrix(degenerate, matrix_identity_float4x4);

    AssertMatrix3EqualWithAccuracy(n, matrix_identity_float3x3, kAccuracy);
}

- (void)testMatrix4GetUpperLeft3x3
{
    simd_float4x4 m = MathUtils_MatrixMakeTranslation(9.f, 9.f, 9.f);
    m.columns[0][0] = 2.f;
    m.columns[1][2] = 5.f;

    simd_float3x3 sub = MathUtils_Matrix4GetUpperLeft3x3(m);
    XCTAssertEqual(sub.columns[0][0], 2.f);
    XCTAssertEqual(sub.columns[1][2], 5.f);
    XCTAssertEqual(sub.columns[2][2], 1.f);
}

#pragma mark - Randomness (bounds only)

- (void)testRandomFloatStaysInBounds
{
    for (int i = 0; i < 1000; i++) {
        float v = MathUtils_RandomFloat(-3.f, 7.f);
        XCTAssertGreaterThanOrEqual(v, -3.f);
        XCTAssertLessThanOrEqual(v, 7.f);
    }
}

- (void)testRandomBoolProbCertainty
{
    XCTAssertTrue(MathUtils_RandomBoolProb(1.f));
    XCTAssertTrue(MathUtils_RandomBoolProb(1.5f));
}

@end
