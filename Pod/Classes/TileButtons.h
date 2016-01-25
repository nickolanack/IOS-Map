//
//  TileButtons.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import <Foundation/Foundation.h>
#import "StyleButton.h"

@interface TileButtons : NSObject

-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name;
-(void)addButtons:(NSArray *) buttons ToRow:(NSString *) name Toggler:(StyleButton *)button;


-(void)hide:(NSString *) name;
-(void)show:(NSString *) name;

@end
