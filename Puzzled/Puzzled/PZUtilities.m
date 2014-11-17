//
//  PZUtilities.m
//  Puzzled
//
//  Created by Ostap Horbach on 10/21/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZUtilities.h"

@implementation PZUtilities

+ (CGSize)scaleSize:(CGSize)size toFitInSize:(CGSize)inSize
{
    CGSize scaledSize = CGSizeZero;
    
    CGFloat sizeRatio = size.width / size.height;
    CGFloat inSizeRatio = inSize.width / inSize.height;
    
    if (sizeRatio < inSizeRatio) {
        scaledSize.height = inSize.height;
        scaledSize.width = sizeRatio * inSize.height;
    } else if (sizeRatio > inSizeRatio) {
        scaledSize.width = inSize.width;
        scaledSize.height = inSize.width / sizeRatio;
    } else {
        scaledSize = inSize;
    }
    
    return scaledSize;
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
