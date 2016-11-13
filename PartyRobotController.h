//
//  PartyRobotController.h
//  ButtonDrive
//
//  Created by Patrick Murray on 13/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RobotKit/RobotKit.h>
#import <RobotUIKit/RobotUIKit.h>


@interface PartyRobotController : NSObject <RKResponseObserver>

@property (strong, nonatomic) RKConvenienceRobot* robot;
@property (strong, nonatomic) RKLocatorData *locatorDataStart;
@property (strong, nonatomic) RKLocatorData *locatorDataMoving;
@property (strong, nonatomic) RKLocatorData *locatorHole;


+ (PartyRobotController *) sharedSingleton;


- (void) setUp;


- (void) placeSphero;
- (void) goRandom;



- (void) swingHeld;
- (void) swingReleased;



- (void) STOP;


@end
