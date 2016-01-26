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

-(void)userTapped:(StyleButton *)button InRow:(NSString *)name AtIndex:(int)i;


@end