//
//  StyleButton.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-20.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StyleButton : UIButton


-(void)setDefaultColor:(UIColor *)color;
-(void)setSelectedColor:(UIColor *)color;

-(UIColor *)getDefaultColor;
-(UIColor *)getSelectedColor;

@end
