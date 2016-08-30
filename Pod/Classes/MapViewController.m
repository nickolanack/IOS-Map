//
//  ViewController.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-19.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MapViewController.h"
#import "SaxKmlParser.h"
#import "Kml.h"

#import "MKImageOverlay.h"
#import "MKImageOverlayRenderer.h"
#import "MKOffscreenFeatureRenderer.h"
#import "MKUserTracker.h"
#import "MKPhotoAnnotation.h"
#import "MKPlacemarkAnnotation.h"
#import "MKStyledPolyline.h"
#import "MKStyledPolygon.h"
#import "MKPolylineTapDetector.h"

#import "MapOverlayListViewController.h"
#import "OverlayCell.h"
#import "MockPolylineRenderer.h"

#import "TileButtons.h"
#import "MapDelegate.h"

#import "StyleProvider.h"


#import "GridTileOverlay.h"
#import "GridTileOverlayRenderer.h"

#import "ImageTileOverlay.h"
#import "ImageTileOverlayRenderer.h"


@interface MapViewController ()


@property MKUserTracker *tracker;
@property MKOffscreenFeatureRenderer *offscreenRenderer;
@property MKPolylineTapDetector *tapDetector;
@property UITableView *tableView;

@property TileButtons *tileButtons;
@property id<MapDelegate> delegate;

@property id<StyleProvider> styler;

@property UIBarButtonItem *cancelButton;
@property UIBarButtonItem *backButton;

@property bool showOverlaysSideBar;

@property int debugNumPoly;

@property NSMutableDictionary *externalLayers;
@property NSMutableDictionary *localLayers;

@end

@implementation MapViewController


#pragma mark Initialization


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _debugNumPoly=0;
    
    _externalLayers=[[NSMutableDictionary alloc] init];
    _localLayers=[[NSMutableDictionary alloc] init];
    
    
    if([[[UIApplication sharedApplication] delegate] conformsToProtocol:@protocol(MapDelegate)]){
        _delegate=[[UIApplication sharedApplication] delegate];
    }
    
    if([[[UIApplication sharedApplication] delegate] conformsToProtocol:@protocol(StyleProvider)]){
        _styler=[[UIApplication sharedApplication] delegate];
    }
    
    if([_delegate respondsToSelector:@selector(mapViewDidLoad:)]){
        [_delegate mapViewDidLoad:self];
    }
    
    
    [self.mapView setDelegate:self];
    self.tracker=[[MKUserTracker alloc] initWithMap:self.mapView];
    [self.tracker setDelegate:self];
    [self drawGoogleMapTiles];
    [self loadUsersKmlFiles];
    
    
     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         [self loadExternalLayers];
    // });
    
    
    
    //[self drawLabledGrid];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    _tapDetector=[[MKPolylineTapDetector alloc] initWithMap:self.mapView];
    [_tapDetector setDelegate:self];
    
    _showOverlaysSideBar=true; // if false overlays tile will display subtiles instead.
    
    
    
    [self initTileButtons];
    [self hideSideBar];
    
    
    
}

#pragma mark Sidebar

-(void)hideSideBar{

    if(![self sideBarIsOpen]){
        return;
    }
    
    CGRect sb=_sideBar.frame;

  
    
    
    [self.view.superview layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
          self.sideBarLeftConstraint.constant=-sb.size.width;
        [self.view.superview layoutIfNeeded];
    }];
    
 
    
    
    [self.overlaysButton setSelected:false];
    [self.leftDetailButton setSelected:false];

}
-(void)showSideBar{
    
    if([self sideBarIsOpen]){
        return;
    }
    
   CGRect sb=_sideBar.frame;

    
    [self.view.superview layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.sideBarLeftConstraint.constant=0;
        [self.view.superview layoutIfNeeded];
    }];

    
 
    [self.overlaysButton setSelected:true];
    [self.leftDetailButton setSelected:true];
    
}

-(bool)sideBarIsOpen{
    
    int x=_sideBar.frame.origin.x;
    
    if(x>=0){
        return true;
    }
    return false;
}

-(void)toggleSideBar{

    if([self sideBarIsOpen]){
        [self hideSideBar];
    }else{
        [self showSideBar];
    }

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if([_delegate respondsToSelector:@selector(mapViewNumberOfSideBarCells:)]){
        return [_delegate mapViewNumberOfSideBarCells:self];
    }
    
    return 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if([_delegate respondsToSelector:@selector(mapView:userTappedSidebarCell:atIndex:)]){
        [_delegate mapView:self userTappedSidebarCell:[collectionView cellForItemAtIndexPath:indexPath] atIndex:[indexPath item]];
    }
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
        UICollectionView *cell=[self.sideBarCollectionView dequeueReusableCellWithReuseIdentifier:@"testSidebarCell" forIndexPath:indexPath];
    
        if([_delegate respondsToSelector:@selector(mapView:onDequeueReusableCell:ForSidebarAtIndex:)]){
            [_delegate mapView:self onDequeueReusableCell:cell ForSidebarAtIndex:[indexPath item]];
        }
    
        return cell;
}


-(void)onPolylineTap:(MKPolyline *)polyline atCoordinate:(CLLocationCoordinate2D)coord andTouch:(CGPoint)touchPt{
    //    NSLog(@"PolyTap: %f, %f", coord.latitude, coord.longitude);
    //
    //    MKPlacemarkAnnotation *p=[[MKPlacemarkAnnotation alloc] init];
    //    [p setCoordinate:coord];
    //    NSString *icon=[[NSBundle mainBundle] pathForResource:@"waypoint-offscreen-15.png" ofType:nil];
    //    [p setIconUrl:icon];
    //
    //    [self.mapView addAnnotation:p];
}

-(void)updateTimer{
    
    NSString *timeStr=@"";
    int seconds=[_tracker getTimeInterval];
    if(seconds>60){
        int minutes=seconds/60;
        if(minutes>60){
            int hours=minutes/60;
            timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:@"%i:", hours]];
        }
        timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:(minutes<10?@"%i:":@"%02i:"), minutes%60]];
    }
    timeStr=[timeStr stringByAppendingString:[NSString stringWithFormat:(seconds<10?@"%i":@"%02i"), seconds%60]];
    
    self.trackTime.text=timeStr;
    
}

#pragma mark Load Content

-(bool)shouldLoadUsersKmlAtPath:(NSString *) path{
    
    if([_delegate respondsToSelector:@selector(mapView:shouldLoadKmlAtPath:)]){
        return [_delegate mapView:self shouldLoadKmlAtPath:path];
    }
    return true;

}


-(void)loadUsersKmlFiles{
    
    NSString *folder=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fm =[NSFileManager defaultManager];
    NSError *err;
    NSArray *paths=[fm contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:&err];
    for (NSString *path in paths) {
        NSLog(@"%@", path);
        
        NSString *ext=[path substringFromIndex:path.length-4];
        
        if([ext isEqualToString:@".kml"]&&(![[NSCharacterSet characterSetWithCharactersInString:@"._"] characterIsMember:[path characterAtIndex:0]])){
            
            NSError *err;
            NSString *absolutePath=[folder stringByAppendingPathComponent:path];
            NSString *kml=[NSString stringWithContentsOfFile:absolutePath encoding:NSUTF8StringEncoding error:&err];
            
            if([self shouldLoadUsersKmlAtPath:absolutePath]){
                //[[[SaxKmlParser alloc] initWithDelegate:self] parseString:kml];
                
                /**
                 * TODO provide delegate notifications for users local kml with some sort of id
                 * and add items to layer a layer object.
                 */
                
                Kml *parser=[[Kml alloc]initWithKmlString:kml];
                
                [parser onPlacemark:^(NSDictionary *dictionary) {
                    [self onKmlPlacemark:dictionary];
                }];
                
                [parser onPolygon:^(NSDictionary *dictionary) {
                    [self onKmlPolygon:dictionary];
                }];
                
                [parser onPolyline:^(NSDictionary *dictionary) {
                    [self onKmlPolyline:dictionary];
                }];
                
                [parser onGroundOverlay:^(NSDictionary *dictionary) {
                    [self onKmlGroundOverlay:dictionary];
                }];
                
                [parser parse];
            }
        }
    }
}

-(void)drawLabledGrid{
  
    GridTileOverlay *gridOverlay = [[GridTileOverlay alloc] init];
    gridOverlay.canReplaceMapContent=NO;
    [self.mapView addOverlay:gridOverlay level:MKOverlayLevelAboveLabels];
    


}


-(void)drawGoogleMapTiles{
    
    ImageTileOverlay *tileOverlay = [[ImageTileOverlay alloc] initWithURLTemplate:@"http://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}"];
    tileOverlay.canReplaceMapContent=YES;
    
    if([_delegate respondsToSelector:@selector(mapView:willAddBaseMapTileOverlay:)]){
        [_delegate mapView:self willAddBaseMapTileOverlay:tileOverlay];
    }
    
    [self.mapView addOverlay:tileOverlay];
    
    if([_delegate respondsToSelector:@selector(mapView:didAddBaseMapTileOverlay:)]){
        [_delegate mapView:self didAddBaseMapTileOverlay:tileOverlay];
    }
    
}

-(void)loadExternalLayers{

    if([_delegate respondsToSelector:@selector(numberOfLayers)]){
        
       
            
            int c=[_delegate numberOfLayers];
            for(int i=0;i<c;i++){
         
                
                NSString *type=@"kml";
                
                if([_delegate respondsToSelector:@selector(layerTypeForLayerAtIndex:)]){
                    type = [_delegate layerTypeForLayerAtIndex:i];
                }
                
                if([type isEqualToString:@"kml"]){
                
                    /**
                     * TODO provide delegate notifications for external kml with some sort of id
                     * and add items to layer a layer object.
                     */
                    
                    if(![_delegate respondsToSelector:@selector(kmlStringForLayerAtIndex:)]){
                        @throw [[NSException alloc] initWithName:@"Unimplemented kmlStringForLayerAtIndex" reason:@"Delegate must respode to selector kmlStringForLayerAtIndex: if it responds to selector layerTypeForLayerAtIndex with kml" userInfo:nil];
                    }
                    
                    
                    Kml *parser=[[Kml alloc]initWithKmlString:[_delegate kmlStringForLayerAtIndex:i]];
                                 
                    [parser onPlacemark:^(NSDictionary *dictionary) {
                        [self onKmlPlacemark:dictionary];
                    }];
                    
                    [parser onPolygon:^(NSDictionary *dictionary) {
                        [self onKmlPolygon:dictionary];
                    }];
                    
                    [parser onPolyline:^(NSDictionary *dictionary) {
                        [self onKmlPolyline:dictionary];
                    }];
                    
                    [parser onGroundOverlay:^(NSDictionary *dictionary) {
                        [self onKmlGroundOverlay:dictionary];
                    }];
                    
                                    
                    [parser parse];
                    continue;
                }
                    
                
                if([type isEqualToString:@"tile"]){
                    
                    
                    if(![_delegate respondsToSelector:@selector(tileUrlTemplateForLayerAtIndex:)]){
                        @throw [[NSException alloc] initWithName:@"Unimplemented tileUrlTemplateForLayerAtIndex" reason:@"Delegate must respode to selector tileUrlTemplateForLayerAtIndex: if it responds to selector layerTypeForLayerAtIndex with kml" userInfo:nil];
                    }
                    
                    ImageTileOverlay *tileOverlay = [[ImageTileOverlay alloc] initWithURLTemplate:[_delegate tileUrlTemplateForLayerAtIndex:i]];
                    tileOverlay.canReplaceMapContent=NO;
                    
                    
                    
                    if(self.mapView&&tileOverlay){
                        
                        [self addExternalOverlay:tileOverlay atIndex:i];
                        
                        if([self shouldShowExternalOverlay:tileOverlay atIndex:i]){
                        
                            [self showExternalOverlay:tileOverlay atIndex:i];
                        
                        }
  
                    }
                    
                    continue;
                    
                }
                
              
                    
                 @throw [[NSException alloc] initWithName:@"Unknown type for layer" reason:[NSString stringWithFormat:@"Unknown type %@, at %i",type, i] userInfo:nil];
                
  
                
            }
   
        
    }
    

}


-(void)addExternalOverlay:(ImageTileOverlay *)overlay atIndex:(int)index{

    if(!_externalLayers){
        _externalLayers=[[NSMutableDictionary alloc] init];
    }
  
   [_externalLayers setObject:overlay forKey:[NSString stringWithFormat:@"%i", index]];

}

-(bool)toggleExternalLayerAtIndex:(int) index{
    
    
    
    ImageTileOverlay *overlay= [_externalLayers objectForKey:[NSString stringWithFormat:@"%i", index]];
    if([self.mapView.overlays indexOfObject:overlay]==NSNotFound){
        [self showExternalOverlay:overlay atIndex:index];
        return true;
    }
    
    [self hideExternalOverlay:overlay atIndex:index];
    return false;
}





-(bool)shouldShowExternalOverlay:(ImageTileOverlay *)overlay atIndex:(int)index{
    
    if([_delegate respondsToSelector:@selector(mapView:shouldShowTileOverlay:atIndex:)]){
        return [_delegate mapView:self shouldShowTileOverlay:overlay atIndex:index];
    }
    
    return true;
}
-(void)showExternalOverlay:(ImageTileOverlay *)overlay atIndex:(int)index{
    
    if([_delegate respondsToSelector:@selector(mapView:willAddTileOverlay:forLayerId:)]){
        [_delegate mapView:self willAddTileOverlay:overlay forLayerId:index];
    }
    
    [self.mapView addOverlay:overlay];
    
    if([_delegate respondsToSelector:@selector(mapView:didAddTileOverlay:forLayerId:)]){
        [_delegate mapView:self didAddTileOverlay:overlay forLayerId:index];
    }
    
    
}

-(void)hideExternalOverlay:(ImageTileOverlay *)overlay atIndex:(int)index{
    
    if([_delegate respondsToSelector:@selector(mapView:willRemoveTileOverlay:forLayerId:)]){
        [_delegate mapView:self willRemoveTileOverlay:overlay forLayerId:index];
    }
    
    [self.mapView removeOverlay:overlay];
    
    if([_delegate respondsToSelector:@selector(mapView:didRemoveTileOverlay:forLayerId:)]){
        [_delegate mapView:self didRemoveTileOverlay:overlay forLayerId:index];
    }
    
    
}


#pragma mark Map View

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    if([overlay isKindOfClass:[MKImageOverlay class] ]){
        // this is my custom image overlay class
        MKImageOverlayRenderer *p=[[MKImageOverlayRenderer alloc] initWithOverlay:overlay];

        
        if([self.usersOverlaysButton isSelected]){
            [p setAlpha:0.5];
        }else{
            [p setAlpha:0.1];
        }
        
        return p;
    }
    
    if([overlay isKindOfClass:[GridTileOverlay class] ]){
        GridTileOverlayRenderer *p=[[GridTileOverlayRenderer alloc] initWithOverlay:overlay];
        return p;
    
    }
    
    
    if([overlay isKindOfClass:[MKTileOverlay class]]||[overlay isKindOfClass:[ImageTileOverlay class]]){
        MKTileOverlayRenderer *p=[[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
        return p;
        
    }
    
    if([overlay isKindOfClass:[MKStyledPolygon class] ]){
        MKPolygonRenderer *p=[[MKPolygonRenderer alloc] initWithOverlay:overlay];
        [p setLineWidth:1.0];
        [p setFillColor:[UIColor colorWithRed:1.0 green:0.2 blue:0.3 alpha:0.5]];
        [p setStrokeColor:[UIColor blackColor]];
        
    
        
        
        return p;
        
    }else{
        MockPolylineRenderer *p= [[MockPolylineRenderer alloc]initWithOverlay:overlay];
        if([overlay isKindOfClass:[MKStyledPolyline class]]){
            [p setStrokeColor:((MKStyledPolyline *) overlay).color];
            [p setLineWidth:((MKStyledPolyline *) overlay).width];
        }else{
            
            [p setStrokeColor:[UIColor blueColor]];
            [p setLineWidth:2.0f];
            
        }
        return p;
    }
    
    return nil;
    
    
}




-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    MKAnnotationView *p=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    if([annotation isKindOfClass:[MKPhotoAnnotation class]]){
        [p setImage:[((MKPhotoAnnotation *) annotation) getIcon]];
    }else if([annotation isKindOfClass:[MKPlacemarkAnnotation class]]){
        
        [p setImage:[((MKPlacemarkAnnotation *) annotation) getIcon]];
        [p setCanShowCallout:true];
        [p setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        
    }else{
        
        [p setImage:[UIImage imageNamed:@"waypoint-default-25x28.png"]];
        [p setCanShowCallout:true];
        [p setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        
    }
    [p setDraggable:true];
    
    return p;
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        
        [view setDragState:MKAnnotationViewDragStateNone];
    }
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    
  
    id<MKAnnotation> annotation=view.annotation;
    NSDictionary *data=@{};
    if([annotation isKindOfClass:[MKPlacemarkAnnotation class]]){
        data=((MKPlacemarkAnnotation *)annotation).data;
    }
    
    if([_delegate respondsToSelector:@selector(mapView:userTappedFeatureDetailView:)]){
        
        if(![_delegate mapView:self userTappedFeatureDetailView:data]){
            return;
        }
    
    }
    
    //TODO: default detail view behavior
    
    NSLog(@"Callout Tapped");
    
}

-(bool)shouldRenderViewForOffscreenPointFeature:(MKPointAnnotation *)point {
    return true;
}
-(UIView *)viewForOffscreenPointFeature:(MKPointAnnotation *)point{
    
    if([point isKindOfClass:[MKUserLocation class]]){
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userlocation-offscreen-15.png"]];
    }else{
        return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waypoint-offscreen-15.png"]];
    }
    return nil;
    
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    
    if(!_offscreenRenderer){
        _offscreenRenderer=[[MKOffscreenFeatureRenderer alloc] initWithMap:self.mapView];
        [_offscreenRenderer setDelegate:self];
    }
    
    [_offscreenRenderer startUpdating];
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [_offscreenRenderer stopUpdating];
    
}

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    
    if(mode==MKUserTrackingModeFollowWithHeading){
        [self.lockLocationButton setSelected:true];
    }else{
        [self.lockLocationButton setSelected:false];
    }
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    NSLog(@"Annotation Selected");
    
}

#pragma mark Tile Button Configuration and Delegates

-(bool)shouldShowTileGroup:(NSString *)name {
    
    bool defaultValue=true;
    
    if(_delegate&&[_delegate respondsToSelector:@selector(shouldShowTileGroup:default:)]){
        return [_delegate shouldShowTileGroup:name default:defaultValue];
    }
    return defaultValue;
}

-(bool)shouldEnableTileGroup:(NSString *)name {
    
    bool defaultValue=true;
    
    if(_delegate&&[_delegate respondsToSelector:@selector(shouldEnableTileGroup:default:)]){
        return [_delegate shouldEnableTileGroup:name default:defaultValue];
    }
    return defaultValue;
}

-(bool)shouldShowTileGroup:(NSString *)name item:(int)index default:(bool)showTileGroup{
    
    bool defaultValue=true;
    
    if(_delegate&&[_delegate respondsToSelector:@selector(shouldShowTileGroup:item:default:)]){
        return [_delegate shouldShowTileGroup:name item:index default:defaultValue];
    }
    return defaultValue;
}

-(void)initTileButtons{
    _tileButtons=[[TileButtons alloc] initWithStyler:_styler];
    [_tileButtons setAutoSpaceTiles:true];
    
    
    NSArray *paths=@[self.trackUserButton];
   // for (UIButton *b in paths) {
 
   // }
    [_tileButtons addButtons:paths ToRow:@"paths"];
    
    
    
    NSArray *placemarks=@[self.markerDropButton, self.takePhotoButton];
    for (UIButton *b in placemarks) {
        [b setHidden:true];
    }
    [_tileButtons addButtons:placemarks ToRow:@"placemarks" Toggler:self.waypointButton];
    
    
    
    NSArray *overlays=@[self.usersOverlaysButton, self.overlaysListButton];
    
    for (UIButton *b in overlays) {
        [b setHidden:true];
    }
    if(!_showOverlaysSideBar){
         [_tileButtons addButtons:overlays ToRow:@"overlays" Toggler:self.overlaysButton];
        
    }else{
        overlays=@[self.overlaysButton];
        [_tileButtons addButtons:overlays ToRow:@"overlays"];
        
       
     }
    
    
    NSArray *location=@[self.lockLocationButton, self.addUserLocationButton];
    for (UIButton *b in location) {
        [b setHidden:true];
    }
    [_tileButtons addButtons:@[self.lockLocationButton, self.addUserLocationButton] ToRow:@"location" Toggler:self.locatonButton];
    
    
    if(![self shouldEnableTileGroup:@"paths"]){
        [_tileButtons disableRow:@"paths"];
           }
    if(![self shouldEnableTileGroup:@"placemarks"]){
        [_tileButtons  disableRow:@"placemarks"];
    }
    if(![self shouldEnableTileGroup:@"overlays"]){
        [_tileButtons  disableRow:@"overlays"];
    }
    if(![self shouldEnableTileGroup:@"location"]){
        [_tileButtons  disableRow:@"location"];
    }
    
    
    if(![self shouldShowTileGroup:@"paths"]){
        [_tileButtons hideRow:@"paths"];
    }
    if(![self shouldShowTileGroup:@"placemarks"]){
        [_tileButtons  hideRow:@"placemarks"];
    }
    if(![self shouldShowTileGroup:@"overlays"]){
        [_tileButtons  hideRow:@"overlays"];
    }
    if(![self shouldShowTileGroup:@"location"]){
        [_tileButtons  hideRow:@"location"];
    }
    
    
    [_tileButtons setDelegate:self];
}

#pragma mark Tile Button Clicks

-(void)userTappedButton:(StyleButton *)button InRow:(NSString *)row AtIndex:(int)index{
    
    
    if(_delegate&&[_delegate respondsToSelector:@selector(mapView:userTappedButton:InRow:AtIndex:)]){
    
        if(![_delegate mapView:self userTappedButton: button InRow: row AtIndex:index]){
            return;
        }
        
    }
    
    NSLog(@"%@, %d", row, index);
    
    if([row isEqualToString:@"paths"]&&index==0){
    
        if(!self.trackUserButton.isSelected){
            [self.trackUserButton setSelected:true];
            [self.tracker startTrackingLocation];
            
        }else{
            
            [self.trackUserButton setSelected:false];
            [self.tracker stopTrackingLocation];
        }
    }
    
    if([row isEqualToString:@"placemarks"]){
        
        if(index==1){
            //marker drop
            MKPointAnnotation *point=[[MKPointAnnotation alloc] init];
            [point setCoordinate:self.mapView.centerCoordinate];
            
            
            //[self.points addObject:point];
            [self.mapView addAnnotation:point];
            [_tileButtons hide:@"placemarks"];
        
        }
        
        if(index==2){
            //photo drop
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            
            //picker.wantsFullScreenLayout = YES;
            picker.navigationBarHidden = YES;
            picker.toolbarHidden = YES;
            
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //picker.showsCameraControls=YES;
            
            picker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            [picker setDelegate:self];
            
            [self presentViewController:picker animated:false completion:^{
                NSLog(@"Dismissed");
            }];
        }

    }
    
    if([row isEqualToString:@"overlays"]){
        
        //if(index==0){
        if(_showOverlaysSideBar){
        
            if([self sideBarIsOpen]){
                [self hideSideBar];
            }else{
                [self showSideBar];
            }
        
        }
        
        
        if(index==1){
            
            int c=[self.mapView.overlays count];
            if(c==0){
        
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                  message:@"You don't have any layers, but can add your own spatial features through itunes"
                                                 delegate:nil
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            //toggle users overlays
            [self.usersOverlaysButton setSelected:!self.usersOverlaysButton.selected];
            for(id o in self.mapView.overlays) {
                
                //this is basically redraw overlays. it depends on the selected state of usersOverlaysButton
                
                [self.mapView removeOverlay:o];
                [self.mapView addOverlay:o];
                
                //[o setNeedsDisplay];
            }
            
        }
        
        if(index==2){
            //show overlys list
            
        }
        
    }
    
    
    if([row isEqualToString:@"location"]){
        
        if(index==0){
            if(self.locatonButton.selected){
                
                MKMapRect mr=self.mapView.visibleMapRect;
                
                MKMapPoint p=MKMapPointForCoordinate(_tracker.currentLocation.coordinate);
                if(!MKMapRectContainsPoint(mr, p)){
                    [self.mapView setCenterCoordinate:_tracker.currentLocation.coordinate animated:true];
                }
            }
        }
        
        if(index==1){
            //toggle lock to users location
            
            [self.lockLocationButton setSelected:!self.lockLocationButton.selected];
            if(self.lockLocationButton.selected){
                
                [_tracker startMovingWithLocation];
                [_tracker startRotatingWithHeading];
                
            }else{
                
                [_tracker stopMovingWithLocation];
                [_tracker stopRotatingWithHeading];
  
            }
            
        }
        
        if(index==2){
            //add partners location
        }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info{
    
    NSLog(@"%@", info);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSString *type=[info objectForKey:UIImagePickerControllerMediaType];
    if([type isEqualToString:@"public.image"]){
        
        MKPhotoAnnotation  *point=[[MKPhotoAnnotation alloc] initWithUIImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [point setCoordinate:[_tracker.currentLocation coordinate]];
        [self.mapView addAnnotation:point];
        
    }else{
        NSLog(@"Unknown Media Type: %@",type);
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"Cancelled");
    
}





#pragma mark Kml Parser

-(void) onKmlPlacemark:(NSDictionary *)dictionary{
    
    
    MKPlacemarkAnnotation *point=[[MKPlacemarkAnnotation alloc] init];
    [point setCoordinate:[SaxKmlParser ParseCoordinateString:[dictionary valueForKey:@"coordinates"]]];
    [point setTitle:[dictionary valueForKey:@"name"]];
    
    [point setData:dictionary];
    
    NSString *iconUrl=[dictionary valueForKey:@"href"];
    if(!iconUrl){
        [[NSException alloc] initWithName:@"Empty placmark icon" reason:@"Expected placemark dictionary value: href" userInfo:nil];
    }
    
    [point setIconUrl:[dictionary valueForKey:@"href"]];
    
    [self.mapView addAnnotation:point];
    
    
    
}

-(void) onKmlGroundOverlay:(NSDictionary *)dictionary{
    
    NSLog(@"Ground Overlay: %@", dictionary);
    
    MKImageOverlay *o=[[MKImageOverlay alloc] init];
    
    NSString *folder=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *image=[[dictionary valueForKey:@"href"] stringByReplacingOccurrencesOfString:@"files/" withString:@""];
    
    [o setImage:[folder stringByAppendingPathComponent:image]];
    [o setRotation:[[dictionary valueForKey:@"rotation"] floatValue]];
    [o setScale:[[dictionary valueForKey:@"viewboundscale"] floatValue]];
    [o setNorth:[[dictionary valueForKey:@"north"] floatValue] South:[[dictionary valueForKey:@"south"] floatValue] East:[[dictionary valueForKey:@"east"] floatValue] West:[[dictionary valueForKey:@"west"] floatValue]];
    
    [self.mapView addOverlay:o];
    
}
-(void)onKmlPolyline:(NSDictionary *)dictionary{
    
    
    
    NSArray *coordinateStrings=[SaxKmlParser ParseCoordinateArrayString:[dictionary objectForKey:@"coordinates"]];
    CLLocationCoordinate2D locations[[coordinateStrings count]];
    
    for (int i=0; i<[coordinateStrings count]; i++) {
        locations[i]= [SaxKmlParser ParseCoordinateString:[coordinateStrings objectAtIndex:i]];
    }
    
    
    MKStyledPolyline * p= [MKStyledPolyline polylineWithCoordinates:locations count:[coordinateStrings count]];
    [p setColor:[SaxKmlParser ParseColorString:[dictionary objectForKey:@"color"]]];
    [p setWidth:[[dictionary objectForKey:@"width"] floatValue]];
    [self.mapView addOverlay:p];
    
}
-(void)onKmlPolygon:(NSDictionary *)dictionary{
    
    _debugNumPoly++;
    if(_debugNumPoly>20){
        return;
    }
    
    NSArray *coordinateStrings=[SaxKmlParser ParseCoordinateArrayString:[dictionary objectForKey:@"coordinates"]];
    CLLocationCoordinate2D locations[[coordinateStrings count]];
    
    for (int i=0; i<[coordinateStrings count]; i++) {
        locations[i]= [SaxKmlParser ParseCoordinateString:[coordinateStrings objectAtIndex:i]];
    }
    
    
    MKStyledPolygon * p= [MKStyledPolygon polygonWithCoordinates:locations count:[coordinateStrings count]];
    [p setColor:[SaxKmlParser ParseColorString:[dictionary objectForKey:@"color"]]];
    [p setWidth:[[dictionary objectForKey:@"width"] floatValue]];
    [self.mapView addOverlay:p];


}

#pragma mark Tracking


-(void)userTrackerDistanceDidChange:(float) distance From:(float) previousDistance{
    [self.trackDistance setText:[NSString stringWithFormat:@"%im", (int)(distance)]];
}
-(void)userTrackerPathDidChange:(MKStyledPolyline *)path From:(MKStyledPolyline *)previousPath{
    
    if(previousPath&&self.mapView){
        [self.mapView removeOverlay:previousPath];
    }
    
    if(self.mapView){
        [self.mapView addOverlay:path];
    }
    
}

#pragma mark Device

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            
            [self.topBar setHidden:true];
            break;
            
        default:
            [self.topBar setHidden:false];
            break;
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc=[segue destinationViewController];
    if([vc isKindOfClass:[MapOverlayListViewController class]]){
        
        MapOverlayListViewController *mOverlayvc=(MapOverlayListViewController *)vc;
        [mOverlayvc setDelegate:self];
        [mOverlayvc setDataSource:self];
        
    }
    
}

#pragma mark OverlayTable Cells

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(_tableView==nil){
        _tableView=tableView;
    }
    
    if(section==0){
        return _mapView.overlays.count;
    }else{
        return _mapView.annotations.count;
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    int section=indexPath.section;
    int row=indexPath.row;
    
    OverlayCell *cell;
    
    NSString *textLabel=@"Feature";
    NSString *detailTextLabel=@"";
    UIImage *image;
    
    
    
    
    if(section==0){
        
        
        NSObject<MKOverlay> *o=[_mapView.overlays objectAtIndex:row];
        textLabel= @"Overlay";
        //cell.detailTextLabel.text= o.title;
        
        if([o isKindOfClass:[MKImageOverlay class]]){
            MKImageOverlay *iO=(MKImageOverlay *)o;
            image=[iO getUIImage];
        }
        
        if([o isKindOfClass:[MKStyledPolyline class]]){
            
            MKStyledPolyline *sPO=(MKStyledPolyline *)o;
            
            
            MockPolylineRenderer *pl=[[MockPolylineRenderer alloc] initWithPolyline:sPO];
            [pl setStrokeColor:sPO.color];
            [pl setLineWidth:sPO.width];
            
            
            MKMapRect pr=sPO.boundingMapRect;
            
            float max=MAX(pr.size.height, pr.size.width);
            float size =64;
            CGSize imageSize=CGSizeMake(size*(pr.size.width/max),size*(pr.size.height/max));
            
            MKZoomScale scale= size / max;
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0);
            
            CGContextRef context=UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, scale, scale);
            [pl drawMapRect:pr zoomScale:scale inContext:context];
            image = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned.
            UIGraphicsEndImageContext();
            
            
        }
        
    }else if(section==1){
        MKPointAnnotation *a=[_mapView.annotations objectAtIndex:row];
        
        textLabel= @"Point";
        //cell.detailTextLabel.text= a.title;
        
        if([a isKindOfClass:[MKPhotoAnnotation class]]){
            MKPhotoAnnotation *phA=(MKPhotoAnnotation *)a;
            image=[phA getIcon];
        }
        
        if([a isKindOfClass:[MKPlacemarkAnnotation class]]){
            MKPlacemarkAnnotation *plA=(MKPlacemarkAnnotation *)a;
            image=[plA getIcon];
        }
        
        if([a isKindOfClass:[MKUserLocation class]]){
            image=[UIImage imageNamed:@"userlocation-offscreen-15.png"];
        }
        
        if([a isKindOfClass:[MKPointAnnotation class]]){
            image=[UIImage imageNamed:@"waypoint-offscreen-15.png"];
        }
        
        
        detailTextLabel=a.title;
        
    }
    
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MapOverlayCell"];
    
    if (cell == nil){
        cell = [[OverlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MapOverlayCell"];
        
        
    }
    
    
    
    cell.featureText.text=textLabel;
    cell.detailFeatureText.text=detailTextLabel;
    
    if(image != nil){
        [cell.featureImage setImage:image];
    }
    cell.featureSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    return cell;
    
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    if(_tableView){
        [_tableView reloadData];
    }
}
-(void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers{
    if(_tableView){
        [_tableView reloadData];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //add code here for when you hit delete
    }
}

-(void)cancelBigButtonClick{
    self.navigationItem.leftBarButtonItem =_backButton;
    [self.crossHairs setHidden:true];
    [self.bigButton setTintColor:self.bigButton.backgroundColor];
    [self.bigButton setBackgroundColor:[UIColor whiteColor]];

}
- (IBAction)onBigButtonClick:(id)sender {
    
    if(!_backButton){
       _backButton=self.navigationItem.backBarButtonItem;
       _cancelButton=[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBigButtonClick)];

    }

    if(self.crossHairs.isHidden){
        
        self.navigationItem.leftBarButtonItem =_cancelButton;
        [self.crossHairs setHidden:false];
        
        [self.bigButton setBackgroundColor:self.bigButton.tintColor];
        [self.bigButton setTintColor:[UIColor whiteColor]];
        [self.bigButton setBackgroundImage:nil forState:UIControlStateNormal];
        
    }else{
        [self cancelBigButtonClick];
        
        if(![_delegate mapView:self userTappedPrimaryButton:self.bigButton]){
            return;
        }
                                                                            
        //TODO: default behavior
        
    }
    
}
- (IBAction)onRightButtonTap:(id)sender {
    
    [self.rightDetailButton setSelected:!self.rightDetailButton.selected];
    
    
        
        if(self.rightDetailButton.selected){
            
            MKMapRect mr=self.mapView.visibleMapRect;
            
            MKMapPoint p=MKMapPointForCoordinate(_tracker.currentLocation.coordinate);
            if(!MKMapRectContainsPoint(mr, p)){
                [self.mapView setCenterCoordinate:_tracker.currentLocation.coordinate animated:false];
                
            }
        }
    
    
   
        //toggle lock to users location
        
        
        
        if(self.rightDetailButton.selected){
            
            [_tracker startMovingWithLocation];
            [_tracker startRotatingWithHeading];
            
        }else{
            
            [_tracker stopMovingWithLocation];
            [_tracker stopRotatingWithHeading];
            
        }
        
    
    
    
}

- (IBAction)onLeftButtonTap:(id)sender {
    
    
    
    [self toggleSideBar];
    
}
@end
