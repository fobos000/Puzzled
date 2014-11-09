//
//  PZPuzzleCell.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/23/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZPuzzleCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PZPuzzleCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PZPuzzleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
//        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _imageView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

//- (void)drawRect:(CGRect)rect
//{
//    
//}

@end
