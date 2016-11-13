//
//  StartViewController.m
//  ButtonDrive
//
//  Created by Patrick Murray on 12/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import "StartViewController.h"
#import "PJMRobotController.h"


@interface StartViewController ()



@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [PJMRobotController sharedSingleton].alignmentView = self.view;
    [[PJMRobotController sharedSingleton] setUpRobot];
    
     [[PJMRobotController sharedSingleton].robot setBackLEDBrightness:.0];
    [[PJMRobotController sharedSingleton].robot setLEDWithRed:0 green:0 blue:0];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[PJMRobotController sharedSingleton].robot setBackLEDBrightness:0.0];
    
    [[PJMRobotController sharedSingleton] setIntitial];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[PJMRobotController sharedSingleton].robot setLEDWithRed:0 green:1 blue:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[PJMRobotController sharedSingleton].robot setLEDWithRed:1 green:0 blue:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[PJMRobotController sharedSingleton].robot setLEDWithRed:0 green:0 blue:1];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [[PJMRobotController sharedSingleton].robot setLEDWithRed:1 green:1 blue:1];
                });
            });
        });
    });
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




@end
