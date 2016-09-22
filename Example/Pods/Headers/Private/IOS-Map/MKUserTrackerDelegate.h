//
//  MKUserTrackerDelegate.h
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-27.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MKStyledPolyline.h"



@protocol MKUserTrackerDelegate <NSObject>

@optional

-(void)userTrackerSpeedDidChangeTo:(float) speed From:(float) previousSpeed;
-(void)userTrackerDistanceDidChange:(float) distance From:(float) previousDistance;
-(void)userTrackerPathDidChange:(MKStyledPolyline *) path From:(MKStyledPolyline *) previousPath;

@end
