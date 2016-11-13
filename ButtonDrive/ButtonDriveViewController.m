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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(winOccured)
                                                 name:@"WIN"
                                               object:nil];
    
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
    
    NSNumber *num = [NSNumber numberWithInt:_strokeCount];
    
    
    NSDictionary *headers = @{ @"content-type": @"application/json"};
    NSDictionary *parameters = @{ @"name": @"Patrick",
                                  @"score": num };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sphero-golf-score-board.herokuapp.com/"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                    }
                                                }];
    [dataTask resume];
    
    _strokeCount = 0;
    [self setStroke:_strokeCount];
    
    
}


- (void) setStroke:(int)stroke {
    
    _strokeLabel.text = [NSString stringWithFormat:@"Stroke: %d", stroke];
    
}


@end
