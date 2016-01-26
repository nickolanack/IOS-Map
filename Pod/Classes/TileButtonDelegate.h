//
//  TileButtonDelegate.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import <Foundation/Foundation.h>
#import "StyleButton.h"



@protocol TileButtonDelegate <NSObject>

@optional

-(void)userTappedButton:(StyleButton *)button InRow:(NSString *)row AtIndex:(int)index;


@end