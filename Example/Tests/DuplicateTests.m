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



describe(@"custom differential use duplicate and replace handler, same key but value changed 1.0", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
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
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"B", @"url": @"B"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

describe(@"custom differential use duplicate and replace handler, same key but value changed 2.0", ^{
  
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
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

describe(@"custom differential use duplicate and replace handler, same key but value changed but without replacing 3.0", ^{
  
  NSArray *remote = @[
                      @{@"name": @"A", @"url": @"A"},
                      @{@"name": @"B", @"url": @"B"},
                      @{@"name": @"C", @"url": @"C"}
                      ];
  
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
  
  // [+D]
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return NO;
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
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});


describe(@"custom differential use duplicate and replace handler, same key but value changed; If return duplicate is nil. the shouldReplace will be ignore at all time  4.0", ^{
  
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
  // add    : [@{@"name": @"D", @"url": @"D"}]
  // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
  // replace: [@{@"name": @A", @"url": @"A1"}]
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  /*
   // shadow @[@{@"name": @"A", @"url": @"A"},
   @{@"name": @"B", @"url": @"B"},
   @{@"name": @"C", @"url": @"C"}]
   
   // diff
   // add    : [@{@"name": @"D", @"url": @"D"}],
   // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
   // replace: [@{@"name": @A", @"url": @"A1"}]
   */
  
  // obtain a diff from remote and client.
  // diff
  // add    : [@{@"name": @B", @"url": @"B"}],
  // delete : []
  // replace: [@{@"name": @A", @"url": @"A"}]
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
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

describe(@"example in README.md", ^{
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
  // add    : [@{@"name": @"D", @"url": @"D"}]
  // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
  // replace: [@{@"name": @A", @"url": @"A1"}]
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow primaryKey: @"name" shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  }];
  /*
   // shadow @[@{@"name": @"A", @"url": @"A"},
   @{@"name": @"B", @"url": @"B"},
   @{@"name": @"C", @"url": @"C"}]
   
   // diff
   // add    : [@{@"name": @"D", @"url": @"D"}],
   // delete : [@{@"name": @"B", @"url": @"B"}, @{@"name": @"A", @"url": @"A"}]
   // replace: [@{@"name": @A", @"url": @"A1"}]
   */
  
  // obtain a diff from remote and client.
  // diff
  // add    : [@{@"name": @B", @"url": @"B"}],
  // delete : []
  // replace: [@{@"name": @A", @"url": @"A"}]
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
  
  // apply remote_cilent_diff into client.
  NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
  
  newClient = @[
                @{@"name": @"A", @"url": @"A1"},
                @{@"name": @"C", @"url": @"C"},
                @{@"name": @"D", @"url": @"D"}
                ];
  
  it(@"client == remote", ^{
    
    expect([newClient dictSort]).to.equal(@[
                                            @{@"name": @"A", @"url": @"A1"},
                                            @{@"name": @"C", @"url": @"C"},
                                            @{@"name": @"D", @"url": @"D"}
                                            ]);
  });
});

SpecEnd
