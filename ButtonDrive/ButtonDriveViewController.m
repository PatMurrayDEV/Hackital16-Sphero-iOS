//
//  Copyright (c) 2011-2014 Orbotix, Inc. All rights reserved.
//

#import "ButtonDriveViewController.h"
#import "PJMRobotController.h"




@interface ButtonDriveViewController()



@property (weak, nonatomic) IBOutlet UILabel *forceLabel;
@property (weak, nonatomic) IBOutlet UILabel *strokeLabel;

@property (weak, nonatomic) IBOutlet UISlider *slider;





@end

@implementation ButtonDriveViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [[PJMRobotController sharedSingleton] addObserver:self forKeyPath:@"stroke" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
	
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"From KVO");
    
    if([keyPath isEqualToString:@"stroke"])
    {
        id oldC = [change objectForKey:NSKeyValueChangeOldKey];
        id newC = [change objectForKey:NSKeyValueChangeNewKey];
        
        _strokeLabel.text = [NSString stringWithFormat:@"Stroke: %@", newC];
        
        NSLog(@"%@ %@", oldC, newC);
    }
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

- (IBAction)sliderBeSliding:(id)sender {

    double value = 180 - (_slider.value * 360);
    
    [[PJMRobotController sharedSingleton].robot driveWithHeading:value andVelocity:0];
}

- (IBAction)sliderTouchEnd:(id)sender {
    
    [self.slider setValue:0.5];
    
}




@end
