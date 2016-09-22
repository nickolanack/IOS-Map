//
//  MKStyledPolygon.h
//  Pods
//
//  Created by Nick on 2016-06-09.
//
//

#import <MapKit/MapKit.h>

@interface MKStyledPolygon : MKPolygon
    @property UIColor *color;
    @property float width;

    @property UIColor *fillColor;
    @property float fillOpacity;

@end
