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

@interface GameBoardViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;


@end

@implementation GameBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
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
        
        
    
        
        UIImage *imageSized =  [self grayscaleImage:[self imageWithImage:image scaledToSize:CGSizeMake(500, 500)]];
        self.imageView.image = imageSized;
        [self.spinner startAnimating];

        

        
        [[PJMRobotController sharedSingleton] setImageForGame:imageSized];


        [self.spinner stopAnimating];
        [self startGame];
        
        

        
    }];
    
    
    
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}





- (void) startGame {
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
