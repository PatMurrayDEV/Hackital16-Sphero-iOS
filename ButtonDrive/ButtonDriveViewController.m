//
//  Copyright (c) 2011-2014 Orbotix, Inc. All rights reserved.
//

#import "ButtonDriveViewController.h"
#import "PartyRobotController.h"




@interface ButtonDriveViewController()



@property (weak, nonatomic) IBOutlet UILabel *forceLabel;
@property (weak, nonatomic) IBOutlet UILabel *strokeLabel;



@property int strokeCount;


@end

@implementation ButtonDriveViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(winOccured)
//                                                 name:@"WIN"
//                                               object:nil];
    
}



- (IBAction)swingButtonTouchDown:(id)sender {
    [[PartyRobotController sharedSingleton] swingHeld];
}


- (IBAction)swingButtonRelease:(id)sender {
    _strokeCount = _strokeCount + 1;
    [self setStroke:_strokeCount];
   [[PartyRobotController sharedSingleton] swingReleased];
}




- (IBAction)stopTapped:(id)sender {
    _strokeCount = 0;
    [self setStroke:_strokeCount];
    [[PartyRobotController sharedSingleton] placeSphero];
    [[PartyRobotController sharedSingleton] goRandom];
//    [[PJMRobotController sharedSingleton] stopPressed];

}

- (IBAction)gesturePerformed:(id)sender {
    
    [[PartyRobotController sharedSingleton] STOP];
}


- (void) winOccured {
        
    _strokeCount = 0;
    [self setStroke:_strokeCount];
    
    
}


- (void) setStroke:(int)stroke {
    
    _strokeLabel.text = [NSString stringWithFormat:@"Stroke: %d", stroke];
    
}


@end
