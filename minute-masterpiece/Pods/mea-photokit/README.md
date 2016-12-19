# mea-photokit


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

mea-photokit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "mea-photokit"

## Author

Daniel Loomb, daniel@meamobile.com

## License

mea-photokit is available under the MIT license. See the LICENSE file for more info.


## Issues

### Goooooooogle

GDataObject.h "ARC forbids Objective-C objects in struct" error

**FIX** Add __unsafe_unretained

```
#!objective-c

typedef struct GDataDescriptionRecord {
  __unsafe_unretained NSString *label;
  __unsafe_unretained NSString *keyPath;
  GDataDescRecTypes reportType;
} GDataDescriptionRecord;

```



Seeing **Duplicate Symbols** in the GTMHTTP classes?

```
#!bash

duplicate symbol _OBJC_CLASS_$_GTMGatherInputStream in:
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libGTMHTTPFetcher.a(GTMGatherInputStream.o)
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libgtm-http-fetcher.a(GTMGatherInputStream.o)
duplicate symbol _OBJC_METACLASS_$_GTMGatherInputStream in:
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libGTMHTTPFetcher.a(GTMGatherInputStream.o)
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libgtm-http-fetcher.a(GTMGatherInputStream.o)
duplicate symbol _OBJC_IVAR_$_GTMGatherInputStream.dataArray_ in:
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libGTMHTTPFetcher.a(GTMGatherInputStream.o)
    /Users/daniel/Library/Developer/Xcode/DerivedData/mea-photokit-agpihhrlsmtlkfgcynasursgumiw/Build/Products/Debug-iphonesimulator/libgtm-http-fetcher.a(GTMGatherInputStream.o)
duplicate symbol _OBJC_IVAR_$_GTMGatherInputStream.arrayIndex_ in:
```

Google includes two versions of the same code. 

**FIX** Remove ` -l"GTMHTTPFetcher"` from your **Pods/Targets Support Files/Pods-mea-photokit/Pods-mea-photokit.<env>.xconfig** file.