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
  
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return YES;
  }];
  
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return YES;
  }];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
  
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
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
  
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return YES;
  }];
  
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return YES;
  }];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
  
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
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
  NSDictionary *diff_client_shadow = [DS diffWins: client andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return NO;
  }];
  
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return NO;
  }];
  
  NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
  
  newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient andLoses: shadow duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"name"] isEqualToString: obj[@"name"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return NO;
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

SpecEnd
