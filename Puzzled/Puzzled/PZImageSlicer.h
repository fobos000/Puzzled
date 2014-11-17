//
//  PZImageSlicer.h
//  Puzzled
//
//  Created by Ostap Horbach on 9/5/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZPuzzleSize.h"

@class PZMatrix;

@interface PZImageSlicer : NSObject

+ (PZMatrix *)slicedImagesWithImage:(UIImage *)image
                         puzzleSize:(PuzzleSize)puzzleSize
                          imageSize:(CGSize)imageSize;

@end
