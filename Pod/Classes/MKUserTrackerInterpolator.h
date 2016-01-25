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


-(MKStyledPolyline *)polylineFromPath:(NSArray *)points;

@end
