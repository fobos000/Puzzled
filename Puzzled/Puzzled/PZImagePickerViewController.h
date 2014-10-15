//
//  PZImagePickerViewController.h
//  Puzzled
//
//  Created by Ostap Horbach on 10/8/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PZImagePickerViewController;

@protocol PZImagePickerDelegate <NSObject>

- (void)imagePicker:(PZImagePickerViewController *)picker didPickImage:(UIImage *)image;

@end

@interface PZImagePickerViewController : UIViewController

@property (nonatomic, weak) id <PZImagePickerDelegate> delegate;

@end
