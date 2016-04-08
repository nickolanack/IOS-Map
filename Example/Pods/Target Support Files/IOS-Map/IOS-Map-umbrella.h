#import <UIKit/UIKit.h>

#import "CrossHairs.h"
#import "DismissView.h"
#import "InsetView.h"
#import "MapDelegate.h"
#import "MapOverlayListViewController.h"
#import "MapViewController.h"
#import "MKImageOverlay.h"
#import "MKImageOverlayRenderer.h"
#import "MKOffscreenFeatureRenderer.h"
#import "MKOffscreenFeatureRendererDelegate.h"
#import "MKPhotoAnnotation.h"
#import "MKPlacemarkAnnotation.h"
#import "MKPolylineTapDetector.h"
#import "MKPolylineTapDetectorDelegate.h"
#import "MKStyledPolyline.h"
#import "MKUserTracker.h"
#import "MKUserTrackerDelegate.h"
#import "MKUserTrackerInterpolator.h"
#import "MockPolylineRenderer.h"
#import "OverlayCell.h"
#import "RoundButton.h"
#import "SaxKmlParser.h"
#import "SaxKmlParserDelegate.h"
#import "StyleButton.h"
#import "TileButtonDelegate.h"
#import "TileButtons.h"

FOUNDATION_EXPORT double IOS_MapVersionNumber;
FOUNDATION_EXPORT const unsigned char IOS_MapVersionString[];

