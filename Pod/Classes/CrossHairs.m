//
//  CrossHairs.m
//  Pods
//
//  Created by Nick Blackwell on 2016-03-08.
//
//

#import "CrossHairs.h"

@implementation CrossHairs

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    self.layer.cornerRadius = 75; // this value vary as per your desire
    //self.clipsToBounds = YES;
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 5;
    
    self.layer.borderColor = [UIColor colorWithRed:11.0/255.0 green:96.0/255.0 blue:1.0 alpha:1.0].CGColor;
    self.layer.borderWidth=1.5;
    self.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    return self;
    
}

@end
