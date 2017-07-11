//
//  DSTests.m
//  DSTests
//
//  Created by lyc2345 on 05/11/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

// https://github.com/Specta/Specta

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

SpecBegin(InitialSpecs)

describe(@"these will pass", ^{
  
  it(@"can do maths", ^{
    expect(1).beLessThan(23);
  });
  
  it(@"can read", ^{
    expect(@"team").toNot.contain(@"I");
  });
  
  it(@"will wait and succeed", ^{
    waitUntil(^(DoneCallback done) {
      done();
    });
  });
});


SpecEnd

SpecBegin(FirstSpec)

describe(@"See remote first, apply remote into client, 1.1", ^{
	
	NSArray *remote = @[@"A", @"C"];
	NSArray *client = @[@"A", @"B", @"C", @"D"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	it(@"client == remote", ^{
		
		expect([remote sort]).to.equal([newClient sort]);
	});
});

describe(@"See remote first, apply remote into client, 1.2", ^{
	
	NSArray *remote = @[@"A", @"B", @"C", @"D"];
	NSArray *client = @[@"A", @"B"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	it(@"client == remote", ^{
		
		expect([remote sort]).to.equal([newClient sort]);
	});
});

describe(@"See remote first, apply remote into client, 1.3", ^{
	
	NSArray *remote = @[@"A", @"C", @"D", @"E"];
	NSArray *client = @[@"A", @"B", @"D"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	it(@"client == remote", ^{
		
		expect([remote sort]).to.equal([newClient sort]);
	});
});

SpecEnd

SpecBegin(SecondSpec)

describe(@"See client first, apply client into remote, 2.1", ^{
	
	NSArray *remote = @[@"A", @"B"];
	NSArray *client = @[@"A", @"B", @"C", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *need_to_apply_to_remote = [DS diffWins: client loses: remote];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([client sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
	});
});

describe(@"See client first, apply client into remote, 2.2", ^{
	
	NSArray *remote = @[@"A", @"C", @"D", @"E"];
	NSArray *client = @[@"A", @"B", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *need_to_apply_to_remote = [DS diffWins: client loses: remote];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([client sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
	});
});

SpecEnd

SpecBegin(ThirdSpec)

describe(@"diff client_shadow first, apply remote into client, apply client_shadow_diff into remote, 3.1", ^{
	
	NSArray *remote = @[@"A", @"B", @"C"];
	NSArray *client = @[@"A", @"B", @"C", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
	
	newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
	NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([newClient sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
		expect([newRemote sort]).to.equal(@[@"A", @"B", @"C", @"D"]);
	});
});

describe(@"diff client_shadow first, remote is reset, reset shadow as well, prevent client doesn't wipe out if remote is reset, 3.2", ^{
	
	NSArray *remote = @[];
	NSArray *client = @[@"A", @"B", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
	
	newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
	NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([newClient sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
		expect([newClient sort]).to.equal(@[@"A", @"B", @"D"]);
	});
});

describe(@"different device start with empty shadow, diff client_shadow first, apply remote into client, apply client_shadow_diff into remote, 3.3", ^{
	
	NSArray *remote = @[@"A", @"B", @"C", @"D"];
	NSArray *client = @[@"E", @"F"];
	NSArray *shadow = @[];
	
	NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
	NSArray *newClient = [DS mergeInto: shadow applyDiff: need_to_apply_to_client];
	
	newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
	NSDictionary *need_to_apply_to_remote = [DS diffWins: newClient loses: remote];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([newClient sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
		expect([newClient sort]).to.equal(@[@"A", @"B", @"C", @"D", @"E", @"F"]);
	});
});

SpecEnd


SpecBegin(TestNoDiff)

describe(@"See diff nil 1.1", ^{
  
  NSArray *remote = @[@"A", @"B", @"C"];
  NSArray *client = @[@"A", @"B", @"C"];
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
  
  it(@"check diff is nil", ^{
    
    expect(need_to_apply_to_client).to.equal(nil);
  });
});

describe(@"See diff nil 1.2", ^{
  
  NSArray *remote = @[@"A"];
  NSArray *client = @[@"A"];
  NSDictionary *need_to_apply_to_client = [DS diffWins: remote loses: client];
  
  it(@"check diff is nil", ^{
    
    expect(need_to_apply_to_client).to.equal(nil);
  });
});

SpecEnd

/*
 describe(@"these will pass", ^{
 
 it(@"can do maths", ^{
 expect(1).beLessThan(23);
 });
 
 it(@"can read", ^{
 expect(@"team").toNot.contain(@"I");
 });
 
 it(@"will wait and succeed", ^{
 waitUntil(^(DoneCallback done) {
 done();
 });
 });
 });
 describe(@"these will fail", ^{
 
 it(@"can do maths", ^{
 expect(1).to.equal(2);
 });
 
 it(@"can read", ^{
 expect(@"number").to.equal(@"string");
 });
 
 it(@"will wait for 10 seconds and fail", ^{
 waitUntil(^(DoneCallback done) {
 
 });
 });
 });
 */
