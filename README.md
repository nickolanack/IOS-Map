# Map

[![CI Status](http://img.shields.io/travis/nickolanack/Map.svg?style=flat)](https://travis-ci.org/nickolanack/Map)
[![Version](https://img.shields.io/cocoapods/v/Map.svg?style=flat)](http://cocoapods.org/pods/Map)
[![License](https://img.shields.io/cocoapods/l/Map.svg?style=flat)](http://cocoapods.org/pods/Map)
[![Platform](https://img.shields.io/cocoapods/p/Map.svg?style=flat)](http://cocoapods.org/pods/Map)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.


To transition to map within a project 
```ObjC

	
	- (IBAction)onTapMapButton:(id)sender {
    
	    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
	    UIViewController *myController = [storyboard instantiateInitialViewController];
	    [self.navigationController pushViewController: myController animated:YES];
    
	}



```

## Requirements

## Installation

Map is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Map"
```

## Author

nickolanack, nickblackwell82@gmail.com

## License

Map is available under the MIT license. See the LICENSE file for more info.
