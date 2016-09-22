//
//  MockCLLocationManager.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-10-29.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import "MockCLLocationManager.h"

@implementation MockCLLocationManager


// this class will be used to test MKUserTracker once enough location sample files
// have been created, MKUserTracker should be able to recieve locations from this class at a much higher rate
// than they were collected. so that tests can be completed quickly

@synthesize locationManagerDelegate, locationSamples;

-(void)runAsync:(void (^)())completion{

    [self run];
    completion();
    

}

-(void)run{
    
    CLLocationManager *lm=[[CLLocationManager alloc] init];
    
    int count=[self.locationSamples count];
    
    
    for(CLLocation *l in self.locationSamples){
        
        
        
        [self.locationManagerDelegate locationManager:lm didUpdateLocations:@[l]];
        
    }
    
    
}





+(NSArray *)ReadSamplesFromFile:(NSString *)path{

    NSError *err;
  
    NSArray *rawSamples = (NSArray *)[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:&err];
    if(err){
        @throw [NSException exceptionWithName:err.description reason:err.debugDescription userInfo:nil];
    }
    
    
    NSMutableArray *samples=[[NSMutableArray alloc] init];
    
    for(NSDictionary *data in rawSamples){
        
        
        
        [samples addObject:[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([[data objectForKey:@"lat"] doubleValue], [[data objectForKey:@"lng"] doubleValue]) altitude:[[data objectForKey:@"alt"] doubleValue] horizontalAccuracy:[[data objectForKey:@"h-ac"] doubleValue] verticalAccuracy:[[data objectForKey:@"v-ac"] doubleValue] course:[[data objectForKey:@"crs"] doubleValue] speed:[[data objectForKey:@"spd"] doubleValue] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:[[data objectForKey:@"tms"] doubleValue]]]];
        
    }
    
    //[NSDate dateWithTimeIntervalSinceReferenceDate:<#(NSTimeInterval)#>]
    return samples;
}

@end
