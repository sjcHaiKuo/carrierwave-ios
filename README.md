# carrierwave-ios

**carrierwave-ios** is easy to use iOS library which provides flexible way to upload and edit asset files. Designed to integrate with [CarrierWave ruby gem](https://github.com/carrierwaveuploader/carrierwave), makes your work as fast as possible.

## Features:
**carrierwave-ios** handles:
* download and upload assets
* edit image assets
* image compression

## Requirements

- Xcode 6.0 with iOS 8.0 SDK
- [Carthage](https://github.com/Carthage/Carthage) 0.5
- [CocoaPods](https://github.com/CocoaPods/CocoaPods) 0.35 (use `gem install cocoapods` to grab it!)

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party. To use **carrierwave-ios** via CocoaPods write in your Podfile:

```rb
pod 'Carrierwave', '~> 0.1.0'
```

### Configuration

Just add `@import Carrierwave` in your source file whenever you want to use **carrierwave-ios**.

### Usage

`CRVNetworkManager` encapsulates the common tasks, including upload, download and delete asset. All supported assets should be wrapped with usage of `CRVAssetType` protocol. 

## Upload tasks

Declarations:

```objc
- (NSString *)uploadAsset:(id<CRVAssetType>)asset progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;
- (NSString *)uploadAsset:(id<CRVAssetType>)asset toURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVUploadCompletionBlock)completion;
```

Creating an upload proccess:

```objc
NSString *proccessId;
proccessId = [[CRVNetworkManager sharedManager] uploadAsset:asset progress:^(double progress) {
	NSLog(@"Progress: %f", progress);
} completion:^(CRVUploadInfo *info, NSError *error) {
	if (error) {
    	NSLog(@"Error: %@", error);
    } else {
    	NSLog(@"Success: %@", info);
	}                  
}]
```

## Download task

Declarations:

```objc
- (NSString *)downloadAssetWithIdentifier:(NSString *)identifier progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;
- (NSString *)downloadAssetFromURL:(NSURL *)url progress:(CRVProgressBlock)progress completion:(CRVDownloadCompletionBlock)completion;
```

Creating a download proccess:

```objc
	NSString *proccessId
	proccessId = [[CRVNetworkManager sharedManager] downloadAssetWithIdentifier:identifier progress:^(double progress) {
		NSLog(@"Progress: %f", progress);
	} completion:^(CRVImageAsset *asset, NSError *error) {
		if (error) {
	    	NSLog(@"Error: %@", error);
	    } else {
	    	NSLog(@"Success");
		}
	}
```

## Delete task 

Declarations:

```objc
- (void)deleteAssetWithIdentifier:(NSString *)identifier completion:(CRVCompletionBlock)completion;
- (void)deleteAssetFromURL:(NSURL *)url completion:(CRVCompletionBlock)completion;
```

Calling delete:

```objc
	[[CRVNetworkManager sharedManager] deleteAssetWithIdentifier:identifier completion:^(BOOL success, NSError *error) {
		if (error) {
	    	NSLog(@"Error: %@", error);
	    } else {
	    	NSLog(@"Success");
		}
	}
```

## Proccess management

`CRVNetworkManager` provides additional methods for handling lifecycle of upload or download processes, which are pretty straightforward and self-explanatory. As parameter all functions takes identifier returned by process creating methods.

```objc
- (void)cancelProccessWithIdentifier:(NSString *)identifier;
- (void)pauseProccessWithIdentifier:(NSString *)identifier;
- (void)resumeProccessWithIdentifier:(NSString *)identifier;
```

### Authors

**Adrian Kashivskyy**

- [https://github.com/akashivskyy](https://github.com/akashivskyy)
- [https://twitter.com/akashivskyy](https://twitter.com/akashivskyy)

**Patryk Kaczmarek**

- [https://github.com/PatrykKaczmarek](https://github.com/PatrykKaczmarek)

**Wojciech Trzasko**

- [https://github.com/WojciechTrzasko](https://github.com/WojciechTrzasko)

**Grzegorz Lesiak**

- [https://github.com/glesiak](https://github.com/glesiak)

**Paweł Białecki**

- [https://github.com/ecler](https://github.com/ecler)

## License
**carrierwave-ios** is available under the [MIT license](https://github.com/netguru/carrierwave-ios/blob/master/LICENSE.md).

## Contribution
First, thank you for contributing!

Here's a few guidelines to follow:

- we follow [Ray Wenderlich Style Guide](https://github.com/raywenderlich/objective-c-style-guide).
- write tests
- make sure the entire test suite passes

## More Info

Have a question? Please [open an issue](https://github.com/netguru/carrierwave-ios/issues/new)!

##
Copyright © 2014-2015 [Netguru](https://netguru.co)