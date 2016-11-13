//
//  GameBoardViewController.m
//  ButtonDrive
//
//  Created by Patrick Murray on 12/11/2016.
//  Copyright © 2016 Orbotix, Inc. All rights reserved.
//

#import "GameBoardViewController.h"
#import "PJMRobotController.h"
#import <CoreImage/CoreImage.h>
#import "DrawView.h"

@interface GameBoardViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet DrawView *drawView;



@end

@implementation GameBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _drawView.strokeColor = [UIColor blackColor];
    _drawView.strokeWidth = 25.0f;
    _drawView.backgroundColor = [UIColor clearColor];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.showsCameraControls = YES;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES
                         completion:^ {
                         }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    
        
        UIImage *imageSized =  [self imageWithImage:image scaledToSize:CGSizeMake(500, 500)];
        self.imageView.image = imageSized;
//        [self.spinner startAnimating];


        
        

        
    }];
    
    
    
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}





- (void) startGame {
    [self performSegueWithIdentifier:@"startGameSegue" sender:self];
}



- (IBAction)goButtonTapped:(id)sender {
    
    _drawView.backgroundColor = [UIColor whiteColor];
    
//    [[PJMRobotController sharedSingleton] setImageForGame:[self imageWithImage:[_drawView imageRepresentation] scaledToSize:CGSizeMake(1000, 1000)]];
    
    _drawView.backgroundColor = [UIColor clearColor];
    
    [self performSegueWithIdentifier:@"startGameSegue" sender:self];

    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
