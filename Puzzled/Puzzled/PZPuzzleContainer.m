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

@interface PZPuzzleCellPlaceholder : NSObject

@property (nonatomic, strong) PZPuzzleCell *cell;

@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic) BOOL empty;

@end

@implementation PZPuzzleCellPlaceholder

- (void)setEmpty:(BOOL)empty
{
    if (empty) {
        self.cell.alpha = 0.0f;
    } else {
        self.cell.alpha = 1.0f;
    }
    _empty = empty;
}

@end

typedef enum : NSUInteger {
    UndefinedMoveDirection,
    XMoveDirection,
    YMoveDirection
} MoveDirection;

@interface PZPuzzleContainer ()

@property (nonatomic) PuzzleSize puzzleSize;
@property (nonatomic) CGSize cellSize;
@property (nonatomic, strong) PZMatrix *puzzleMatrix;
@property (nonatomic) BOOL dragging;
@property (nonatomic, strong) PZPuzzleCell *draggedCell;
@property (nonatomic) CGFloat dX;
@property (nonatomic) CGFloat dY;
@property (nonatomic) CGPoint initialTouch;
@property (nonatomic) MoveDirection moveDirection;

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
            
            PZPuzzleCellPlaceholder *placeholder = [[PZPuzzleCellPlaceholder alloc] init];
            placeholder.originalIndexPath = path;
            placeholder.currentIndexPath = path;
            placeholder.cell = cellForIndex;
            
            [cells addObject:placeholder];
            [self addSubview:cellForIndex];
        }
    }
    _puzzleMatrix = [[PZMatrix alloc] initWithSize:[self.dataSource sizeForPuzzleContainer:self]
                                    objects:cells];
    
    NSIndexPath *emptyCellIndexPath = [self.dataSource indexOfEmptyPuzzleForPuzzleContainer:self];
    PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:emptyCellIndexPath];
    placeholder.empty = YES;
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
            PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:cellPath];
            PZPuzzleCell *cellAtIndex = placeholder.cell;
            cellAtIndex.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
            cellIndex++;
        }
    }
}

- (PZPuzzleCell *)cellAtIndexPath:(NSIndexPath *)path
{
    PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:path];
    return placeholder.cell;
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
    PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:path];
    cell = placeholder.cell;
    
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
        _initialTouch = touchLocation;
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (_dragging) {
        if (_moveDirection == UndefinedMoveDirection) {
            CGFloat deltaX = fabsf(_initialTouch.x - touchLocation.x);
            CGFloat deltaY = fabsf(_initialTouch.y - touchLocation.y);
            if (deltaX > deltaY) {
                _moveDirection = XMoveDirection;
            } else {
                _moveDirection = YMoveDirection;
            }
        }
        
        CGRect frame = _draggedCell.frame;
        if (_moveDirection == XMoveDirection) {
            frame.origin.x = touchLocation.x - _dX;
        } else if (_moveDirection == YMoveDirection) {
            frame.origin.y = touchLocation.y - _dY;
        }
        _draggedCell.frame = frame;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _dragging = NO;
    _moveDirection = UndefinedMoveDirection;
    
    CGPoint cellLocation = _draggedCell.center;
    
    NSIndexPath *initialIndexPath = [self indexPathAtPoint:_initialTouch];
    NSIndexPath *indexPath = [self indexPathAtPoint:cellLocation];
    [_puzzleMatrix swipeObjectAtIndexPath:indexPath withObjectAtIndexPath:initialIndexPath];
    [self setNeedsLayout];
}

@end
