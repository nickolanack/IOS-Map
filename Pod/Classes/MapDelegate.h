//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "StyleButton.h"


@protocol MapDelegate <NSObject>


@optional

-(bool)shouldShowTileGroup:(NSString *)name default:(bool)showTileGroup;
-(bool)shouldShowTileGroup:(NSString *)name item:(int)index default:(bool)showTileGroup;


-(bool)shouldEnableTileGroup:(NSString *)name default:(bool)enableTileGroup;
-(bool)shouldEnableTileGroup:(NSString *)name item:(int)index default:(bool)enableTileItem;

// return false to disable default behavour
-(bool) mapView:(MapViewController *) view userTappedButton:(StyleButton *)button InRow:(NSString *)row AtIndex:(int)index;


@end
