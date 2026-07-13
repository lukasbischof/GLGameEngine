//
//  MatrixAssertions.h
//  GLGameEngineTests
//
//  Element-wise XCTAssert helpers for simd matrix/vector types.
//

#ifndef MatrixAssertions_h
#define MatrixAssertions_h

#include <simd/simd.h>
#import <XCTest/XCTest.h>

#define AssertMatrix4EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        simd_float4x4 _a = (actual), _e = (expected); \
        for (int _c = 0; _c < 4; _c++) { \
            for (int _r = 0; _r < 4; _r++) { \
                XCTAssertEqualWithAccuracy(_a.columns[_c][_r], _e.columns[_c][_r], accuracy, \
                                           @"column %d row %d", _c, _r); \
            } \
        } \
    } while (0)

#define AssertMatrix3EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        simd_float3x3 _a = (actual), _e = (expected); \
        for (int _c = 0; _c < 3; _c++) { \
            for (int _r = 0; _r < 3; _r++) { \
                XCTAssertEqualWithAccuracy(_a.columns[_c][_r], _e.columns[_c][_r], accuracy, \
                                           @"column %d row %d", _c, _r); \
            } \
        } \
    } while (0)

#define AssertVector3EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        simd_float3 _a = (actual), _e = (expected); \
        XCTAssertEqualWithAccuracy(_a.x, _e.x, accuracy); \
        XCTAssertEqualWithAccuracy(_a.y, _e.y, accuracy); \
        XCTAssertEqualWithAccuracy(_a.z, _e.z, accuracy); \
    } while (0)

#endif /* MatrixAssertions_h */
