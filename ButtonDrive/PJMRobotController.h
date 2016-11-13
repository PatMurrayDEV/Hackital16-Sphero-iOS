//
//  PJMRobotController.h
//  ButtonDrive
//
//  Created by Patrick Murray on 12/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>

@interface PJMRobotController : NSObject

@property (strong, nonatomic) RKConvenienceRobot* robot;
//@property (strong, nonatomic) RUICalibrateGestureHandler *calibrateHandler;
@property (strong, nonatomic) RKLocatorData *locatorDataStart;
@property (strong, nonatomic) RKLocatorData *locatorDataMoving;

@property (strong, nonatomic) UIView *alignmentView;

@property int stroke;



+ (PJMRobotController *) sharedSingleton;

- (void)swingButtonTouchDown;
- (void)swingButtonRelease;
- (void) setUpRobot;
- (void)stopPressed;


- (void) setImageForGame:(UIImage*)image;
- (void) setIntitial;


@end
