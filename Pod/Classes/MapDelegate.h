//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@protocol MapDelegate <NSObject>


@optional

-(bool)shouldShowTileGroup:(NSString *)name default:(bool)showTileGroup;
-(bool)shouldShowTileGroup:(NSString *)name item:(int)index default:(bool)showTileGroup;



@end
