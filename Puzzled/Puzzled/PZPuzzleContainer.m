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
@property (nonatomic) CGSize cellSize;
@property (nonatomic, strong) NSMutableArray * cells;

@end

@implementation PZPuzzleContainer

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (!self.dataSource) {
        return;
    }
    
    _puzzleSize = [self.dataSource sizeForPuzzleContainer:self];
    
    for (int cellRow = 0; cellRow < _puzzleSize.numberOfRows; cellRow++) {
        for (int cellColumn = 0; cellColumn < _puzzleSize.numberOfColumns; cellColumn++) {
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
    
    int cellIndex = 0;
    for (int cellRow = 0; cellRow < _puzzleSize.numberOfRows; cellRow++) {
        for (int cellColumn = 0; cellColumn < _puzzleSize.numberOfColumns; cellColumn++) {
            NSIndexPath *cellPath = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
            CGPoint origin = [self originForCellAtIndexPath:cellPath];
            CGSize size = [self cellSize];
            PZPuzzleCell *cellAtIndex = _cells[cellIndex];
            cellAtIndex.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
            cellIndex++;
        }
    }
}

- (PZPuzzleCell *)cellAtIndexPath:(NSIndexPath *)path
{
    return _cells[path.row + path.column];
}


- (CGSize)cellSize
{
    if (CGSizeEqualToSize(_cellSize, CGSizeZero)) {
        CGFloat cellWidth = self.frame.size.width / self.puzzleSize.numberOfColumns;
        CGFloat cellHeight = self.frame.size.height / self.puzzleSize.numberOfRows;
        _cellSize = CGSizeMake(cellWidth, cellHeight);
    }
    
    return _cellSize;
}

- (CGPoint)originForCellAtIndexPath:(NSIndexPath *)path
{
    CGFloat cellX = path.column * [self cellSize].width;
    CGFloat cellY = path.row * [self cellSize].height;
    
    return CGPointMake(cellX, cellY);
}

@end
