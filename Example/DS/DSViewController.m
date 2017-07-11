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
//                        @{
//                          @"comicName": @"A",
//                          @"author": @"A",
//                          @"url": @"A",
//                          },
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
	
	NSDictionary *diff = [DS diffWins: newValue loses: oldValue primaryKey: @"comicName"];
  
  
  NSLog(@"diff: %@", diff);
  
  
  NSDictionary *diff2 = [DS diffWins: @[@"B", @"C", @"D"] loses: @[@"A", @"B", @"C"]];

  NSLog(@"diff2: %@", diff2);
}

@end
