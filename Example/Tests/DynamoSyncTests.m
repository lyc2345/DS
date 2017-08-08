//
//  DynamoSyncTests.m
//  DS
//
//  Created by Stan Liu on 11/07/2017.
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

SpecBegin(DynamoSyncTests)

describe(@"s1p1 commitId passed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"}
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow];
  // commit id passed, not need to diff client remote
  //NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    return YES;
  }];
  
  it(@"s1p1", ^{
    expect([newClient dictSort]).to.equal([client dictSort]);
    expect([newRemote dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"},
                                            ]);
  });
});

describe(@"s1p2 commitId passed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"}
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow];
  // commit id passed, not need to diff client remote
  //NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    return YES;
  }];
  
  it(@"s1p2", ^{
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newRemote dictSort]).to.equal(@[
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F"}
                                            ]);
  });
});

describe(@"s2p1 commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"G", @"url": @"G"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"}
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow];
  
  NSArray *newClient = remote;
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
    return YES;
  }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"s2p1", ^{
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newRemote dictSort]).to.equal(@[
                        @{@"name": @"B", @"url": @"B"},
                        @{@"name": @"C", @"url": @"C"},
                        @{@"name": @"E", @"url": @"E"},
                        @{@"name": @"F", @"url": @"F"},
                        @{@"name": @"G", @"url": @"G"}
                        ]);
  });
});

describe(@"s1p3 commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"},
                      @{@"name": @"G", @"url": @"G"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F1"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  
  NSArray *newClient = remote;
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                return YES;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"s1p3", ^{
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newRemote dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F1"},
                                            @{@"name": @"G", @"url": @"G"}
                                            ]);
  });
});

SpecEnd
