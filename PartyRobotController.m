//
//  PartyRobotController.m
//  ButtonDrive
//
//  Created by Patrick Murray on 13/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import "PartyRobotController.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>


@interface PartyRobotController()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;

@property double currentMaxAccelX;
@property double currentMaxAccelY;
@property double currentMaxAccelZ;
@property double angle;
@property double distance;
@property BOOL stop;


@property double initialX;
@property double initialY;


@property BOOL performingRandom;


@property double initialCompass;





@end

@implementation PartyRobotController


+ (PartyRobotController *)sharedSingleton {
    static PartyRobotController *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[PartyRobotController alloc] init];
        
        return sharedSingleton;
    }
}



- (void) setUp {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    // hook up for robot state changes
    [[RKRobotDiscoveryAgent sharedAgent] addNotificationObserver:self selector:@selector(handleRobotStateChangeNotification:)];
    
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    _currentMaxAccelZ = 0;
    _performingRandom = NO;
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startDeviceMotionUpdates];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingHeading];
    
    _initialCompass = [self.locationManager heading].magneticHeading;
    
//    [self swingReleased];
    
}


- (void) placeSphero {
    
    _locatorHole = _locatorDataMoving;
    
}


- (void) goRandom {
    
    _performingRandom = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _stop = YES;
        _angle = 0;
        [self spheroCommand];
        _performingRandom = NO;
    });
    _stop = NO;
    _angle = arc4random_uniform(360);
    [self spheroCommand];
    
    
}



- (void) swingHeld {
    
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

- (void) swingReleased {
    
    [self.motionManager stopDeviceMotionUpdates];
    
    _angle = [self.locationManager heading].magneticHeading;
    
    NSLog(@"MOTION ACC - x: %f, y: %f, z: %f", _currentMaxAccelX, _currentMaxAccelY, _currentMaxAccelZ);
    
    _distance = (fabs(_currentMaxAccelZ) / 4) * 150;
    
    if (_distance >= 150) {
        _distance = 150;
    }
    
    _stop = false;
    _locatorDataStart = _locatorDataMoving;
    [self spheroCommand];
    
    
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    _currentMaxAccelZ = 0;
}



- (void) STOP {
    
    _stop = YES;
    _angle = 0;
    [self spheroCommand];
    
}




#pragma mark - SPHERO
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
    [_robot addResponseObserver:self];
    [self startLocatorStreaming];
    [_robot setBackLEDBrightness:1.0];
    [_robot setLEDWithRed:0 green:0 blue:0];
    
}

- (void)handleDisconnected {
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

        
        if (!_stop && !_performingRandom) {
            
            if (fabs(_locatorDataMoving.position.x) - fabs(_locatorDataStart.position.x) >= _distance) {
                NSLog(@"CURRENT x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                _stop = YES;
                _angle = 0;
                [self spheroCommand];
            } else if (fabs(_locatorDataMoving.position.y) - fabs(_locatorDataStart.position.y) >= _distance) {
                NSLog(@"CURRENT x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                
                _stop = YES;
                _angle = 0;
                [self spheroCommand];
            }
            
            if ((fabs(_locatorDataMoving.position.x - _locatorHole.position.x) <= 10) && (fabs(_locatorDataMoving.position.y - _locatorHole.position.y) <= 10)) {
                [self win];
            }

            
        }
        
        
    }
}


#pragma mark - sphero commands
- (void) spheroCommand {
    
    if (!_stop) {
        [_robot driveWithHeading:_angle andVelocity:0.2];
        [_robot setLEDWithRed:0 green:0 blue:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self spheroCommand];
        });
    } else {
        [_robot setLEDWithRed:1 green:0 blue:0];
        [_robot stop];
//        if ((fabs(_locatorDataMoving.position.x - _locatorHole.position.x) <= 10) && (fabs(_locatorDataMoving.position.y - _locatorHole.position.y) <= 10)) {
//            [self win];
//        }
        return;
    }
    
}


- (void) win {
    
    _stop = YES;
    _angle = 0;
    [self spheroCommand];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"WIN" object:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_robot setLEDWithRed:0 green:1 blue:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_robot setLEDWithRed:0 green:0 blue:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_robot setLEDWithRed:0 green:1 blue:0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_robot setLEDWithRed:0 green:0 blue:0];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [_robot setLEDWithRed:0 green:1 blue:0];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [_robot setLEDWithRed:0 green:0 blue:0];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [_robot setLEDWithRed:0 green:1 blue:0];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                    [_robot setLEDWithRed:0 green:1 blue:0.5];
                                });
                            });
                        });
                    });
                });
            });
        });
    });
    
}







@end
