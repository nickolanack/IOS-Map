//  Created by Nick Blackwell on 2012-11-06.
//  Copyright (c) 2012 Nicholas Blackwell. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "ImageTileOverlay.h"



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

-(int) numberOfLayers;


-(NSString *) layerTypeForLayerAtIndex:(int) i;
-(NSString *) kmlStringForLayerAtIndex:(int) i;
-(NSString *) tileUrlTemplateForLayerAtIndex:(int) i;

// return false to disable default behavour
-(bool) mapView:(MapViewController *) view userTappedFeatureDetailView:(NSDictionary*) feature;


-(int) mapViewNumberOfSideBarCells:(MapViewController *) view;
-(void) mapView:(MapViewController *) view userTappedSidebarCell:(UICollectionViewCell *)cell atIndex:(int)index;
-(UICollectionViewCell *) mapView:(MapViewController *) view cellForSideBarAtIndex:(int)index;
-(void) mapView:(MapViewController *) view onDequeueReusableCell:(UICollectionViewCell *) cell ForSidebarAtIndex:(int)index;

-(bool)mapView:(MapViewController *) view shouldShowTileOverlay:(ImageTileOverlay *) overlay atIndex:(int)index;

-(bool)mapView:(MapViewController *) view shouldAllowDragging:(MKAnnotationView *)annotation;

-(void)mapView:(MapViewController *) view willAddBaseMapTileOverlay:(ImageTileOverlay *) overlay;
-(void)mapView:(MapViewController *) view didAddBaseMapTileOverlay:(ImageTileOverlay *) overlay;


//TODO rename forLayerId to forLayerIndex (becuase id is different.)
-(void)mapView:(MapViewController *) view willAddTileOverlay:(ImageTileOverlay *) overlay forLayerId:(int) index;
-(void)mapView:(MapViewController *) view didAddTileOverlay:(ImageTileOverlay *) overlay forLayerId:(int) index;

-(void)mapView:(MapViewController *) view willRemoveTileOverlay:(ImageTileOverlay *) overlay forLayerId:(int) index;
-(void)mapView:(MapViewController *) view didRemoveTileOverlay:(ImageTileOverlay *) overlay forLayerId:(int) index;

@end
