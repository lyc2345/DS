//
//  DS.m
//  Differential
//
//  Created by Stan Liu on 22/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "DS.h"

@implementation DS

// generate diff content
+(NSDictionary *)diffSetsFormatFromWin:(NSMutableSet *)wins loses:(NSMutableSet *)loses {
  
  return @{@"_winSet": wins, @"_loseSet": loses};
}

+(NSDictionary *)diffFormatFromAdd:(NSArray *)add delete:(NSArray *)delete replace:(NSArray *)replace {
  
  return @{@"_add": add, @"_delete": delete, @"_replace": replace};
}

+(NSDictionary *)diffShadowAndClient:(NSArray *)client shadow:(NSArray *)shadow {
  
  NSDictionary *sets = [DS diffSetWins: shadow losesSet: client];
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToDelete = [winsMutableSet allObjects];
  NSArray *waitToAdd = [losesMutableSet allObjects];
  
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  //NSLog(@"diff: %@", diff);
  return diff;
}

// Generate both wins set and loses set.
/*
 e.g.
 wins  : [B, C, D]
 loses : [A, B, C]
 */
+(NSDictionary *)diffSetWins:(NSArray *)wins losesSet:(NSArray *)loses {
  
  // 1. Convert array to mutable set
  NSMutableSet *winsMutableSet = [NSMutableSet setWithArray: wins];
  NSMutableSet *losesMutableSet = [NSMutableSet setWithArray: loses];
  
  // 2. set common set as losesMutableSet (see losesMutableSet as origin sets)
  /*
   e.g. [A, B, C]
   */
  NSMutableSet *commonSet = [NSMutableSet setWithSet: losesMutableSet];
  
  // 3. intersect commonSet with winMutableSet
  // e.g. [A, B, C] intersect [B, C, D] = [B, C]
  [commonSet intersectSet: winsMutableSet];
  
  // 4. commonSet minus losesMutableSet because loses so = wait to be deleted
  // e.g. [A, B, C] - [B, C] = [A], because wait to be deleted = -A
  [losesMutableSet minusSet: commonSet];
  
  // 5. commonSet minus winMutableSet because wins so = wait to be added
  // e.g. [B, C, D] - [B, C] = [D], because wait to be added = +D
  [winsMutableSet minusSet: commonSet];
  
  // e.g. diff = Add: [+D], Delete: [-A]
  NSDictionary *diffSet = [DS diffSetsFormatFromWin: winsMutableSet loses: losesMutableSet];
  NSLog(@"diffSet: %@", diffSet);
  return diffSet;
}

+(NSDictionary *)diffWins:(NSArray *)wins andLoses:(NSArray *)loses {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  // replace is empty because this case the duplicate always add new, delete old.
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins
                 andLoses:(NSArray *)loses
                duplicate:(id(^)(id add, id delete))duplicate
            shouldReplace:(BOOL(^)(id deplicate))shouldReplace {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  NSArray *duplicated = duplicate(waitToAdd, waitToDelete);
  
  if (duplicated || duplicated.count > 0) {
    
    [winsMutableSet minusSet: [NSMutableSet setWithArray: duplicated]];
    NSArray *newAdd = [winsMutableSet allObjects];
    
    if (shouldReplace(duplicated)) {
      return [DS diffFormatFromAdd: newAdd delete: waitToDelete replace: duplicated];
    } else {
      return [DS diffFormatFromAdd: newAdd delete: @[] replace: @[]];
    }
  }
  return [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
}

+(NSArray *)mergeInto:(NSArray *)into applyDiff:(NSDictionary *)diff {
  
  NSMutableArray *newInto;
  
  NSArray *add = diff[@"_add"];
  NSArray *delete = diff[@"_delete"];
  NSArray *replace = diff[@"_replace"];
  
  NSMutableSet *intoMutableSet = [NSMutableSet setWithArray: into];
  
  NSSet *deleteSet = [NSSet setWithArray: delete];
  [intoMutableSet minusSet: deleteSet];
  
  newInto = [[intoMutableSet allObjects] mutableCopy];
  
  [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if (![newInto containsObject: obj]) {
      [newInto addObject: obj];
    }
  }];
  
  if (replace && replace.count > 0) {
    [replace enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      if (![newInto containsObject: obj]) {
        [newInto addObject: obj];
      }
    }];
  }
  
  return newInto;
}


@end

