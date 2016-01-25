//
//  MKUserTrackerInterpolator.m
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import "MKUserTrackerInterpolator.h"


@implementation MKUserTrackerInterpolator



-(MKStyledPolyline *)polylineFromPath:(NSArray *)points{


    CLLocationCoordinate2D locations[[points count]];
    
    for (int i=0; i<[points count]; i++) {
        CLLocation *l=[points objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    return [MKStyledPolyline polylineWithCoordinates:locations count:[points count]];

}

@end
