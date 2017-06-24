//
//  DS.h
//  Differential
//
//  Created by Stan Liu on 22/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DS : NSObject

+(NSDictionary *)diffShadowAndClient:(NSArray *)client
                              shadow:(NSArray *)shadow;

+(NSDictionary *)diffWins:(NSArray *)wins andLoses:(NSArray *)loses;

+(NSDictionary *)diffWins:(NSArray *)wins
                 andLoses:(NSArray *)loses
                duplicate:(id(^)(id add, id delete))duplicate
            shouldReplace:(BOOL(^)(id deplicate))shouldReplace;


+(NSArray *)mergeInto:(NSArray *)into
            applyDiff:(NSDictionary *)diff;

@end
