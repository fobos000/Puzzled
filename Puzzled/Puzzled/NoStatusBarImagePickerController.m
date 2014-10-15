//
//  NoStatusBarImagePickerController.m
//  Puzzled
//
//  Created by Ostap Horbach on 10/8/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NoStatusBarImagePickerController.h"

@interface NoStatusBarImagePickerController ()

@end

@implementation NoStatusBarImagePickerController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

@end
