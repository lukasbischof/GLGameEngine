//
//  SIMDBridgeTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import <GLKit/GLKit.h>
#import "SIMDBridge.h"

@interface SIMDBridgeTests : XCTestCase
@end

@implementation SIMDBridgeTests

- (void)testMatrix4PreservesColumnMajorLayout
{
    GLKMatrix4 m;
    for (int i = 0; i < 16; i++) {
        m.m[i] = (float)i;
    }

    simd_float4x4 s = SIMD_Matrix4(m);

    // GLKMatrix4 and simd_float4x4 share the column-major 16-float layout:
    // m.m[col*4 + row] is column `col`, row `row`
    for (int col = 0; col < 4; col++) {
        for (int row = 0; row < 4; row++) {
            XCTAssertEqual(s.columns[col][row], m.m[col * 4 + row],
                           @"column %d row %d", col, row);
        }
    }
}

- (void)testMatrix3ExpandsPackedColumnsCorrectly
{
    // GLKMatrix3 is 9 packed floats; simd_float3x3 pads each column to 16
    // bytes, so a memcpy would shear the columns — the bridge must repack.
    GLKMatrix3 m;
    for (int i = 0; i < 9; i++) {
        m.m[i] = (float)(i + 1);
    }

    simd_float3x3 s = SIMD_Matrix3(m);

    // column 0 = (m00,m01,m02) = m.m[0..2], column 1 = m.m[3..5], column 2 = m.m[6..8]
    for (int col = 0; col < 3; col++) {
        for (int row = 0; row < 3; row++) {
            XCTAssertEqual(s.columns[col][row], m.m[col * 3 + row],
                           @"column %d row %d", col, row);
        }
    }
}

- (void)testMatrix3RoundTripThroughRotation
{
    GLKMatrix3 rot = GLKMatrix3MakeYRotation((float)M_PI_4);
    simd_float3x3 s = SIMD_Matrix3(rot);

    // transform a vector both ways and compare
    GLKVector3 gv = GLKMatrix3MultiplyVector3(rot, GLKVector3Make(1.f, 2.f, 3.f));
    simd_float3 sv = simd_mul(s, simd_make_float3(1.f, 2.f, 3.f));

    XCTAssertEqualWithAccuracy(sv.x, gv.x, 1e-5);
    XCTAssertEqualWithAccuracy(sv.y, gv.y, 1e-5);
    XCTAssertEqualWithAccuracy(sv.z, gv.z, 1e-5);
}

- (void)testVectorBridges
{
    simd_float2 v2 = SIMD_Vector2(GLKVector2Make(1.f, 2.f));
    XCTAssertEqual(v2.x, 1.f);
    XCTAssertEqual(v2.y, 2.f);

    simd_float3 v3 = SIMD_Vector3(GLKVector3Make(3.f, 4.f, 5.f));
    XCTAssertEqual(v3.x, 3.f);
    XCTAssertEqual(v3.y, 4.f);
    XCTAssertEqual(v3.z, 5.f);

    simd_float4 v4 = SIMD_Vector4(GLKVector4Make(6.f, 7.f, 8.f, 9.f));
    XCTAssertEqual(v4.x, 6.f);
    XCTAssertEqual(v4.y, 7.f);
    XCTAssertEqual(v4.z, 8.f);
    XCTAssertEqual(v4.w, 9.f);
}

@end
