//
//  StyleButton.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-20.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "StyleButton.h"
#import <QuartzCore/QuartzCore.h>
@interface StyleButton ()

@property UIColor *defaultColor;
@property UIColor *selectedColor;

@end

@implementation StyleButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    self=[super initWithCoder:aDecoder];
    self.layer.cornerRadius = 4; // this value vary as per your desire
    //self.clipsToBounds = YES;
    
    self.layer.shadowColor = [UIColor redColor].CGColor;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 20;
    
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth=1.5;
    
    _defaultColor=self.backgroundColor;
    _selectedColor=[UIColor magentaColor];
    
    if(self.isSelected){
        [self setBackgroundColor:_selectedColor];
    }
    return self;
    
}

-(void)setSelected:(BOOL)selected{
    [self setBackgroundColor:(selected?_selectedColor:_defaultColor)];
    [super setSelected:selected];
    
}
-(void)setDefaultColor:(UIColor *)color{
    _defaultColor=color;
    [self setSelected:self.selected];
}
-(void)setSelectedColor:(UIColor *)color{
    _selectedColor=color;
    [self setSelected:self.selected];
}


-(UIColor *)getDefaultColor{
    return _defaultColor;
}
-(UIColor *)getSelectedColor{
    return _selectedColor;
}

@end
