//
//  TerrainTests.m
//  GLGameEngineTests
//
//  Uses Terrain's CPU-only initializer (raw RGBA heightmap bytes, no Loader/GPU)
//  to test the world-space height sampling.
//
//  Height formula: (r+g+b)/768 * 2*MAX_HEIGHT - MAX_HEIGHT with MAX_HEIGHT = 20,
//  so black = -20, mid-gray (128) = 0, white = 765/768*40-20 = 19.84375.
//

#import <XCTest/XCTest.h>
#import "Terrain.h"

static const NSUInteger kMapSize = 4;
static const GLfloat kWhiteHeight = 765.f / 768.f * 40.f - 20.f; // 19.84375
static const GLfloat kBlackHeight = -20.f;

@interface TerrainTests : XCTestCase
@end

@implementation TerrainTests

// Builds a kMapSize x kMapSize RGBA map with every pixel set to `gray`
- (Terrain *)terrainWithUniformGray:(uint8_t)gray gridX:(GLint)gridX gridZ:(GLint)gridZ
{
    uint8_t pixels[kMapSize * kMapSize * 4];
    for (NSUInteger i = 0; i < kMapSize * kMapSize; i++) {
        pixels[i * 4 + 0] = gray;
        pixels[i * 4 + 1] = gray;
        pixels[i * 4 + 2] = gray;
        pixels[i * 4 + 3] = 255;
    }

    return [[Terrain alloc] initWithGridX:gridX gridZ:gridZ heightMapData:pixels width:kMapSize height:kMapSize];
}

// All black except a white pixel at map coordinate (0,0)
- (Terrain *)terrainWithWhiteOriginPixelGridX:(GLint)gridX gridZ:(GLint)gridZ
{
    uint8_t pixels[kMapSize * kMapSize * 4] = { 0 };
    for (NSUInteger i = 0; i < kMapSize * kMapSize; i++) {
        pixels[i * 4 + 3] = 255;
    }
    pixels[0] = pixels[1] = pixels[2] = 255;

    return [[Terrain alloc] initWithGridX:gridX gridZ:gridZ heightMapData:pixels width:kMapSize height:kMapSize];
}

- (void)testUniformGrayMapIsFlatZero
{
    Terrain *terrain = [self terrainWithUniformGray:128 gridX:0 gridZ:0];

    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:0.f worldZ:0.f], 0.f, 1e-3);
    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:123.f worldZ:45.f], 0.f, 1e-3);
    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:399.f worldZ:399.f], 0.f, 1e-3);
}

- (void)testUniformBlackMapIsFlatMinusMaxHeight
{
    Terrain *terrain = [self terrainWithUniformGray:0 gridX:0 gridZ:0];

    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:200.f worldZ:100.f], kBlackHeight, 1e-3);
}

- (void)testHeightAtGridCorner
{
    Terrain *terrain = [self terrainWithWhiteOriginPixelGridX:0 gridZ:0];

    // world (0,0) is exactly the white grid point
    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:0.f worldZ:0.f], kWhiteHeight, 1e-3);

    // far corner of the map is black
    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:399.f worldZ:399.f], kBlackHeight, 1e-3);
}

- (void)testHeightInterpolatesBetweenGridPoints
{
    Terrain *terrain = [self terrainWithWhiteOriginPixelGridX:0 gridZ:0];

    // halfway along the first cell's top edge: barycentric mix of the white
    // (0,0) and black (1,0) grid points
    GLfloat gridSquareSize = TERRAIN_SIZE / (kMapSize - 1);
    GLfloat expected = (kWhiteHeight + kBlackHeight) / 2.f;

    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:gridSquareSize / 2.f worldZ:0.f], expected, 1e-3);
}

- (void)testGridOffsetShiftsWorldCoordinates
{
    // the demo scene uses gridZ = -1: terrain covers z in [-400, 0]
    Terrain *terrain = [self terrainWithWhiteOriginPixelGridX:0 gridZ:-1];

    XCTAssertEqualWithAccuracy([terrain getHeightAtWorldX:0.f worldZ:-TERRAIN_SIZE], kWhiteHeight, 1e-3);
}

- (void)testOutOfBoundsReturnsZero
{
    Terrain *terrain = [self terrainWithUniformGray:255 gridX:0 gridZ:0];

    XCTAssertEqual([terrain getHeightAtWorldX:-10.f worldZ:0.f], 0.f);
    XCTAssertEqual([terrain getHeightAtWorldX:0.f worldZ:1000.f], 0.f);
}

@end
