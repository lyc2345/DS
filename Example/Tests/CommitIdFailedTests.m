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

SpecBegin(CommitIdFailedTests)

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});


describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D1"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  // [-D, +A1, +B1]
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote
                           applyDiff: need_to_apply_to_remote
                          primaryKey: @"name"
                       shouldReplace:^BOOL(id oldValue, id newValue) {
                         return NO;
                       }];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"C", @"url": @"C"}
                                            ]);
  });
});

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D2"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  // [-D, +A1, +B1]
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D2"}
                                            ]);
  });
});


describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  // [-D, +A1, +B1]
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F"}
                                            ]);
  });
});

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C1"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  // [-D, +A1, +B1]
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F"}
                                            ]);
  });
});

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A2"},
                      @{@"name": @"B", @"url": @"B2"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C1"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  // [-D, +A1, +B1]
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return YES;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A2"},
                                            @{@"name": @"B", @"url": @"B2"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F"}
                                            ]);
  });
});

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"E", @"url": @"E"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"C", @"url": @"C2"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C1"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return NO;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"}
                                            ]);
  });
});

describe(@"commitId failed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B1"},
                      @{@"name": @"E", @"url": @"E"}
                      ];
  
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"C", @"url": @"C2"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C1"}
                      ];
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  // push failed
  
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return YES;
              }];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A"},
                                            @{@"name": @"B", @"url": @"B1"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"}
                                            ]);
  });
});


SpecEnd
