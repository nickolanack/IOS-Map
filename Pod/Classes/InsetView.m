//
//  InsetView.m
//  Pods
//
//  Created by Nick Blackwell on 2016-03-23.
//
//

#import "InsetView.h"

@implementation InsetView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
   //(context, CGSizeMake(0, 0), 10);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10,[UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.3].CGColor);

    CGContextMoveToPoint(context, self.frame.size.width-10, 0);
    CGContextAddLineToPoint(context, self.frame.size.width-10, self.frame.size.height);
    
    CGContextStrokePath(context);
}


@end
