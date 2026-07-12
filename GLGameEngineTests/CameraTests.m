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
    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, GLKMatrix4Identity, 1e-5);
}

- (void)testMoveAccumulates
{
    Camera *camera = [Camera camera];
    [camera move:GLKVector3Make(1.f, 2.f, 3.f)];
    [camera move:GLKVector3Make(-4.f, 0.5f, 10.f)];

    AssertVector3EqualWithAccuracy(camera.position, GLKVector3Make(-3.f, 2.5f, 13.f), 1e-5);
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
    [camera move:GLKVector3Make(1.f, 2.f, 3.f)];

    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, GLKMatrix4MakeTranslation(-1.f, -2.f, -3.f), 1e-5);
}

- (void)testViewMatrixComposition
{
    Camera *camera = [Camera camera];
    camera.position = GLKVector3Make(10.f, -5.f, 20.f);
    camera.pitch = 15.f;
    camera.yaw = 75.f;
    camera.roll = -30.f;

    // Rx(pitch) * Ry(yaw) * Rz(roll) * T(-position), all angles in degrees
    GLKMatrix4 expected = GLKMatrix4MakeXRotation(MathUtils_DegToRad(15.f));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeYRotation(MathUtils_DegToRad(75.f)));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeZRotation(MathUtils_DegToRad(-30.f)));
    expected = GLKMatrix4Multiply(expected, GLKMatrix4MakeTranslation(-10.f, 5.f, -20.f));

    AssertMatrix4EqualWithAccuracy(camera.viewMatrix, expected, 1e-4);
}

- (void)testViewMatrixMapsCameraPositionToOrigin
{
    Camera *camera = [Camera camera];
    camera.position = GLKVector3Make(3.f, 4.f, 5.f);
    camera.pitch = 33.f;
    camera.yaw = 120.f;

    GLKVector4 eye = GLKMatrix4MultiplyVector4(camera.viewMatrix, GLKVector4Make(3.f, 4.f, 5.f, 1.f));
    XCTAssertEqualWithAccuracy(eye.x, 0.f, 1e-4);
    XCTAssertEqualWithAccuracy(eye.y, 0.f, 1e-4);
    XCTAssertEqualWithAccuracy(eye.z, 0.f, 1e-4);
}

@end
