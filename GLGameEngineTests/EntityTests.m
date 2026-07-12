//
//  EntityTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import "Entity.h"
#import "MatrixAssertions.h"

@interface EntityTests : XCTestCase
@end

@implementation EntityTests

// Entities are testable without a GPU model; only the texture-atlas offset
// getters need a real ModelTexture, so they are not covered here.
- (Entity *)makeEntity
{
    return [[Entity alloc] initWithTexturedModel:nil
                                        position:GLKVector3Make(1.f, 2.f, 3.f)
                                        rotation:MathUtils_RotationMake(10.f, 20.f, 30.f)
                                           scale:2.f
                                 andTextureIndex:0];
}

- (void)testDesignatedInitializerStoresState
{
    Entity *entity = [self makeEntity];

    AssertVector3EqualWithAccuracy(entity.position, GLKVector3Make(1.f, 2.f, 3.f), 1e-6);
    XCTAssertEqualWithAccuracy(entity.rotation.x, 10.f, 1e-6);
    XCTAssertEqualWithAccuracy(entity.rotation.y, 20.f, 1e-6);
    XCTAssertEqualWithAccuracy(entity.rotation.z, 30.f, 1e-6);
    XCTAssertEqualWithAccuracy(entity.scale, 2.f, 1e-6);
    XCTAssertNil(entity.model);
}

- (void)testIncreasePositionByVector
{
    Entity *entity = [self makeEntity];
    [entity increasePositionByVector:GLKVector3Make(0.5f, -1.f, 4.f)];

    AssertVector3EqualWithAccuracy(entity.position, GLKVector3Make(1.5f, 1.f, 7.f), 1e-5);
}

- (void)testIncreaseRotation
{
    Entity *entity = [self makeEntity];
    [entity increaseRotationByX:1.f y:2.f andZ:3.f];

    XCTAssertEqualWithAccuracy(entity.rotation.x, 11.f, 1e-5);
    XCTAssertEqualWithAccuracy(entity.rotation.y, 22.f, 1e-5);
    XCTAssertEqualWithAccuracy(entity.rotation.z, 33.f, 1e-5);

    [entity increaseRotationByRotation:MathUtils_RotationMake(-11.f, -22.f, -33.f)];
    XCTAssertEqualWithAccuracy(entity.rotation.x, 0.f, 1e-5);
    XCTAssertEqualWithAccuracy(entity.rotation.y, 0.f, 1e-5);
    XCTAssertEqualWithAccuracy(entity.rotation.z, 0.f, 1e-5);
}

- (void)testSetRotation
{
    Entity *entity = [self makeEntity];
    [entity setRotationX:90.f y:180.f andZ:270.f];

    XCTAssertEqualWithAccuracy(entity.rotation.x, 90.f, 1e-6);
    XCTAssertEqualWithAccuracy(entity.rotation.y, 180.f, 1e-6);
    XCTAssertEqualWithAccuracy(entity.rotation.z, 270.f, 1e-6);
}

- (void)testTransformationMatrixMatchesMathUtils
{
    Entity *entity = [self makeEntity];

    GLKMatrix4 expected = MathUtils_CreateTransformationMatrixr(entity.position, entity.rotation, entity.scale);
    AssertMatrix4EqualWithAccuracy(entity.currentTransformationMatrix, expected, 1e-6);
}

- (void)testTransformationMatrixFollowsMutations
{
    Entity *entity = [self makeEntity];

    // Every mutation path must be reflected in the next matrix read
    [entity increasePositionByVector:GLKVector3Make(5.f, 5.f, 5.f)];
    [entity increaseRotationByX:5.f y:0.f andZ:0.f];
    entity.scale = 0.5f;

    GLKMatrix4 expected = MathUtils_CreateTransformationMatrixr(entity.position, entity.rotation, entity.scale);
    AssertMatrix4EqualWithAccuracy(entity.currentTransformationMatrix, expected, 1e-6);

    entity.position = GLKVector3Make(-1.f, -2.f, -3.f);
    [entity setRotationX:0.f y:45.f andZ:0.f];

    expected = MathUtils_CreateTransformationMatrixr(entity.position, entity.rotation, entity.scale);
    AssertMatrix4EqualWithAccuracy(entity.currentTransformationMatrix, expected, 1e-6);
}

- (void)testCopyPreservesTransformState
{
    Entity *entity = [self makeEntity];
    Entity *copy = [entity copy];

    AssertVector3EqualWithAccuracy(copy.position, entity.position, 1e-6);
    XCTAssertEqualWithAccuracy(copy.rotation.x, entity.rotation.x, 1e-6);
    XCTAssertEqualWithAccuracy(copy.rotation.y, entity.rotation.y, 1e-6);
    XCTAssertEqualWithAccuracy(copy.rotation.z, entity.rotation.z, 1e-6);
    XCTAssertEqualWithAccuracy(copy.scale, entity.scale, 1e-6);
}

@end
