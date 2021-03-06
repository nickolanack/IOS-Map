//
//  MKUserTrackerInterpolator.h
//  Pods
//
//  Created by Nick Blackwell on 2016-01-25.
//
//

#import <Foundation/Foundation.h>
#import "MKStyledPolyline.h"

@interface MKUserTrackerInterpolator : NSObject


-(MKStyledPolyline *)polylineFromPoints:(NSArray *)points;
-(double)distanceFromPoints:(NSArray *)points;
-(double)speedFromPoints:(NSArray *)points;

@end
