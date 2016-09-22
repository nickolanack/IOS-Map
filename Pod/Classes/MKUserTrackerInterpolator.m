//
//  MKUserTrackerInterpolator.m
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import "MKUserTrackerInterpolator.h"
#import <MapKit/MapKit.h>

@implementation MKUserTrackerInterpolator



-(MKStyledPolyline *)polylineFromPoints:(NSArray *)points{


    CLLocationCoordinate2D locations[[points count]];
    
    for (int i=0; i<[points count]; i++) {
        CLLocation *l=[points objectAtIndex:i];
        CLLocationCoordinate2D c=l.coordinate;
        locations[i]= c;
    }
    
    return [MKStyledPolyline polylineWithCoordinates:locations count:[points count]];

}




-(double)distanceFromPoints:(NSArray *)points{
    
    double meters=0;

    if(points&&[points count]>1){
        
        
        for (int i=1; i<[points count];i++) {
            meters=meters+[[points objectAtIndex:i-1] distanceFromLocation:[points objectAtIndex:i]];
        }
        
        
    }
    return meters;
    
    
}


-(double)speedFromPoints:(NSArray *)points{
    

    CLLocation *last=[points lastObject];
    return last.speed;

}

@end
