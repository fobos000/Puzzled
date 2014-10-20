//
//  PZPuzzleContainer.h
//  Puzzled
//
//  Created by Ostap Horbach on 8/23/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZPuzzleSize.h"

@class PZPuzzleContainer;

@protocol PZPuzzleContainerDataSorce <NSObject>

@required
- (CGSize)imageSizeForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer;
- (PuzzleSize)sizeForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer;
- (UIImage *)imageForCellAtIndexPath:(NSIndexPath *)index;
- (NSIndexPath *)indexOfEmptyPuzzleForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer;

@end

@protocol PZPuzzleContainerDelegate <NSObject>

@end

@interface PZPuzzleContainer : UIView

@property (nonatomic, weak) id<PZPuzzleContainerDataSorce> dataSource;
@property (nonatomic, weak) id<PZPuzzleContainerDelegate> delegate;

@end
