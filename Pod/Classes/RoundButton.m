//
//  RoundButton.m
//  Pods
//
//  Created by Nick Blackwell on 2016-03-08.
//
//

#import "RoundButton.h"

@implementation RoundButton


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
   

    self.layer.cornerRadius =  MIN(self.frame.size.width/2, self.frame.size.height/2);
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 5;
    
    self.layer.masksToBounds=true;

    

    
    return self;
    
}


- (void)setSelected:(BOOL)selected {
    
    self.layer.cornerRadius =  MIN(self.frame.size.width/2, self.frame.size.height/2);
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 5;
    
    [super setSelected:selected];
    
    
    
}

@end
