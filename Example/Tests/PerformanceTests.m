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

@property NSArray *remote;
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
  NSMutableArray *emptyArray3 = [NSMutableArray array];
  self.remote = [self generate: emptyArray3];
}

-(NSArray *)generate:(NSMutableArray *)array {
  
  if (array.count > 150) {
    return array;
  }
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSDictionary *object = [self dicFormat: [self generateLettersLength: 3 intoArray: array]
                                   value: [NSString stringWithFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length] - 1)]]];
  [array addObject: object];
  return [self generate: array];
}

-(NSString *)generateLettersLength:(int)length intoArray:(NSArray *)array {
  
  NSString *key = [self generateLettersBy: length on: [NSMutableString string]];
  
  if ([self checkDuplicateFromKey: key array: array]) {
    return [self generateLettersLength: length intoArray: array];
  } else {
    return key;
  }
}

-(NSString *)generateLettersBy:(int)length on:(NSMutableString *)string {
  
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  NSString *key = [NSString stringWithFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length] - 1)]];
  [string appendFormat: @"%@", key];
  
  if (string.length >= length) {
    return string;
  } else {
    return [self generateLettersBy: length on: string];
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
  self.remote = nil;
  
  [super tearDown];
}

- (void)testPerformanceExample {
  
  
  NSDictionary *diff_client_shadow = [DS diffWins: _client loses: _shadow primaryKey: @"name"];
  
  NSDictionary *diff_remote_client = [DS diffWins: _remote loses: _client primaryKey: @"name"];
  
  [self measureBlock:^{
    
    NSArray *newClient = [DS mergeInto: _shadow applyDiff: diff_remote_client];
    
    newClient = [DS mergeInto: newClient
                    applyDiff: diff_client_shadow
                   primaryKey: @"name"
                shouldReplace:^BOOL(id oldValue, id newValue) {
                  
                  return NO;
                }];
  }];
}

@end
