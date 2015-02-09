# carrierwave-ios

Welcome to the **carrierwave-ios** project.

## Requirements

- Xcode 6.0 with iOS 8.0 SDK
- [Carthage](https://github.com/Carthage/Carthage) 0.5
- [CocoaPods](https://github.com/CocoaPods/CocoaPods) 0.35 (use `gem install cocoapods` to grab it!)
- [Uncrustify](https://github.com/bengardner/uncrustify) 0.61

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party. To use **carrierwave-ios** via CocoaPods write in your Podfile:

```rb
pod 'Carrierwave', '~> 0.1.0'
```


### Configuration

Assuming the above tools are already installed, run the following commands after cloning the repository:

- `carthage update`
- `pod install`

### Coding guidelines

- Please respect [Ray Wenderlich's Objective-C style guide](https://github.com/raywenderlich/objective-c-style-guide).
- The code should be readable and self-explanatory - full variable names, meaningful methods, etc.
- Please **write documentation comments** in public header files.
- **Write tests** for every bug you fix and every feature you deliver.
- Please **don't leave** any commented-out code.
- Don't use pure `#pragma message` for warnings. Use the `CRVTemporary` and `CRVWorkInProgress` macros accordingly.
- Please use **feature flags** (located in `Carrierwave-Features.h` file) for enabling or disabling major features.

### Workflow

- Always hit ⌘U (Product → Test) before committing.
- Always commit to master. No remote branches.
- Use `[ci skip]` in the commit message for minor changes.

### Examples

#### Well documented method

```objc
/**
 *  Tells the magician to perform a given trick.
 *
 *  @param trick The magic trick to perform.
 *
 *  @returns Whether the magician succeeded in performing the magic trick.
 */
- (BOOL)performMagicTrick:(CRVMagicTrick *)trick;
```
Do you think it takes too much time? Try [this plugin](https://github.com/onevcat/VVDocumenter-Xcode) and change your mind!
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