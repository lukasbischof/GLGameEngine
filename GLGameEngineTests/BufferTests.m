//
//  BufferTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import "Buffer.h"

@interface BufferTests : XCTestCase
@end

@implementation BufferTests

- (void)testNoCopyAliasesCallerMemory
{
    float data[] = { 1.f, 2.f, 3.f };
    FloatBuffer buffer = FloatBufferCreateWithDataNoCopy(data, sizeof(data));

    XCTAssertEqual(buffer.data, (const float *)data);
    XCTAssertEqual(buffer.length, sizeof(data));
}

- (void)testCopyDuplicatesBytes
{
    float data[] = { 1.f, 2.f, 3.f, 4.f };
    FloatBuffer buffer = FloatBufferCreateWithDataCopy(data, sizeof(data));

    XCTAssertNotEqual(buffer.data, (const float *)data);
    XCTAssertEqual(buffer.length, sizeof(data));
    XCTAssertEqual(memcmp(buffer.data, data, sizeof(data)), 0);

    // mutating the source must not affect the copy
    data[0] = 99.f;
    XCTAssertEqual(buffer.data[0], 1.f);

    free((void *)buffer.data);
}

- (void)testUintBufferCopyRoundTrip
{
    uint32_t data[] = { 10, 20, 30 };
    UintBuffer buffer = UintBufferCreateWithDataCopy(data, sizeof(data));

    XCTAssertEqual(buffer.length, sizeof(data));
    XCTAssertEqual(memcmp(buffer.data, data, sizeof(data)), 0);

    free((void *)buffer.data);
}

- (void)testGenericBufferCopyRoundTrip
{
    uint8_t data[] = { 0xDE, 0xAD, 0xBE, 0xEF };
    Buffer buffer = BufferCreateWithDataCopy(data, sizeof(data));

    XCTAssertEqual(buffer.length, sizeof(data));
    XCTAssertEqual(memcmp(buffer.data, data, sizeof(data)), 0);

    free((void *)buffer.data);
}

- (void)testNullDataYieldsEmptyBuffer
{
    Buffer buffer = BufferCreateWithDataNoCopy(NULL, 16);
    XCTAssertEqual(buffer.data, NULL);
    XCTAssertEqual(buffer.length, 0);

    FloatBuffer floatBuffer = FloatBufferCreateWithDataCopy(NULL, 16);
    XCTAssertEqual(floatBuffer.data, NULL);
    XCTAssertEqual(floatBuffer.length, 0);
}

- (void)testZeroLengthCopyYieldsEmptyBuffer
{
    float data[] = { 1.f };
    FloatBuffer buffer = FloatBufferCreateWithDataCopy(data, 0);

    XCTAssertEqual(buffer.data, NULL);
    XCTAssertEqual(buffer.length, 0);
}

@end
