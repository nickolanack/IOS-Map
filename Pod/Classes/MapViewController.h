//
//  ViewController.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SaxKmlParserDelegate.h"
#import "MKOffscreenFeatureRendererDelegate.h"
#import "MKUserTrackerDelegate.h"
#import "MKPolylineTapDetectorDelegate.h"
#import "TileButtonDelegate.h"


@interface MapViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate, SaxKmlParserDelegate, MKOffscreenFeatureRendererDelegate, UIImagePickerControllerDelegate, MKUserTrackerDelegate, UINavigationControllerDelegate, MKPolylineTapDetectorDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, TileButtonDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;



@property (unsafe_unretained, nonatomic) IBOutlet UIButton *bigButton;


@property (weak, nonatomic) IBOutlet StyleButton *overlaysButton;
@property (weak, nonatomic) IBOutlet StyleButton *addUserLocationButton;
@property (weak, nonatomic) IBOutlet StyleButton *locatonButton;
@property (weak, nonatomic) IBOutlet StyleButton *waypointButton;
@property (weak, nonatomic) IBOutlet StyleButton *markerDropButton;
@property (weak, nonatomic) IBOutlet StyleButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet StyleButton *lockLocationButton;
@property (weak, nonatomic) IBOutlet StyleButton *usersOverlaysButton;
@property (weak, nonatomic) IBOutlet StyleButton *overlaysListButton;
@property (weak, nonatomic) IBOutlet StyleButton *trackUserButton;


- (IBAction)onBigButtonClick:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *crossHairs;

@property (weak, nonatomic) IBOutlet UIView *trackInfoBar;
@property (weak, nonatomic) IBOutlet UILabel *trackLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackTime;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UILabel *trackDistance;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *sideBar;


@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *sideBarLeftConstraint;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *sideBarWidthConstraint;



@property (unsafe_unretained, nonatomic) IBOutlet UIButton *rightDetailButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *leftDetailButton;
- (IBAction)onRightButtonTap:(id)sender;
- (IBAction)onLeftButtonTap:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *sideBarCollectionView;

-(bool)toggleExternalLayerAtIndex:(int) i;
-(bool)isExternalLayerVisibleAtIndex:(int) i;

-(void)hideSideBar;
-(void)showSideBar;


@end
