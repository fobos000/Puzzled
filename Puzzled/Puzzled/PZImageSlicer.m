//
//  PZImageSlicer.m
//  Puzzled
//
//  Created by Ostap Horbach on 9/5/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZImageSlicer.h"
#import "PZMatrix.h"

@implementation PZImageSlicer

+ (PZMatrix *)slicedImagesWithImage:(UIImage *)image size:(PuzzleSize)size
{
    NSMutableArray *slicedImageArray = [NSMutableArray array];
    
    CGFloat sliceWidth = image.size.width / size.numberOfColumns;
    CGFloat sliceHeight = image.size.height / size.numberOfRows;
    
    for (int row = 0; row < size.numberOfRows; row++) {
        for (int column = 0; column < size.numberOfColumns; column++) {
            CGRect rect = CGRectMake(column * sliceWidth, row * sliceHeight, sliceWidth, sliceHeight);
            UIImage *slice = [self imageWithImage:image cropInRect:rect];
            [slicedImageArray addObject:slice];
        }
    }
    
    PZMatrix *slicedImageMatrix = [[PZMatrix alloc] initWithSize:size objects:slicedImageArray];
    return slicedImageMatrix;
}

+ (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect
{
    NSParameterAssert(image != nil);
    if (CGPointEqualToPoint(CGPointZero, rect.origin) && CGSizeEqualToSize(rect.size, image.size)) {
        return image;
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    [image drawAtPoint:(CGPoint){-rect.origin.x, -rect.origin.y}];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

@end
