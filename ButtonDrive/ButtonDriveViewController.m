//
//  Copyright (c) 2011-2014 Orbotix, Inc. All rights reserved.
//

#import "ButtonDriveViewController.h"
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>

@interface ButtonDriveViewController() <RKResponseObserver>

@property (strong, nonatomic) RKConvenienceRobot* robot;
//@property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;
@property (strong, nonatomic) RKLocatorData *locatorDataStart;
@property (strong, nonatomic) RKLocatorData *locatorDataMoving;

@property BOOL moving;

@end

@implementation ButtonDriveViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillResignActive:)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appDidBecomeActive:)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];

	
//	self.calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];

	// hook up for robot state changes
	[[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
	
}


- (void)appDidBecomeActive:(NSNotification*)notification {
	[RKRobotDiscoveryAgent startDiscovery];
}


- (void)appWillResignActive:(NSNotification*)notification {
	[RKRobotDiscoveryAgent stopDiscovery];
    [RKRobotDiscoveryAgent disconnectAll];
}

- (void)handleRobotStateChangeNotification:(RKRobotChangedStateNotification*)n {
    switch(n.type) {
        case RKRobotConnecting:
            [self handleConnecting];
            break;
        case RKRobotOnline: {
            // Do not allow the robot to connect if the application is not running
            RKConvenienceRobot *convenience = [RKConvenienceRobot convenienceWithRobot:n.robot];
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
                [convenience disconnect];
                return;
            }
            self.robot = convenience;
            [self handleConnected];
            break;
        }
        case RKRobotDisconnected:
            [self handleDisconnected];
            self.robot = nil;
            [RKRobotDiscoveryAgent startDiscovery];
            break;
        default:
            break;
    }
}

- (void)handleConnecting {
    // Handle when a robot is connecting here
}

- (void)handleConnected {
//    [_calibrateHandler setRobot:_robot.robot];
    [_robot addResponseObserver:self];
    [self startLocatorStreaming];

}

- (void)handleDisconnected {
//    [_calibrateHandler setRobot:nil];
}

- (IBAction)zeroPressed:(id)sender {
    _moving = true;
	[_robot driveWithHeading:0.0 andVelocity:0.2];
    _locatorDataStart = _locatorDataMoving;
    NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", _locatorDataStart.position.x, @"cm"]);
    NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", _locatorDataStart.position.y, @"cm"]);

    [_robot setLEDWithRed:0 green:0 blue:1];
}

- (IBAction)stopPressed:(id)sender {
    [_robot setLEDWithRed:1 green:0 blue:0];
	[_robot stop];
    _moving = false;
}






- (void)startLocatorStreaming {
    // Register for Locator X,Y position, and X,Y velocity
    RKDataStreamingMask sensorMask = RKDataStreamingMaskLocatorAll;
    [self.robot sendCommand:[RKSetDataStreamingCommand commandWithRate:10 andMask:sensorMask]];
}

- (void)handleAsyncMessage:(RKAsyncMessage *)message forRobot:(id<RKRobotBase>)robot {
    if ([message isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        
        // Grab specific sensor data objects from the main sensor object
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)message;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
        RKLocatorData *locatorData = sensorsData.locatorData;
        _locatorDataMoving = locatorData;
        
        if (_moving) {
            if (_locatorDataMoving.position.x - _locatorDataStart.position.x > 10) {
                NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"]);
                NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                [self stopPressed:self];
            } else if (_locatorDataMoving.position.y - _locatorDataStart.position.y > 10) {
                NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"]);
                NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                
                [self stopPressed:self];
            }
        }
        
        
        
        // Print Locator Values
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"]);
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.velocity.x, @"cm/s"]);
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", locatorData.velocity.y, @"cm/s"]);
    }
}










@end
