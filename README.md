# DS

[![CI Status](http://img.shields.io/travis/lyc2345/DS.svg?style=flat)](https://travis-ci.org/lyc2345/DS)
[![Version](https://img.shields.io/cocoapods/v/DS.svg?style=flat)](http://cocoapods.org/pods/DS)
[![License](https://img.shields.io/cocoapods/l/DS.svg?style=flat)](http://cocoapods.org/pods/DS)
[![Platform](https://img.shields.io/cocoapods/p/DS.svg?style=flat)](http://cocoapods.org/pods/DS)

Inspired by Neil Fraser, [Differential Synchronization](https://neil.fraser.name/writing/sync/).

![Image of DS](https://neil.fraser.name/writing/sync/diff2.gif) 


## Usage
Differential Synchronizatioin step by step
1. diff client and shadow
2. apply remote into client
3. apply client_shadow (step.1) into newClient (step.2)
4. diff remote and whole new client(step.3)
5. push diff(step.4) , whole new client == new remote
6. if push success, save whole new client in shadow.

## Example
```objective-c
NSArray *remote = @[@"A", @"B", @"C"];
NSArray *client = @[@"A", @"B", @"C", @"D"]; // client add "D"
NSArray *shadow = @[@"A", @"B", @"C"]; // last synchronized result == remote

// obtain a diff from client and shadow.
NSDictionary *diff_client_shadow = [DS diffShadowAndClient: client shadow: shadow];

// obtain a diff from remote and client.
NSDictionary *need_to_apply_to_client = [DS diffWins: remote andLoses: client];
// apply remote_cilent_diff into client.
NSArray *newClient = [DS mergeInto: client applyDiff: need_to_apply_to_client];

// obtain a new client that applied diff_remote_client and diff_client_shadow.
newClient = [DS mergeInto: newClient applyDiff: diff_client_shadow];

// obtain a diff from remote and newClient.
NSDictionary *need_to_apply_to_remote = [DS diffShadowAndClient: newClient shadow: shadow];

// assuming push diff to remote.
NSArray *newRemote = [DS mergeInto: remote applyDiff: need_to_apply_to_remote];

// assuming push successfully. save newRemote in shadow
shadow = newRemote

// shadow == newRemote == newClient = @[@"A", @"B", @"C", @"D"];
	
```
This example you can refer to Tests.m line: 119, test 3.1



To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Installation

DS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

### Manual
Drag DS.h/DS.m into your project.

### Use Cocoapods
```ruby
pod "DS", :git=> 'https://www.github.com/lyc2345/DS.git'

OR 

pod "DS"
```

## Author

lyc2345, lyc2345@gmail.com

## License

DS is available under the MIT license. See the LICENSE file for more info.
