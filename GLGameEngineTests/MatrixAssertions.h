//
//  MatrixAssertions.h
//  GLGameEngineTests
//
//  Element-wise XCTAssert helpers for GLKit matrix types.
//

#ifndef MatrixAssertions_h
#define MatrixAssertions_h

#import <GLKit/GLKit.h>
#import <XCTest/XCTest.h>

#define AssertMatrix4EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        GLKMatrix4 _a = (actual), _e = (expected); \
        for (int _i = 0; _i < 16; _i++) { \
            XCTAssertEqualWithAccuracy(_a.m[_i], _e.m[_i], accuracy, @"m[%d]", _i); \
        } \
    } while (0)

#define AssertMatrix3EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        GLKMatrix3 _a = (actual), _e = (expected); \
        for (int _i = 0; _i < 9; _i++) { \
            XCTAssertEqualWithAccuracy(_a.m[_i], _e.m[_i], accuracy, @"m[%d]", _i); \
        } \
    } while (0)

#define AssertVector3EqualWithAccuracy(actual, expected, accuracy) \
    do { \
        GLKVector3 _a = (actual), _e = (expected); \
        XCTAssertEqualWithAccuracy(_a.x, _e.x, accuracy); \
        XCTAssertEqualWithAccuracy(_a.y, _e.y, accuracy); \
        XCTAssertEqualWithAccuracy(_a.z, _e.z, accuracy); \
    } while (0)

#endif /* MatrixAssertions_h */
