//
//  DSViewController.m
//  DS
//
//  Created by lyc2345 on 05/11/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

#import "DSViewController.h"
#import <DS/DS.h>

@interface DSViewController ()

@end

@implementation DSViewController

- (void)viewDidLoad {
	[super viewDidLoad];
  
  NSArray *newValue = @[
                        @{
                          @"comicName": @"A",
                          @"author": @"A",
                          @"url": @"A",
                          },
                        @{
                          @"comicName": @"B",
                          @"author": @"author B",
                          @"url": @"https://www.wikipedia/B",
                          },
                        @{
                          @"comicName": @"C",
                          @"author": @"C",
                          @"url": @"C",
                          },
                        ];
  
  NSArray *oldValue = @[
                        @{
                          @"comicName": @"A",
                          @"author": @"A",
                          @"url": @"A",
                          },
                        @{
                          @"comicName": @"B",
                          @"author": @"B",
                          @"url": @"B",
                          }
                        ];
	
	NSDictionary *diff = [DS diffWins: newValue andLoses: oldValue duplicate:^id(id add, id delete) {
    
    __block NSMutableArray *replace = [NSMutableArray array];
    [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      NSDictionary *addObject = obj;
      [delete enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([addObject[@"comicName"] isEqualToString: obj[@"comicName"]]) {
          
          [replace addObject: addObject];
        }
      }];
    }];
    return replace.count > 0 ? replace : nil;
    
  } shouldReplace:^BOOL(id deplicate) {
    
    return NO;
  }];
  
  
  NSLog(@"diff: %@", diff);
  

}

@end
