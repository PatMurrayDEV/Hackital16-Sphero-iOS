//
//  PJMRobotController.m
//  ButtonDrive
//
//  Created by Patrick Murray on 12/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import "PJMRobotController.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>
#import "ButtonDrive-Swift.h"
#import <CoreLocation/CoreLocation.h>


@interface PJMRobotController() <RKResponseObserver>

@property BOOL moving;

@property double distance;

@property BOOL stop;

@property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;

@property (strong, nonatomic) PuttPuttGameLogic *gameEngine;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CMMotionManager *motionManager;

@property double currentMaxAccelX;
@property double currentMaxAccelY;
@property double currentMaxAccelZ;


@property double angleStart;
@property double angleEnd;
@property double angle;




@end


@implementation PJMRobotController


+ (PJMRobotController *)sharedSingleton {
    static PJMRobotController *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[PJMRobotController alloc] init];
        
        return sharedSingleton;
    }
}







- (void) setIntitial {
    
    [_gameEngine setInitialWithX:_locatorDataMoving.position.x y:_locatorDataMoving.position.y];
    _stroke = 0;
    
}



- (void) setUpRobot {
    _moving = false;
    
    self.calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.alignmentView];
    
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
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingHeading];
    
    _angleStart = [self.locationManager heading].trueHeading;

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
    [_robot addResponseObserver:self];
    [self startLocatorStreaming];
    [_robot setBackLEDBrightness:1.0];
    [_robot setLEDWithRed:0 green:0 blue:0];
    [_calibrateHandler setRobot:_robot.robot];
    
}

- (void)handleDisconnected {
        [_calibrateHandler setRobot:nil];
}


- (void) startDriving {
    _locatorDataStart = _locatorDataMoving;
    [self spheroCommand];
}


- (void) spheroCommand {
    
    if (!_stop) {
        _moving = true;
        [_robot driveWithHeading:_angle andVelocity:0.2];
        
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


- (void)zeroPressed {
    _distance = 100;
    _stop = false;
    [self startDriving];
}

- (void)stopPressed{
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
                [self stopPressed];
            } else if (fabs(_locatorDataMoving.position.y) - fabs(_locatorDataStart.position.y) >= _distance) {
                NSLog(@"CURRENT x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                NSLog(@"x: %@, y: %@", [NSString stringWithFormat:@"%.02f  %@", locatorData.position.x, @"cm"], [NSString stringWithFormat:@"%.02f  %@", locatorData.position.y, @"cm"]);
                
                [self stopPressed];
            } else {
                NSArray<NSNumber *> *results = [_gameEngine puttGolfBallToBallX:locatorData.position.x ballY:locatorData.position.y];
                
                if (results[1].boolValue == YES) {
                    [self stopPressed];
                } else if (results[0].boolValue == YES) {
                    [self win];
                }
                
                
                
            }
        }
        
        
    }
}


- (void) win {
    
    [self stopPressed];
    
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
                                    [_robot setLEDWithRed:0 green:0 blue:0];
                                });
                            });
                        });
                    });
                });
            });
        });
    });
    
}




- (void)swingButtonTouchDown {
    
    _angleStart = [self.locationManager heading].trueHeading;

    
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




- (void)swingButtonRelease {
    
    [self.motionManager stopDeviceMotionUpdates];
    
    
    _angleEnd = [self.locationManager heading].trueHeading;
    
    _angle = [self.locationManager heading].trueHeading;
    
    
    NSLog(@"MOTION ACC - x: %f, y: %f, z: %f", _currentMaxAccelX, _currentMaxAccelY, _currentMaxAccelZ);
    
    
    
    _distance = (fabs(_currentMaxAccelZ) / 4) * 150;
    
    if (_distance >= 150) {
        _distance = 150;
    }
    
    _stop = false;
    [self startDriving];
    
    _stroke = _stroke + 1;
    
    
    
    _currentMaxAccelX = 0;
    _currentMaxAccelY = 0;
    _currentMaxAccelZ = 0;
    
    
    
}




- (void) setImageForGame:(UIImage*)image {
    
    
    _gameEngine = [[PuttPuttGameLogic alloc] initWithImage:image startX:0 startY:0 endX:1000 endY:1000];
    
    
    
}





@end
