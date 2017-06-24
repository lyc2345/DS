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
+(NSDictionary *)diffFormatFromAdd:(NSArray *)add delete:(NSArray *)delete replace:(NSArray *)replace {
	
	return @{@"_add": add, @"_delete": delete, @"_replace": replace};
}

+(NSDictionary *)diffShadowAndClient:(NSArray *)client shadow:(NSArray *)shadow {
	
	NSMutableSet *shadowMutableSet = [NSMutableSet setWithArray: shadow];
	NSMutableSet *clientMutableSet = [NSMutableSet setWithArray: client];
	
	NSMutableSet *commonSet = [NSMutableSet setWithArray: client];
	
	[commonSet intersectSet: shadowMutableSet];
	
	[shadowMutableSet minusSet: commonSet];
	NSArray *waitToDelete = [shadowMutableSet allObjects];
	
	
	[clientMutableSet minusSet: commonSet];
	NSArray *waitToAdd = [clientMutableSet allObjects];
	
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
	//NSLog(@"diff: %@", diff);
	return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins andLoses:(NSArray *)loses {
  
  NSMutableSet *winsMutableSet = [NSMutableSet setWithArray: wins];
  NSMutableSet *losesMutableSet = [NSMutableSet setWithArray: loses];
  
  NSMutableSet *commonSet = [NSMutableSet setWithArray: loses];
  [commonSet intersectSet: winsMutableSet];
  
  [losesMutableSet minusSet: commonSet];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  [winsMutableSet minusSet: commonSet];
  NSArray *waitToAdd = [winsMutableSet allObjects];
  
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete];
  //NSDictionary *diff = [DS diffFormatFromConditionArray:@[waitToAddByClient, waitToAddByRemote]];
  //NSLog(@"diff: %@", diff);
  return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins
                 andLoses:(NSArray *)loses
                duplicate:(id(^)(id add, id delete))duplicate
            shouldReplace:(BOOL(^)(id deplicate))shouldReplace {
	
	NSMutableSet *winsMutableSet = [NSMutableSet setWithArray: wins];
	NSMutableSet *losesMutableSet = [NSMutableSet setWithArray: loses];
	
	NSMutableSet *commonSet = [NSMutableSet setWithArray: loses];
	[commonSet intersectSet: winsMutableSet];
	
	[losesMutableSet minusSet: commonSet];
	NSArray *waitToDelete = [losesMutableSet allObjects];
	
	[winsMutableSet minusSet: commonSet];
	NSArray *waitToAdd = [winsMutableSet allObjects];
  
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
  //NSDictionary *diff = [DS diffFormatFromConditionArray:@[waitToAddByClient, waitToAddByRemote]];
	//NSLog(@"diff: %@", diff);
  return [DS diffFormatFromAdd: waitToAdd delete: @[] replace: @[]];
}

+(NSArray *)mergeInto:(NSArray *)into applyDiff:(NSDictionary *)diff {
	
	NSMutableArray *newInto;
	
	NSArray *add = diff[@"_add"];
	NSArray *delete = diff[@"_delete"];
	
	NSMutableSet *intoMutableSet = [NSMutableSet setWithArray: into];
	
	NSSet *deleteSet = [NSSet setWithArray: delete];
	[intoMutableSet minusSet: deleteSet];
	
	newInto = [[intoMutableSet allObjects] mutableCopy];
	
	[add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (![newInto containsObject: obj]) {
			[newInto addObject: obj];
		}
	}];
	
	return newInto;
}


@end
