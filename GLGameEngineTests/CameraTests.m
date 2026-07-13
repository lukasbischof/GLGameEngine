//
//  CameraTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import "Camera.h"
#import "MatrixAssertions.h"

@interface CameraTests : XCTestCase
@end

@implementation CameraTests

- (void)testInitialStateYieldsIdentityViewMatrix
{
    Camera *camera = [Camera camera];
    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, matrix_identity_float4x4, 1e-5);
}

- (void)testMoveAccumulates
{
    Camera *camera = [Camera camera];
    [camera move:simd_make_float3(1.f, 2.f, 3.f)];
    [camera move:simd_make_float3(-4.f, 0.5f, 10.f)];

    AssertVector3EqualWithAccuracy(camera.position, simd_make_float3(-3.f, 2.5f, 13.f), 1e-5);
}

- (void)testInvertPitchRoundTrip
{
    Camera *camera = [Camera camera];
    camera.pitch = 42.f;

    [camera invertPitch];
    XCTAssertEqualWithAccuracy(camera.pitch, -42.f, 1e-6);

    [camera invertPitch];
    XCTAssertEqualWithAccuracy(camera.pitch, 42.f, 1e-6);
}

- (void)testViewMatrixForPureTranslationIsNegatedTranslation
{
    Camera *camera = [Camera camera];
    [camera move:simd_make_float3(1.f, 2.f, 3.f)];

    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, MathUtils_MatrixMakeTranslation(-1.f, -2.f, -3.f), 1e-5);
}

- (void)testViewMatrixComposition
{
    Camera *camera = [Camera camera];
    camera.position = simd_make_float3(10.f, -5.f, 20.f);
    camera.pitch = 15.f;
    camera.yaw = 75.f;
    camera.roll = -30.f;

    // Rx(pitch) * Ry(yaw) * Rz(roll) * T(-position), all angles in degrees
    simd_float4x4 expected = MathUtils_MatrixMakeXRotation(MathUtils_DegToRad(15.f));
    expected = simd_mul(expected, MathUtils_MatrixMakeYRotation(MathUtils_DegToRad(75.f)));
    expected = simd_mul(expected, MathUtils_MatrixMakeZRotation(MathUtils_DegToRad(-30.f)));
    expected = simd_mul(expected, MathUtils_MatrixMakeTranslation(-10.f, 5.f, -20.f));

    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, expected, 1e-4);
}

- (void)testViewMatrixMapsCameraPositionToOrigin
{
    Camera *camera = [Camera camera];
    camera.position = simd_make_float3(3.f, 4.f, 5.f);
    camera.pitch = 33.f;
    camera.yaw = 120.f;

    simd_float4 eye = simd_mul(camera.viewMatrix, simd_make_float4(3.f, 4.f, 5.f, 1.f));
    XCTAssertEqualWithAccuracy(eye.x, 0.f, 1e-4);
    XCTAssertEqualWithAccuracy(eye.y, 0.f, 1e-4);
    XCTAssertEqualWithAccuracy(eye.z, 0.f, 1e-4);
}

@end
