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
    XCTAssertEqualWithAccuracy(MathUtils_DegToRad(180.f), (GLfloat)M_PI, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_DegToRad(-90.f), (GLfloat)(-M_PI_2), kAccuracy);
}

- (void)testRadToDeg
{
    XCTAssertEqualWithAccuracy(MathUtils_RadToDeg((GLfloat)M_PI), 180.f, 1e-4);
    XCTAssertEqualWithAccuracy(MathUtils_RadToDeg((GLfloat)M_PI_2), 90.f, 1e-4);
}

- (void)testDegRadRoundTrip
{
    for (GLfloat deg = -360.f; deg <= 360.f; deg += 45.f) {
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

    XCTAssertEqualWithAccuracy(rad.x, (GLfloat)M_PI_2, kAccuracy);
    XCTAssertEqualWithAccuracy(rad.y, (GLfloat)M_PI, kAccuracy);
    XCTAssertEqualWithAccuracy(rad.z, (GLfloat)(-M_PI_4), kAccuracy);

    Rotation back = MathUtils_ConvertRotationToDegrees(rad);
    XCTAssertEqualWithAccuracy(back.x, deg.x, 1e-3);
    XCTAssertEqualWithAccuracy(back.y, deg.y, 1e-3);
    XCTAssertEqualWithAccuracy(back.z, deg.z, 1e-3);
}

#pragma mark - Barycentric interpolation

- (void)testBarryCentricAtTriangleCorners
{
    GLKVector3 p1 = GLKVector3Make(0.f, 10.f, 0.f);
    GLKVector3 p2 = GLKVector3Make(1.f, 20.f, 0.f);
    GLKVector3 p3 = GLKVector3Make(0.f, 30.f, 1.f);

    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, GLKVector2Make(0.f, 0.f)), 10.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, GLKVector2Make(1.f, 0.f)), 20.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, GLKVector2Make(0.f, 1.f)), 30.f, kAccuracy);
}

- (void)testBarryCentricAtCentroid
{
    GLKVector3 p1 = GLKVector3Make(0.f, 3.f, 0.f);
    GLKVector3 p2 = GLKVector3Make(1.f, 6.f, 0.f);
    GLKVector3 p3 = GLKVector3Make(0.f, 9.f, 1.f);

    // The centroid weighs each corner equally
    GLKVector2 centroid = GLKVector2Make(1.f / 3.f, 1.f / 3.f);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, centroid), 6.f, 1e-4);
}

- (void)testBarryCentricOnFlatTriangleIsConstant
{
    GLKVector3 p1 = GLKVector3Make(0.f, 5.f, 0.f);
    GLKVector3 p2 = GLKVector3Make(1.f, 5.f, 0.f);
    GLKVector3 p3 = GLKVector3Make(0.f, 5.f, 1.f);

    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, GLKVector2Make(0.25f, 0.25f)), 5.f, kAccuracy);
    XCTAssertEqualWithAccuracy(MathUtils_BarryCentric(p1, p2, p3, GLKVector2Make(0.1f, 0.7f)), 5.f, kAccuracy);
}

#pragma mark - Transformation matrices

// Note: despite the header's wording, the rotation parameters are interpreted
// as degrees (the implementation converts them to radians itself).
- (void)testCreateTransformationMatrixTranslationOnly
{
    GLKVector3 t = GLKVector3Make(1.f, -2.f, 3.f);
    GLKMatrix4 mat = MathUtils_CreateTransformationMatrixr(t, MathUtils_ZeroRotation, 1.f);

    AssertMatrix4EqualWithAccuracy(mat, GLKMatrix4MakeTranslation(t.x, t.y, t.z), kAccuracy);
}

- (void)testCreateTransformationMatrixComposition
{
    GLKVector3 t = GLKVector3Make(4.f, 5.f, 6.f);
    Rotation rotDeg = MathUtils_RotationMake(30.f, 60.f, 90.f);
    GLfloat scale = 2.5f;

    GLKMatrix4 actual = MathUtils_CreateTransformationMatrixr(t, rotDeg, scale);

    // T * Rx * Ry * Rz * S, composed from GLKit's Make… primitives
    GLKMatrix4 expected = GLKMatrix4MakeTranslation(t.x, t.y, t.z);
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeXRotation(MathUtils_DegToRad(rotDeg.x)));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeYRotation(MathUtils_DegToRad(rotDeg.y)));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeZRotation(MathUtils_DegToRad(rotDeg.z)));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeScale(scale, scale, scale));

    AssertMatrix4EqualWithAccuracy(actual, expected, 1e-4);
}

- (void)testCreateTransformationMatrixTransformsOrigin
{
    GLKVector3 t = GLKVector3Make(7.f, 8.f, 9.f);
    GLKMatrix4 mat = MathUtils_CreateTransformationMatrixr(t, MathUtils_RotationMake(12.f, 34.f, 56.f), 3.f);

    // Rotation and scale never move the origin: it must land on the translation
    GLKVector4 origin = GLKMatrix4MultiplyVector4(mat, GLKVector4Make(0.f, 0.f, 0.f, 1.f));
    XCTAssertEqualWithAccuracy(origin.x, t.x, 1e-4);
    XCTAssertEqualWithAccuracy(origin.y, t.y, 1e-4);
    XCTAssertEqualWithAccuracy(origin.z, t.z, 1e-4);
}

- (void)testCreateTransformationMatrixrXYZMatchesRotationStructVariant
{
    GLKVector3 t = GLKVector3Make(1.f, 2.f, 3.f);
    GLKMatrix4 a = MathUtils_CreateTransformationMatrixrXYZ(t, 10.f, 20.f, 30.f, 1.5f);
    GLKMatrix4 b = MathUtils_CreateTransformationMatrixr(t, MathUtils_RotationMake(10.f, 20.f, 30.f), 1.5f);

    AssertMatrix4EqualWithAccuracy(a, b, kAccuracy);
}

- (void)testCreateGUITransformationMatrix
{
    GLKMatrix4 actual = MathUtils_CreateGUITransformationMatrix(GLKVector2Make(0.5f, -0.25f),
                                                                GLKVector2Make(2.f, 4.f));

    GLKMatrix4 expected = GLKMatrix4MakeTranslation(0.5f, -0.25f, 0.f);
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeScale(2.f, 4.f, 1.f));

    AssertMatrix4EqualWithAccuracy(actual, expected, kAccuracy);
}

#pragma mark - Normal matrix

- (void)testNormalMatrixOfIdentityIsIdentity
{
    GLKMatrix3 n = MathUtils_CreateNormalMatrix(GLKMatrix4Identity, GLKMatrix4Identity);
    AssertMatrix3EqualWithAccuracy(n, GLKMatrix3Identity, kAccuracy);
}

- (void)testNormalMatrixOfPureRotationIsTheRotation
{
    // For a pure rotation R, inverse-transpose(R) == R
    GLKMatrix4 rot = GLKMatrix4MakeYRotation(MathUtils_DegToRad(90.f));
    GLKMatrix3 n = MathUtils_CreateNormalMatrix(rot, GLKMatrix4Identity);

    AssertMatrix3EqualWithAccuracy(n, GLKMatrix4GetMatrix3(rot), 1e-4);
}

- (void)testNormalMatrixOfUniformScaleIsInverseScale
{
    // inverse-transpose of diag(2,2,2) is diag(0.5,0.5,0.5)
    GLKMatrix4 scale = GLKMatrix4MakeScale(2.f, 2.f, 2.f);
    GLKMatrix3 n = MathUtils_CreateNormalMatrix(scale, GLKMatrix4Identity);

    AssertMatrix3EqualWithAccuracy(n, GLKMatrix3MakeScale(0.5f, 0.5f, 0.5f), 1e-4);
}

- (void)testNormalMatrixOfNonInvertibleMatrixFallsBackToIdentity
{
    GLKMatrix4 degenerate = GLKMatrix4MakeScale(0.f, 0.f, 0.f);
    GLKMatrix3 n = MathUtils_CreateNormalMatrix(degenerate, GLKMatrix4Identity);

    AssertMatrix3EqualWithAccuracy(n, GLKMatrix3Identity, kAccuracy);
}

#pragma mark - Randomness (bounds only)

- (void)testRandomFloatStaysInBounds
{
    for (int i = 0; i < 1000; i++) {
        GLfloat v = MathUtils_RandomFloat(-3.f, 7.f);
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
