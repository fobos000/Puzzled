//
//  PZImageSlicer.m
//  Puzzled
//
//  Created by Ostap Horbach on 9/5/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZImageSlicer.h"
#import "PZMatrix.h"
#import "PZUtilities.h"

@implementation PZImageSlicer

+ (PZMatrix *)slicedImagesWithImage:(UIImage *)image
                               puzzleSize:(PuzzleSize)puzzleSize
                          imageSize:(CGSize)imageSize
{
    CGSize newSize = [PZUtilities scaleSize:image.size toFitInSize:imageSize];
    UIImage *scaledImage = [PZUtilities imageWithImage:image scaledToSize:newSize];
    
    NSMutableArray *slicedImageArray = [NSMutableArray array];
    
    CGFloat sliceWidth = scaledImage.size.width / puzzleSize.numberOfColumns;
    CGFloat sliceHeight = scaledImage.size.height / puzzleSize.numberOfRows;
    
    for (int row = 0; row < puzzleSize.numberOfRows; row++) {
        for (int column = 0; column < puzzleSize.numberOfColumns; column++) {
            CGRect rect = CGRectMake(column * sliceWidth, row * sliceHeight, sliceWidth, sliceHeight);
            UIImage *slice = [self imageWithImage:scaledImage cropInRect:rect];
            [slicedImageArray addObject:slice];
        }
    }
    
    PZMatrix *slicedImageMatrix = [[PZMatrix alloc] initWithSize:puzzleSize objects:slicedImageArray];
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
