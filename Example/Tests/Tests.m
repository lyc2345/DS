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

@end

SpecBegin(InitialSpecs)

SpecEnd

SpecBegin(FirstSpec)

describe(@"See remote first, apply remote into client, 1.1", ^{
	
	NSArray *remote = @[@"A", @"C"];
	NSArray *client = @[@"A", @"B", @"C", @"D"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	it(@"client == remote", ^{
		
		expect([remote sort]).to.equal([newClient sort]);
	});
});

describe(@"See remote first, apply remote into client, 1.2", ^{
	
	NSArray *remote = @[@"A", @"B", @"C", @"D"];
	NSArray *client = @[@"A", @"B"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	it(@"client == remote", ^{
		
		expect([remote sort]).to.equal([newClient sort]);
	});
});

describe(@"See remote first, apply remote into client, 1.3", ^{
	
	NSArray *remote = @[@"A", @"C", @"D", @"E"];
	NSArray *client = @[@"A", @"B", @"D"];
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
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
	
	NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: client shadow:shadow];
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
	
	NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: client shadow:shadow];
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
	
	NSArray *remote = @[@"A", @"B", @"E"];
	NSArray *client = @[@"A", @"B", @"C", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	
	NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: newClient shadow: shadow];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([newClient sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
	});
});

describe(@"diff client_shadow first, remote is reset, reset shadow as well, prevent client doesn't wipe out if remote is reset, 3.2", ^{
	
	NSArray *remote = @[];
	NSArray *client = @[@"A", @"B", @"D"];
	NSArray *shadow = remote;
	
	NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
	NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: newClient shadow: shadow];
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
	
	NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
	NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];
	
	newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];
	
	NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: newClient shadow: shadow];
	NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];
	
	shadow = newRemote;
	
	it(@"client == remote", ^{
		
		expect([newClient sort]).to.equal([newRemote sort]);
		expect([newRemote sort]).to.equal([shadow sort]);
		expect([newClient sort]).to.equal(@[@"A", @"B", @"C", @"D", @"E", @"F"]);
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
