//
//  DuplicateTests.m
//  DS
//
//  Created by Stan Liu on 24/06/2017.
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

SpecBegin(DuplicateSpecs)

describe(@"commitId passed, remoteHash passed, example in README.md", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  // diff
  // add    : [@{@"name": @"D", @"url": @"D"}]
  // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
  // replace: [@{@"name": @A", @"url": @"A1"}]
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  /*
   // shadow @[@{@"name": @"A", @"url": @"A"},
               @{@"name": @"B", @"url": @"B"},
               @{@"name": @"C", @"url": @"C"}]
   
   // diff
   // add    : [@{@"name": @"D", @"url": @"D"}],
   // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
   // replace: [@{@"name": @A", @"url": @"A1"}]
   */
  NSArray *newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
    return YES;
  }];
  
  // diff newClient and remote
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  
  // push diff_newClient_Remote to remote
  NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

describe(@"commitId failed, remoteHash passed", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"E", @"url": @"E"},
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];

  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: diff_client_shadow];
  // failed
  
  // pull
  newClient = remote;
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                return YES;
              }];

  
  NSDictionary *diff_newClient_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  
  NSArray *newRemote = [DS mergeInto: remote applyDiff: diff_newClient_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"},
                                            @{@"name": @"E", @"url": @"E"}
                                            ]);
  });
});


describe(@"commitId failed, remoteHash passed, example for README", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D1"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F1"},
                      @{@"name": @"G", @"url": @"G"},
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"F", @"url": @"F"},
                      @{@"name": @"G", @"url": @"G"},
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: diff_client_shadow];
  // failed
  
  // pull
  newClient = remote;

  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                it(@"check Replace", ^{
                  
                  expect([oldValue dictSort]).to.equal(@[
                                                         @{@"name": @"A", @"url": @"A"}
                                                         ]);
                  expect([newValue dictSort]).to.equal(@[
                                                         @{@"name": @"A", @"url": @"A1"}
                                                         ]);
                });
                
                return YES;
              }];

  
  NSDictionary *diff_newClient_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  
  NSArray *newRemote = [DS mergeInto: remote applyDiff: diff_newClient_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D1"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F1"},
                                            ]);
  });
});

describe(@"commitId failed, remoteHash passed, example for README", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D1"},
                      @{@"name": @"E", @"url": @"E"},
                      @{@"name": @"F", @"url": @"F1"},
                      @{@"name": @"G", @"url": @"G"},
                      ];
  
  // client add "D", change A' url to A1
  NSArray *client = @[
                      @{@"name": @"A", @"url": @"A1"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D2"}
                      ];
  
  // last synchronized result == remote
  NSArray *shadow = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"C", @"url": @"C"},
                      @{@"name": @"D", @"url": @"D"},
                      @{@"name": @"F", @"url": @"F"},
                      @{@"name": @"G", @"url": @"G"},
                      ];
  
  NSDictionary *diff_client_shadow = [DS diffWins: client loses: shadow primaryKey: @"name"];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: diff_client_shadow];
  // failed
  
  // pull
  newClient = remote;
  
  newClient = [DS mergeInto: newClient
                  applyDiff: diff_client_shadow
                 primaryKey: @"name"
              shouldReplace:^BOOL(id oldValue, id newValue) {
                
                it(@"check Replace", ^{
                  
                  expect([oldValue dictSort]).to.equal(@[
                                                         @{@"name": @"A", @"url": @"A"},
                                                         @{@"name": @"D", @"url": @"D1"}
                                                         ]);
                  expect([newValue dictSort]).to.equal(@[
                                                         @{@"name": @"A", @"url": @"A1"},
                                                         @{@"name": @"D", @"url": @"D2"}
                                                         ]);
                });
                
                return YES;
              }];
  
  
  NSDictionary *diff_newClient_remote = [DS diffWins: newClient loses: remote primaryKey: @"name"];
  
  NSArray *newRemote = [DS mergeInto: remote applyDiff: diff_newClient_remote];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal([newRemote dictSort]);
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D2"},
                                            @{@"name": @"E", @"url": @"E"},
                                            @{@"name": @"F", @"url": @"F1"},
                                            ]);
  });
});

SpecEnd
