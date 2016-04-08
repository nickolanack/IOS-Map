
//
//  Created by Nick Blackwell on 2013-07-25.
//
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>


@protocol StyleProvider <NSObject>

@optional

- (UIColor *) colorForNamedStyle:(NSString *)name withDefault:(UIColor *)color;
- (NSString *) textForNamedLabel:(NSString *)name withDefault:(NSString *)text;
- (UIImage *) imageForNamedImage:(NSString *)name withDefault:(UIImage *)image;

@end
