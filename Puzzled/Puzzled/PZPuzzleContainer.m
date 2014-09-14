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
#import "PZMatrix.h"

@interface PZPuzzleContainer ()

@property (nonatomic) PuzzleSize puzzleSize;
@property (nonatomic) CGSize cellSize;
@property (nonatomic, strong) PZMatrix *puzzleMatrix;
@property (nonatomic) BOOL dragging;
@property (nonatomic, strong) PZPuzzleCell *draggedCell;
@property (nonatomic) CGFloat dX;
@property (nonatomic) CGFloat dY;

@end

@implementation PZPuzzleContainer

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (!self.dataSource) {
        return;
    }
    
    _puzzleSize = [self.dataSource sizeForPuzzleContainer:self];
    
    NSMutableArray *cells = [@[] mutableCopy];
    for (int cellRow = 0; cellRow < _puzzleSize.numberOfRows; cellRow++) {
        for (int cellColumn = 0; cellColumn < _puzzleSize.numberOfColumns; cellColumn++) {
            NSIndexPath *path = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
            UIImage *image = [self.dataSource imageForCellAtIndexPath:path];
            PZPuzzleCell *cellForIndex = [[PZPuzzleCell alloc] init];
            cellForIndex.image = image;
            [cells addObject:cellForIndex];
            [self addSubview:cellForIndex];
        }
    }
    _puzzleMatrix = [[PZMatrix alloc] initWithSize:[self.dataSource sizeForPuzzleContainer:self]
                                    objects:cells];
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
            PZPuzzleCell *cellAtIndex = [_puzzleMatrix objectAtIndexPath:cellPath];
            cellAtIndex.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
            cellIndex++;
        }
    }
}

- (PZPuzzleCell *)cellAtIndexPath:(NSIndexPath *)path
{
    return [_puzzleMatrix objectAtIndexPath:path];
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

- (CGRect)frameForCellAtIndexPath:(NSIndexPath *)path
{
    CGPoint origin = [self originForCellAtIndexPath:path];
    CGSize size = [self cellSize];
    
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

- (NSIndexPath *)indexPathAtPoint:(CGPoint)point
{
    NSIndexPath *indexPathAtPoint = nil;
    
    for (int column = 0; column < _puzzleSize.numberOfColumns; column++) {
        for (int row = 0; row < _puzzleSize.numberOfRows; row++) {
            NSIndexPath *path = [NSIndexPath indexPathWithRow:row column:column];
            CGRect rectAtIndexPath = [self frameForCellAtIndexPath:path];
            if (CGRectContainsPoint(rectAtIndexPath, point)) {
                indexPathAtPoint = path;
            }
        }
    }
    
    return indexPathAtPoint;
}

- (PZPuzzleCell *)puzzleCellAtPoint:(CGPoint)point
{
    PZPuzzleCell *cell = nil;
    
    NSIndexPath *path = [self indexPathAtPoint:point];
    cell = [_puzzleMatrix objectAtIndexPath:path];
    
    return cell;
}

#pragma mark - 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.frame, touchLocation)) {
        PZPuzzleCell *puzzleCell = [self puzzleCellAtPoint:touchLocation];
        _draggedCell = puzzleCell;
        _dragging = YES;
        _dX = touchLocation.x - puzzleCell.frame.origin.x;
        _dY = touchLocation.y - puzzleCell.frame.origin.y;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (_dragging) {
        CGRect frame = _draggedCell.frame;
        frame.origin.x = touchLocation.x - _dX;
        frame.origin.y =  touchLocation.y - _dY;
        _draggedCell.frame = frame;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _dragging = NO;
}

@end
