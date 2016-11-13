//
//  Copyright (c) 2011-2014 Orbotix, Inc. All rights reserved.
//

#import "ButtonDriveViewController.h"
#import "PJMRobotController.h"




@interface ButtonDriveViewController()



@property (weak, nonatomic) IBOutlet UILabel *forceLabel;
@property (weak, nonatomic) IBOutlet UILabel *strokeLabel;






@end

@implementation ButtonDriveViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    
	
}




- (IBAction)swingButtonTouchDown:(id)sender {
    [[PJMRobotController sharedSingleton] swingButtonTouchDown];
}


- (IBAction)swingButtonRelease:(id)sender {
    [[PJMRobotController sharedSingleton] swingButtonRelease];
}




- (IBAction)stopTapped:(id)sender {
    [[PJMRobotController sharedSingleton] stopPressed];

}



@end
