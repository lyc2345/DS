//
//  DS.m
//  Differential
//
//  Created by Stan Liu on 22/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "DS.h"

@implementation DS (Private)

// generate diff content
+(NSDictionary *)diffSetsFormatFromWin:(NSMutableSet *)wins loses:(NSMutableSet *)loses {
  
  return @{@"_winSet": wins, @"_loseSet": loses};
}

+(NSDictionary *)diffFormatFromAdd:(NSArray *)add delete:(NSArray *)delete replace:(NSArray *)replace {
  
  return @{@"_add": add, @"_delete": delete, @"_replace": replace};
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
  
  if (!(winsMutableSet.count > 0 || losesMutableSet.count > 0)) {
    return nil;
  }
  // e.g. diff = Add: [+D], Delete: [-A]
  NSDictionary *diffSet = [DS diffSetsFormatFromWin: winsMutableSet loses: losesMutableSet];
  return diffSet;
}

@end

@implementation DS

+(NSDictionary *)diffShadowAndClient:(NSArray *)client shadow:(NSArray *)shadow {
  
  NSDictionary *sets = [DS diffSetWins: client losesSet: shadow];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  //NSLog(@"diff: %@", diff);
  return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  // replace is empty because this case the duplicate always add new, delete old.
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses
               primaryKey:(NSString *)key {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  NSMutableArray *oldValue = [NSMutableArray array];
  NSMutableArray *newValue = [NSMutableArray array];
  
  [waitToAdd enumerateObjectsUsingBlock:^(id  _Nonnull addObj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    [waitToDelete enumerateObjectsUsingBlock:^(id  _Nonnull delObj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      // if 2 dictioanries have same primary key
      if ([addObj[key] isEqualToString: delObj[key]]) {
        
        // means the object in waitToAdd array will be the new value, opposite old value in waitToDelete.
        [newValue addObject: addObj];
        [oldValue addObject: delObj];
      }
    }];
  }];
  
  // newAdd just keep the data that never keep before.
  NSMutableSet *originAddSet = [NSMutableSet setWithArray: waitToAdd];
  [originAddSet minusSet: [NSSet setWithArray: newValue]];
  NSArray *newAdd = [originAddSet allObjects];

  // newValue is the data that keeps before and now going to edit.
  return [DS diffFormatFromAdd: newAdd delete: waitToDelete replace: newValue];
}

+(NSDictionary *)compareWinsDiff:(NSDictionary *)winsDiff
                       losesDiff:(NSDictionary *)losesDiff
                      primaryKey:(NSString *)primaryKey
                   shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
  // only replace will compare shouldReplace or not
  NSMutableSet *winsAdd     = [NSMutableSet setWithArray: winsDiff[@"_add"]];
  NSMutableSet *winsDelete  = [NSMutableSet setWithArray: winsDiff[@"_delete"]];
  NSMutableSet *winsReplace = [NSMutableSet setWithArray: winsDiff[@"_replace"]];
  NSMutableSet *losesAdd     = [NSMutableSet setWithArray: losesDiff[@"_add"]];
  NSMutableSet *losesDelete  = [NSMutableSet setWithArray: losesDiff[@"_delete"]];
  NSMutableSet *losesReplace = [NSMutableSet setWithArray: losesDiff[@"_replace"]];
  
  // 1.
  // winsAdd need to minus losesDelete = finalAdd
  [losesDelete minusSet: winsAdd];
  // winsLoses need to minus losesWins = finalDelete
  [losesAdd minusSet: winsDelete];

  // 2.
  [winsAdd unionSet: losesAdd];
  [winsDelete unionSet: losesDelete];
  
  // 3. calculate replace
  NSMutableArray *winsReplaceArray = [[winsReplace allObjects] mutableCopy];
  NSMutableArray *losesReplaceArray = [[losesReplace allObjects] mutableCopy];
  [losesAdd enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", primaryKey, obj[primaryKey]];
    NSArray *filteredArray = [winsReplaceArray filteredArrayUsingPredicate: predicate];
    if (filteredArray.count > 0) {
      [losesReplaceArray addObject: obj];
    }
  }];
  [winsAdd enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", primaryKey, obj[primaryKey]];
    NSArray *filteredArray = [losesReplaceArray filteredArrayUsingPredicate: predicate];
    if (filteredArray.count > 0) {
      [winsReplaceArray addObject: obj];
    }
  }];
  
  // 4. ask user should replace
  BOOL replace = shouldReplace(losesReplaceArray, winsReplaceArray);
  
  NSMutableArray *waitToReplace = replace == YES ? losesReplaceArray : winsReplaceArray;
  [losesReplace enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", primaryKey, obj[primaryKey]];
    NSArray *filteredArray = [waitToReplace filteredArrayUsingPredicate: predicate];
    if (filteredArray.count == 0) {
      [waitToReplace addObject: obj];
    }
  }];
  
  NSMutableArray *waitToAdd = [NSMutableArray arrayWithArray: [winsAdd allObjects]];
  NSMutableArray *waitToDelete = [NSMutableArray arrayWithArray: [winsDelete allObjects]];
  
  [waitToReplace enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", primaryKey, obj[primaryKey]];
    NSArray *duplicateAdd = [waitToAdd filteredArrayUsingPredicate: predicate];
    if (duplicateAdd.count > 0) {
      [waitToAdd removeObjectsInArray: duplicateAdd];
    }
//    NSArray *duplicateDelete = [waitToDelete filteredArrayUsingPredicate: predicate];
//    if (duplicateDelete.count > 0) {
//      [waitToDelete removeObjectsInArray: duplicateDelete];
//    }
  }];
  
  return [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: waitToReplace];
}

+(NSArray *)mergeInto:(NSArray *)into applyDiff:(NSDictionary *)diff {
  
  if (!diff) { return into; }
  if (!into) { into = [NSArray array]; }
  
  NSArray *add = diff[@"_add"];
  NSArray *delete = diff[@"_delete"];
  NSArray *replace = diff[@"_replace"];
  
  NSMutableSet *intoMutableSet = [NSMutableSet setWithArray: into];
  
  NSSet *deleteSet = [NSSet setWithArray: delete];
  [intoMutableSet minusSet: deleteSet];
  
  NSMutableArray *newInto = [[intoMutableSet allObjects] mutableCopy];
  
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

+(NSArray *)mergeInto:(NSArray *)array
            applyDiff:(NSDictionary *)diff
           primaryKey:(NSString *)key
        shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
  
  if (!diff) { return array; }
  if (!array) { array = [NSArray array]; }
  if (!key) { assert(@"primary key can't be nil"); }
  
  NSArray *add = diff[@"_add"];
  NSArray *delete = diff[@"_delete"];
  NSArray *replace = diff[@"_replace"];
  
  NSMutableSet *intoMutableSet = [NSMutableSet setWithArray: array];
  
  NSSet *deleteSet = [NSSet setWithArray: delete];
  [intoMutableSet minusSet: deleteSet];
  
  NSMutableArray *newDuplicated = [NSMutableArray array];
  NSMutableArray *oldDuplicated = [NSMutableArray array];
  [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", key, obj[key]];
    NSArray *filteredArray = [add filteredArrayUsingPredicate: predicate];
    if (filteredArray.count > 0) {
      [newDuplicated addObjectsFromArray: filteredArray];
      [oldDuplicated addObject: obj];
    }
  }];
  [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", key, obj[key]];
    NSArray *filteredArray = [replace filteredArrayUsingPredicate: predicate];
    if (filteredArray.count > 0) {
      [newDuplicated addObjectsFromArray: filteredArray];
      [oldDuplicated addObject: obj];
    }
  }];
  // to choose use new or old
  BOOL needReplace = shouldReplace(oldDuplicated, newDuplicated);
  replace = needReplace == YES ? newDuplicated : oldDuplicated;
  
  NSMutableArray *editedRelace = [NSMutableArray array];
  [replace enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K = %@", key, obj[key]];
    NSArray *filteredArray = [array filteredArrayUsingPredicate: predicate];
    if (filteredArray.count > 0) {
      [editedRelace addObject: obj];
    }
  }];
  
  NSMutableSet *addMutableSet = [NSMutableSet setWithArray: add];
  // if choose use new set, need to delete old set
  [addMutableSet minusSet: [NSSet setWithArray: newDuplicated]];
  [addMutableSet minusSet: [NSSet setWithArray: oldDuplicated]];
  [intoMutableSet minusSet: [NSSet setWithArray: newDuplicated]];
  [intoMutableSet minusSet: [NSSet setWithArray: oldDuplicated]];
  
  NSMutableArray *newInto = [[intoMutableSet allObjects] mutableCopy];
  [addMutableSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
    
    if (![newInto containsObject: obj]) {
      [newInto addObject: obj];
    }
  }];
  [editedRelace enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if (![newInto containsObject: obj]) {
      [newInto addObject: obj];
    }
  }];
  return newInto;
}



@end


@implementation Performance

-(void)run:(void(^)())block {
  
  NSDate *methodStart = [NSDate date];
  
  block();
  /* ... Calculate million seconds  ... */
  NSDate *methodFinish = [NSDate date];
  NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate: methodStart];
  NSLog(@"executionTime = %f", executionTime);
}

@end


/*
 +(NSDictionary *)diffWins:(NSArray *)wins
 andLoses:(NSArray *)loses
 primaryKey:(NSString *)key
 shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
 
 NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
 if (!sets) {
 return nil;
 }
 
 NSMutableSet *winsMutableSet = sets[@"_winSet"];
 NSMutableSet *losesMutableSet = sets[@"_loseSet"];
 
 NSArray *waitToAdd = [winsMutableSet allObjects];
 NSArray *waitToDelete = [losesMutableSet allObjects];
 
 NSMutableArray *oldValue = [NSMutableArray array];
 NSMutableArray *newValue = [NSMutableArray array];
 
 [waitToAdd enumerateObjectsUsingBlock:^(id  _Nonnull addObj, NSUInteger idx, BOOL * _Nonnull stop) {
 
 [waitToDelete enumerateObjectsUsingBlock:^(id  _Nonnull delObj, NSUInteger idx, BOOL * _Nonnull stop) {
 
 // if 2 dictioanries have same primary key
 if ([addObj[key] isEqualToString: delObj[key]]) {
 
 // means the object in waitToAdd array will be the new value, opposite old value in waitToDelete.
 [newValue addObject: addObj];
 [oldValue addObject: delObj];
 }
 }];
 }];
 
 // send these old and new value, let user to define which one are going to be keep.
 BOOL replace = shouldReplace(oldValue, newValue);
 
 // newAdd just keep the data that never keep before.
 NSMutableSet *originAddSet = [NSMutableSet setWithArray: waitToAdd];
 [originAddSet minusSet: [NSSet setWithArray: newValue]];
 NSArray *newAdd = [originAddSet allObjects];
 
 if (!replace) {
 
 NSMutableSet *originDelSet = [NSMutableSet setWithArray: waitToDelete];
 [originDelSet minusSet: [NSSet setWithArray: oldValue]];
 // if don't replace. leave old data and delete the changed data.
 // p.s. just keep the data that want to remove BUT NOT EDIT
 NSArray *newDel = [originDelSet allObjects];
 
 return [DS diffFormatFromAdd: newAdd delete: newDel replace: @[]];
 }
 // newValue is the data that keeps before and now going to edit.
 return [DS diffFormatFromAdd: newAdd delete: waitToDelete replace: newValue];
 }
 */

