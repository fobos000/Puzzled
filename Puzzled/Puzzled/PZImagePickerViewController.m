//
//  PZImagePickerViewController.m
//  Puzzled
//
//  Created by Ostap Horbach on 10/8/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZImagePickerViewController.h"
#import "NoStatusBarImagePickerController.h"

@interface PZImagePickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NoStatusBarImagePickerController *imagePickerController;

@end

@implementation PZImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    
    NoStatusBarImagePickerController *imagePickerController = [[NoStatusBarImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    if ([self.delegate respondsToSelector:@selector(imagePicker:didPickImage:)]) {
        [self.delegate imagePicker:self didPickImage:chosenImage];
    }
}

- (IBAction)takeAPicture:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)chooseExistingPicture:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

@end
