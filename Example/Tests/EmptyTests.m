//
//  EmptyTests.m
//  DS
//
//  Created by Stan Liu on 06/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <Specta/Specta.h>
@import XCTest;
@import DS;

@interface NSArray (Sort)

-(NSArray *)sort;

@end

@implementation NSArray (Sort)

-(NSArray *)sort {
  
  return [self sortedArrayUsingSelector: @selector(localizedCompare:)];
}

-(NSArray *)dictSort {
  
  return [self sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    
    NSString *author1 = obj1[@"name"];
    NSString *author2 = obj2[@"name"];
    
    return [author1 localizedStandardCompare: author2];
  }];
}

@end

SpecBegin(EmptySpecs)

describe(@"remote is nil", ^{
  
  NSArray *remote = @[];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];

  // remoteHash is changed
  shadow = nil;
  
  NSDictionary *diff_client_emptyShadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  NSArray *newClient = [DS mergeInto: client applyDiff: diff_client_emptyShadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect(need_to_apply_to_remote).to.equal([DS diffWins: client andLoses: nil]);
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

describe(@"client is nil", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = nil;
  
  // last synchronized result == remote
  NSArray *shadow = nil;
  
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
  
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"}
                                            ]);
  });
});

SpecEnd