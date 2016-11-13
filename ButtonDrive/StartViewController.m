//
//  StartViewController.m
//  ButtonDrive
//
//  Created by Patrick Murray on 12/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import "StartViewController.h"
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>

@interface StartViewController ()

@property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;
@property (strong, nonatomic) RKConvenienceRobot* robot;


@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.calibrateHandler = [[RUICalibrateGestureHandler alloc] initWithView:self.view];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_calibrateHandler setRobot:_robot.robot];
    [_robot setBackLEDBrightness:1.0];
    [_robot setLEDWithRed:0 green:0 blue:0];
}

- (void)handleDisconnected {
    [_calibrateHandler setRobot:nil];
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [_robot setBackLEDBrightness:0.0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_robot setLEDWithRed:0 green:1 blue:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_robot setLEDWithRed:1 green:0 blue:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_robot setLEDWithRed:0 green:0 blue:1];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_robot setLEDWithRed:1 green:1 blue:1];
                });
            });
        });
    });
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




@end
