# Carrierwave for iOS

Welcome to the **Carrierwave for iOS** project.

### Tools & requirements

- Xcode 6.0 with iOS 8.0 SDK
- [Carthage](https://github.com/Carthage/Carthage) 0.5
- [CocoaPods](https://github.com/CocoaPods/CocoaPods) 0.35
- [Uncrustify](https://github.com/bengardner/uncrustify) 0.61

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
 *  @returns Whether the magician suceeded in performing the magic trick.
 */
- (BOOL)performMagicTrick:(CRVMagicTrick *)trick;
```

### Authors

**Adrian Kashivskyy**

- [https://github.com/akashivskyy](https://github.com/akashivskyy)
- [https://twitter.com/akashivskyy](https://twitter.com/akashivskyy)

**Patryk Kaczmarek**

- [https://github.com/PatrykKaczmarek](https://github.com/PatrykKaczmarek)

**Wojciech Trzasko**

- [https://github.com/WojciechTrzasko](https://github.com/WojciechTrzasko)

### License

Carrierwave is licensed under the MIT License. See the [LICENSE.md](LICENSE.md) file for more info.
