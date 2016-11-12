//
//  Copyright (c) 2011-2014 Orbotix, Inc. All rights reserved.
//

#import "ButtonDriveViewController.h"
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>


@interface ButtonDriveViewController() <RKResponseObserver>

@property (strong, nonatomic) RKConvenienceRobot* robot;
//@property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;
@property (strong, nonatomic) RKLocatorData *locatorDataStart;
@property (strong, nonatomic) RKLocatorData *locatorDataMoving;

@property (strong, nonatomic) CMMotionManager *motionManager;

@property double currentMaxAccelX;
@property double currentMaxAccelY;
@property double currentMaxAccelZ;

@property BOOL moving;

@property double distance;

@property BOOL stop;

@end

@implementation ButtonDriveViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    _moving = false;
	
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
    
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    _currentMaxAccelZ = 0;
    
	
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


- (void) startDriving {
    _locatorDataStart = _locatorDataMoving;
    [self spheroCommand];
}


- (void) spheroCommand {
    
    if (!_stop) {
        _moving = true;
        [_robot driveWithHeading:0.0 andVelocity:0.2];
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", _locatorDataStart.position.x, @"cm"]);
//        NSLog(@"%@", [NSString stringWithFormat:@"%.02f  %@", _locatorDataStart.position.y, @"cm"]);
        
        [_robot setLEDWithRed:0 green:0 blue:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self spheroCommand];
        });
    } else {
        [_robot setLEDWithRed:1 green:0 blue:0];
        [_robot stop];
        _moving = false;
        return;
    }

}


- (IBAction)zeroPressed:(id)sender {
    _distance = 100;
    _stop = false;
    [self startDriving];
}

- (IBAction)stopPressed:(id)sender {
    _stop = true;
    [self spheroCommand];
}


- (void)startLocatorStreaming {
    // Register for Locator X,Y position, and X,Y velocity
    RKDataStreamingMask sensorMask = RKDataStreamingMaskLocatorAll;
    [self.robot sendCommand:[RKSetDataStreamingCommand commandWithRate:5 andMask:sensorMask]];
}

- (void)handleAsyncMessage:(RKAsyncMessage *)message forRobot:(id<RKRobotBase>)robot {
    if ([message isKindOfClass:[RKDeviceSensorsAsyncData class]]) {
        
        // Grab specific sensor data objects from the main sensor object
        RKDeviceSensorsAsyncData *sensorsAsyncData = (RKDeviceSensorsAsyncData *)message;
        RKDeviceSensorsData *sensorsData = [sensorsAsyncData.dataFrames lastObject];
        RKLocatorData *locatorData = sensorsData.locatorData;
        _locatorDataMoving = locatorData;
        
//        NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);

        
        if (!_stop) {
            if (fabs(_locatorDataMoving.position.x) - fabs(_locatorDataStart.position.x) >= _distance) {
                NSLog(@"CURRENT x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                [self stopPressed:self];
            } else if (fabs(_locatorDataMoving.position.y) - fabs(_locatorDataStart.position.y) >= _distance) {
                NSLog(@"CURRENT x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                
                [self stopPressed:self];
            }
        }
        

    }
}

- (IBAction)swingButtonTouchDown:(id)sender {
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        
        if(fabs(motion.userAcceleration.x) > fabs(_currentMaxAccelX)) {
            _currentMaxAccelX = motion.userAcceleration.x;
        }
        if(fabs(motion.userAcceleration.y) > fabs(_currentMaxAccelY)) {
            _currentMaxAccelY = motion.userAcceleration.y;
        }
        if(fabs(motion.userAcceleration.z) > fabs(_currentMaxAccelZ)) {
            _currentMaxAccelZ = motion.userAcceleration.z;
        }
        
    }];
    
}


- (IBAction)swingButtonRelease:(id)sender {
    
    [self.motionManager stopDeviceMotionUpdates];
    
    
    NSLog(@"MOTION ACC - x: %f, y: %f, z: %f", _currentMaxAccelX, _currentMaxAccelY, _currentMaxAccelZ);
    
    
    
    _distance = (fabs(_currentMaxAccelZ) / 4) * 150;
    
    if (_distance >= 150) {
        _distance = 150;
    }
    
    _stop = false;
    [self startDriving];
    
    
    
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    _currentMaxAccelZ = 0;
    
    
    
}







@end
