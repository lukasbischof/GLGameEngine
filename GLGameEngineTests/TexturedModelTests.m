//
//  TexturedModelTests.m
//  GLGameEngineTests
//

#import <XCTest/XCTest.h>
#import "TexturedModel.h"

@interface TexturedModelTests : XCTestCase
@end

@implementation TexturedModelTests

- (void)testCopyIsEqualAndSharesHash
{
    TexturedModel *model = [[TexturedModel alloc] initWithRawModel:nil andTexture:nil];
    TexturedModel *copy = [model copy];

    // copies keep the UUID, so they must compare equal AND hash equal
    XCTAssertEqualObjects(model, copy);
    XCTAssertEqualObjects(copy, model);
    XCTAssertEqual(model.hash, copy.hash);
}

- (void)testDistinctModelsAreNotEqual
{
    TexturedModel *a = [[TexturedModel alloc] initWithRawModel:nil andTexture:nil];
    TexturedModel *b = [[TexturedModel alloc] initWithRawModel:nil andTexture:nil];

    XCTAssertNotEqualObjects(a, b);
    XCTAssertFalse([a isEqual:nil]);
    XCTAssertFalse([a isEqual:@"not a model"]);
}

- (void)testDictionaryLookupByCopy
{
    // This is exactly MasterRenderer's batching pattern: the entity map is
    // keyed by TexturedModel, and copied entities carry a copied model.
    TexturedModel *model = [[TexturedModel alloc] initWithRawModel:nil andTexture:nil];
    NSMutableDictionary<TexturedModel *, NSMutableArray *> *batches = [NSMutableDictionary dictionary];

    NSMutableArray *batch = [NSMutableArray arrayWithObject:@"entity"];
    batches[model] = batch;

    TexturedModel *copy = [model copy];
    XCTAssertEqualObjects(batches[copy], batch,
                          @"a copied model must resolve to the original's batch, not create a second one");

    [batches[copy] addObject:@"entity2"];
    XCTAssertEqual(batches.count, 1);
    XCTAssertEqual(batches[model].count, 2);
}

@end
