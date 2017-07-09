//
//  PerformaceTests.m
//  DS
//
//  Created by Stan Liu on 09/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
@import DS;

@interface PerformanceTests : XCTestCase

@property NSArray *client;
@property NSArray *shadow;

@end

@implementation PerformanceTests

- (void)setUp {
    [super setUp];
  
  
  NSMutableArray *emptyArray = [NSMutableArray array];
  self.client = [self generate: emptyArray];
  NSMutableArray *emptyArray2 = [NSMutableArray array];
  self.shadow = [self generate: emptyArray2];
  NSLog(@"%@", _client);
  NSLog(@"%@", _shadow);
}

-(NSArray *)generate:(NSMutableArray *)array {
  
  if (array.count > 30) {
    return array;
  }
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSDictionary *object = [self dicFormat: [self generateLetters: 2 fromArray: array]
                                   value: [NSString stringWithFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length] - 1)]]];
  [array addObject: object];
  return [self generate: array];
}

-(NSString *)generateLetters:(int)count fromArray:(NSArray *)array {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSString *key = [NSString stringWithFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length] - 1)]];
  
  if ([self checkDuplicateFromKey: key array: array]) {
    return [self generateLetters: count fromArray: array];
  } else {
    return key;
  }
}

-(BOOL)checkDuplicateFromKey:(NSString *)key array:(NSArray *)array {
  
  BOOL isDuplicate = NO;
  NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", @"name", key];
  if ([array filteredArrayUsingPredicate: predicate].count > 0) {
    isDuplicate = YES;
    return isDuplicate;
  } else {
    return NO;
  }
}

-(NSDictionary *)dicFormat:(NSString *)key value:(NSString *)value {
  
  return @{@"name": key, @"url": value};
}

-(void)tearDown {
  
  self.client = nil;
  self.shadow = nil;
  
  [super tearDown];
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    
    NSDictionary *diff_client_shadow = [DS diffWins: _client andLoses: _shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
      
      return YES;
    }];
    NSLog(@"%@", diff_client_shadow);
  }];
}

@end
