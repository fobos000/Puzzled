//
//  PZPuzzleContainer.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/23/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZPuzzleContainer.h"
#import "PZPuzzleCell.h"
#import "NSIndexPath+RowColumn.h"

@interface PZPuzzleContainer ()

@property (nonatomic) PuzzleSize puzzleSize;
@property (nonatomic, strong) NSMutableArray * cells;

@end

@implementation PZPuzzleContainer

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (!self.dataSource) {
        return;
    }
    
    PuzzleSize size = [self.dataSource sizeForPuzzleContainer:self];
    
    int numOfCells = size.numberOfColumns * size.numberOfRows;
    for (int cellRow = 0; cellRow < numOfCells; cellRow++) {
        for (int cellColumn = 0; cellColumn < numOfCells; cellColumn++) {
            if (!_cells) {
                _cells = [@[] mutableCopy];
            }
            
            NSIndexPath *path = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
            UIImage *image = [self.dataSource imageForCellAtIndexPath:path];
            PZPuzzleCell *cellForIndex = [[PZPuzzleCell alloc] init];
            cellForIndex.image = image;
            [_cells addObject:cellForIndex];
            [self addSubview:cellForIndex];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    PuzzleSize size = [self.dataSource sizeForPuzzleContainer:self];
    
    for (int cellRow = 0; cellRow < size.numberOfRows; cellRow++) {
        for (int cellColumn = 0; cellColumn < size.numberOfColumns; cellColumn++) {
            NSIndexPath *cellPath = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
            CGPoint origin = [self originForCellAtIndexPath:cellPath];
            CGSize size = [self cellSize];
            PZPuzzleCell *cellAtIndex = [self cellAtIndexPath:[NSIndexPath indexPathWithRow:cellRow column:cellColumn]];
            cellAtIndex.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        }
    }
}

- (PZPuzzleCell *)cellAtIndexPath:(NSIndexPath *)path
{
    return nil;
}


- (CGSize)cellSize
{
    CGFloat cellWidth = self.frame.size.width / self.puzzleSize.numberOfColumns;
    CGFloat cellHeight = self.frame.size.height / self.puzzleSize.numberOfRows;
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGPoint)originForCellAtIndexPath:(NSIndexPath *)path
{
    CGFloat cellX = path.column * [self cellSize].width;
    CGFloat cellY = path.row * [self cellSize].height;
    
    return CGPointMake(cellX, cellY);
}




@end
