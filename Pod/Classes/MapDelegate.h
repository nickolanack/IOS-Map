//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"



@protocol MapDelegate <NSObject>


@optional

-(bool) mapViewDidLoad:(MapViewController *) view;

-(bool)shouldShowTileGroup:(NSString *)name default:(bool)showTileGroup;
-(bool)shouldShowTileGroup:(NSString *)name item:(int)index default:(bool)showTileGroup;


-(bool)shouldEnableTileGroup:(NSString *)name default:(bool)enableTileGroup;
-(bool)shouldEnableTileGroup:(NSString *)name item:(int)index default:(bool)enableTileItem;

// return false to disable default behavour
-(bool) mapView:(MapViewController *) view userTappedButton:(UIButton *)button InRow:(NSString *)row AtIndex:(int)index;


// return false to disable default behavour
-(bool) mapView:(MapViewController *) view userTappedPrimaryButton:(UIButton *)button;

/**
 Can filter the list of kml files
 */
-(bool) mapView:(MapViewController *) view shouldLoadKmlAtPath:(NSString *)path;

-(int) numberOfExternalKmlDocuments;
-(NSString *) kmlStringForExternalDocumentAtIndex:(int) i;


// return false to disable default behavour
-(bool) mapView:(MapViewController *) view userTappedFeatureDetailView:(NSDictionary*) feature;


-(int) numberOfSideBarCells;
-(bool)cellForSideBarCellAtIndex:(int)index;

@end
