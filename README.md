# carrierwave-ios

[![Circle CI](https://circleci.com/gh/netguru/carrierwave-ios/tree/master.svg?style=svg)](https://circleci.com/gh/netguru/carrierwave-ios/tree/master)

**carrierwave-ios** is easy to use iOS library which provides flexible way to download, upload and edit asset files. Designed to integrate with [CarrierWave ruby gem](https://github.com/carrierwaveuploader/carrierwave), makes your work as fast as possible.

## Features:
**carrierwave-ios** handles:
* download and upload assets
* edit image assets
* image compression

## Requirements

- Xcode 6.0 with iOS 8.0 SDK
- [Carthage](https://github.com/Carthage/Carthage) 0.5
- [CocoaPods](https://github.com/CocoaPods/CocoaPods) 0.36.0.rc.1 (use `sudo gem install cocoapods --pre` to grab it!)

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party. To use **carrierwave-ios** via CocoaPods write in your Podfile:

```rb
pod 'Carrierwave', '~> 0.1.0'
```

## Configuration

Just add `@import Carrierwave` in your source file whenever you want to use **carrierwave-ios**.

To connect **carrierwave-ios** with rails backend, you just need to set `serverURL` property in `[CRVNetworkManager sharedManager]` to your backend server url. We are recommending to make this in `application:didFinishLaunchingWithOptions:` method in your `AppDelegate` class.

## Usage

`CRVNetworkManager` encapsulates the common tasks, including upload, download and delete asset. All supported assets should be wrapped with usage of `CRVAssetType` protocol.

### Upload tasks

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

If upload finishes with success, method will return `CRVUploadInfo` object that wraps `assetIdentifier` of uploaded asset and server side path to it, stored in `assetPath` property.
For dynamic server urls please use `uploadAsset:toURL:progress:completion` method.

### Download task

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

For dynamic server urls please use `uploadAsset:toURL:progress:completion` method.

### Delete task 

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

For dynamic server urls please use `uploadAsset:toURL:progress:completion` method.

### Asset types

As mentioned before, all uploaded objects should conform to `CRVAssetType` protocol. **carrierwave-ios** comes with ready to use classes for common image and video file types.

`CRVImageAsset` dellivers basic interface for creating image asset from `NSURL` to local image file or instance of `NSData` or `UIImage`. It supports `gif`, `jpeg`, `tiff` and `png` file types. After creation, `image` property gives you access to UI representation. You can make compressed copy of image with usage:
```objc
- (instancetype)compressedImageAssetWithQuality:(CGFloat)quality;
```

`CRVVideoAsset` provides handy methods to create asset object from `NSData` instance or from local video file. It supports `mov` and `mp4` files. In addition, `CRVVideoAsset` can load selected video into `AVPlayerItem` with method:
```objc
- (void)loadVideoWithCompletion:(CRVVideoLoadCompletionBlock)completion; 
```

Usage example:

```objc
[asset loadVideoWithCompletion:^(AVPlayerItem *videoItem, NSError *error) {
	if (error) {
    	NSLog(@"Error: %@", error);
    } else {
    	NSLog(@"Video loaded");
	}
}];
```

### Proccess management

`CRVNetworkManager` provides additional methods for handling lifecycle of upload or download processes, which are pretty straightforward and self-explanatory. As parameter all functions takes identifier returned by process creating methods.

```objc
- (void)cancelProccessWithIdentifier:(NSString *)identifier;
- (void)pauseProccessWithIdentifier:(NSString *)identifier;
- (void)resumeProccessWithIdentifier:(NSString *)identifier;
```

## UI Component

As addition, **carrierwave-ios** delivers handy UI component for editing selected photos. `CRVImageEditViewController` is responsible for scaling, rotating and croping them. Here is some preview how it looks in demo app:

![crop view example](https://github.com/netguru/carrierwave-ios/blob/master/doc/2_crop_view.jpg "Crop view example")

### Usage

Usage is very simple, just create new instance and show it:

```objc
CRVImageEditViewController *controller =  [[CRVImageEditViewController alloc] initWithImageAsset:imageAsset];
controller.delegate = self;
[self presentViewController:controller animated:YES completion:nil];
```

If you are using storyboards, you can also drag new empty view controller in InterfaceBuilder and set its class to `CRVImageEditViewController`.

## UI configurability

We did our best to make `CRVImageEditViewController` as configurable as possible, that's why its interface expose bunch of useful properties to fit any app.

### Delegate

Setting `CRVImageEditViewControllerDelegate` gives possibility to inject own UI components in:

- header view - layouted at the top of the screen.
- footer view - layouted at the bottom of the screen.

The rest of the space is designed for scaling, rotating and cropping image. 


Bringing own UI components is available via implementation of methods:
```objc
- (UIView *)viewForHeaderInImageEditViewController:(CRVImageEditViewController *)controller;
- (UIView *)viewForFooterInImageEditViewController:(CRVImageEditViewController *)controller;
```
To create a view with communication feature, you have to sublass `CRVHeaderFooterView` class and use `eventMessenger` to post messages:

```objc
- (void)postCancelMessage;
- (void)postDoneMessage;
- (void)postShowRatioSheetMessage;
- (void)postResetTransformationMessage;
```
[Here](https://github.com/netguru/carrierwave-ios/blob/master/Carrierwave/CRVFooterView.m) is an example.

Specifying header and footer height is also possible:
```objc
- (CGFloat)heightForHeaderInImageEditViewController:(CRVImageEditViewController *)controller; //default 20 points
- (CGFloat)heightForFooterInImageEditViewController:(CRVImageEditViewController *)controller; //default 60 points
```

### Crop border

Crop border is customizable as well. It has bunch of options which help its to fit your app style. For more info please refer to [CRVScalableView](https://github.com/netguru/carrierwave-ios/blob/master/Carrierwave/CRVScalableView.h) and [CRVScalableBorder](https://github.com/netguru/carrierwave-ios/blob/master/Carrierwave/CRVScalableBorder.h)

#### Animation options
```
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) UIViewAnimationOptions animationCurve;
@property (assign, nonatomic) CGFloat springDamping;
@property (assign, nonatomic) CGFloat springVelocity;
```

#### Border grid

```objc
@property (assign, nonatomic) CRVGridDrawingMode gridDrawingMode;
@property (assign, nonatomic) CRVGridStyle gridStyle;
@property (strong, nonatomic) UIColor *gridColor;
@property (assign, nonatomic) NSUInteger gridThickness;
@property (assign, nonatomic) NSInteger numberOfGridlines;
```

#### Border
```objc
@property (assign, nonatomic) CRVBorderDrawingMode borderDrawinMode;
@property (assign, nonatomic) CRVBorderStyle borderStyle;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) NSUInteger borderThickness;
@property (assign, nonatomic) NSUInteger borderInset;
```

#### Anchors
```objc
@property (assign, nonatomic) CRVAnchorsDrawingMode anchorsDrawingMode;
@property (strong, nonatomic) UIColor *anchorsColor;
@property (assign, nonatomic) NSUInteger anchorThickness;
```

#### Custom drawing 
Although exposed properties are able to customize crop border a lot, there is special method provided to make your own drawing within existing context:
```objc
- (void)drawRect:(CGRect)rect withinContext:(CGContextRef)context;
```

#### Following on screen changes 

There is also a possibility to receive user events and react on them. Only thing you have to do, is to confirm `CRVScalableViewDelegate` protocol and implement methods your're interested in:
```objc
- (void)scalableViewDidBeginScaling:(CRVScalableView *)view;
- (void)scalableViewDidEndScaling:(CRVScalableView *)view;
- (void)scalableViewDidBeginMoving:(CRVScalableView *)view;
- (void)scalableViewDidEndMoving:(CRVScalableView *)view;
- (void)scalableViewDidMove:(CRVScalableView *)view;
- (void)scalableViewDidScale:(CRVScalableView *)view;
```

### Crop border animations

Animate crop view to given frame:
```objc
- (void)animateToFrame:(CGRect)frame completion:(void (^)(BOOL finished))completion;
```

Animate crop view to given size around its center:
```objc
- (void)animateToSize:(CGSize)size completion:(void (^)(BOOL finished))completion;
```

Animates crop view to given ratio around its center. Final dimensions are maximum possible values depending on superview bounds:
```objc
- (void)animateToRatio:(CGFloat)ratio completion:(void (^)(BOOL finished))completion;
```

Animations algorithm is smart enough to validate if given/calculated frame is located in the superview or not. If not origin and/or size will be changed to valid one. So you do not have to worry that crop view will move outside the boundaries of its superview.

## Demo

![demo example](https://github.com/netguru/carrierwave-ios/blob/master/doc/1_crop_view.jpg "Demo example")

**carrierwave-ios** comes with simple demo app which implements basic features of library like upload files and editing image assets. To run demo please follow the instructions below:

```bash
$ git clone --recursive git@github.com:netguru/carrierwave-ios.git
$ carthage update
$ pod install
```

or if you already cloned the project without `--recursive`:

```bash
$ git submodule update --init --recursive
$ carthage update
$ pod install
```

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

## Authors

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

Copyright © 2014-2015 [Netguru](https://netguru.co)
