//
//  PZPuzzleCell.h
//  Puzzled
//
//  Created by Ostap Horbach on 8/23/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PZPuzzleCell : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, setter=setEmpty:) BOOL isEmpty;

@end
