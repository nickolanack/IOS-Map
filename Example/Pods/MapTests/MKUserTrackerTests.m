//
//  MKUserTrackerTests.m
//  MapTrack
//
//  Created by Nick Blackwell on 2015-11-03.
//  Copyright © 2015 Nick Blackwell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKUserTracker.h"
#import "MockCLLocationManager.h"
#import "MKUserTrackerDelegate.h"

@interface MKUserTrackerTests : XCTestCase<MKUserTrackerDelegate>

@property (copy) void (^distanceDidChange)(float distance, float previousDistance);
@property (copy) void (^speedDidChange)(float speed, float previousSpeed);
@property (copy) void (^pathDidChange)(MKStyledPolyline *path, MKStyledPolyline * previousPath);


//(copy) void (^blockProperty)(void);

@end

@implementation MKUserTrackerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)userTrackerDistanceDidChange:(float)distance From:(float)previousDistance{
    if(_distanceDidChange){
        _distanceDidChange(distance,previousDistance);
    }
}
-(void)userTrackerPathDidChange:(MKStyledPolyline *)path From:(MKStyledPolyline *)previousPath{
}
-(void)userTrackerSpeedDidChangeTo:(float)speed From:(float)previousSpeed{
    if(_speedDidChange){
        _speedDidChange(speed,previousSpeed);
    }
}

- (void)testUserTracker {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    MKUserTracker *tracker=[[MKUserTracker alloc] init]; //do not init with map for testing
    MockCLLocationManager *mock=[[MockCLLocationManager alloc] init];
    [mock setLocationManagerDelegate:tracker];
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-0.json" ofType:nil]]];
    [tracker startTrackingLocation];
    XCTAssert([tracker isTracking]==true);
    
    [tracker setDelegate:self];
    _distanceDidChange=^(float distance, float previousDistance){
        XCTAssertGreaterThanOrEqual(distance, previousDistance);
    };
    
    _speedDidChange=^(float speed, float previousSpeed){
        XCTAssertGreaterThanOrEqual(speed, 0);
    };
    
    [mock runAsync:^{
        
        //1446228893.405128 to 1446229088.185225
        long double interval=[tracker getTimeInterval];
        long double calc =1446229088.185225l-1446228893.405128l;
        double delta=(double)fabsl(interval-calc);
        
        XCTAssertLessThan(delta, 0.001);
        XCTAssertGreaterThan([tracker getDistance], 0);
        XCTAssertGreaterThanOrEqual([tracker getSpeed], 0);
        
        
        [tracker stopTrackingLocation];
        XCTAssert([tracker isTracking]==false);
    }];
    
    _distanceDidChange=nil;
    _speedDidChange=nil;
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-1.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"tracklog-2.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"locationlog-0.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    
    
    [mock setLocationSamples:[MockCLLocationManager ReadSamplesFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"locationlog-16.json" ofType:nil]]];
    [tracker startTrackingLocation];
    [mock run];
    [tracker stopTrackingLocation];
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
