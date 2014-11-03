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
#import "PZUtilities.h"

//@interface PZPuzzleCellPlaceholder : NSObject
//
//@property (nonatomic, strong) PZPuzzleCell *cell;
//
//@property (nonatomic, strong) NSIndexPath *originalIndexPath;
//@property (nonatomic, strong) NSIndexPath *currentIndexPath;
//@property (nonatomic) BOOL empty;
//
//@end
//
//@implementation PZPuzzleCellPlaceholder
//
//- (void)setEmpty:(BOOL)empty
//{
//    if (empty) {
//        self.cell.alpha = 0.0f;
//    } else {
//        self.cell.alpha = 1.0f;
//    }
//    _empty = empty;
//}
//
//@end

typedef enum : NSUInteger {
    UndefinedMoveDirection,
    LeftMoveDirection,
    RightMoveDirection,
    UpMoveDirection,
    DownMoveDirection
} MoveDirection;

@interface PZPuzzleContainer ()

@property (nonatomic) UIView *puzzleView;
@property (nonatomic) PuzzleSize puzzleSize;
@property (nonatomic) CGSize cellSize;
@property (nonatomic, strong) PZMatrix *puzzleMatrix;
@property (nonatomic) BOOL dragging;
@property (nonatomic, strong) PZPuzzleCell *draggedCell;
@property (nonatomic, strong) PZPuzzleCell *emptyCell;
@property (nonatomic) CGFloat dX;
@property (nonatomic) CGFloat dY;
@property (nonatomic) CGPoint initialTouch;
@property (nonatomic) NSIndexPath *indexPathOfDraggedCell;
@property (nonatomic) CGRect movementRect;

@end

@implementation PZPuzzleContainer

- (void)setDataSource:(id<PZPuzzleContainerDataSorce>)dataSource
{
    if (dataSource) {
        _dataSource = dataSource;
        
        CGSize originalSize = [_dataSource imageSizeForPuzzleContainer:self];
        CGSize puzzleViewSize = [PZUtilities scaleSize:originalSize toFitInSize:self.frame.size];
        CGRect puzzleViewFrame = CGRectMake(0, 0, puzzleViewSize.width, puzzleViewSize.height);
        _puzzleView = [[UIView alloc] initWithFrame:puzzleViewFrame];
        _puzzleView.center = self.center;
        [self addSubview:_puzzleView];
        
        _puzzleSize = [_dataSource sizeForPuzzleContainer:self];
        
        NSMutableArray *cells = [@[] mutableCopy];
        for (int cellRow = 0; cellRow < _puzzleSize.numberOfRows; cellRow++) {
            for (int cellColumn = 0; cellColumn < _puzzleSize.numberOfColumns; cellColumn++) {
                NSIndexPath *path = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
                
                UIImage *image = [_dataSource imageForCellAtIndexPath:path];
                PZPuzzleCell *cellForIndex = [[PZPuzzleCell alloc] init];
                cellForIndex.image = image;
                
//                PZPuzzleCellPlaceholder *placeholder = [[PZPuzzleCellPlaceholder alloc] init];
//                placeholder.originalIndexPath = path;
//                placeholder.currentIndexPath = path;
//                placeholder.cell = cellForIndex;
                
                [cells addObject:cellForIndex];
                [_puzzleView addSubview:cellForIndex];
            }
        }
        _puzzleMatrix = [[PZMatrix alloc] initWithSize:[_dataSource sizeForPuzzleContainer:self]
                                               objects:cells];
        
        NSIndexPath *emptyCellIndexPath = [_dataSource indexOfEmptyPuzzleForPuzzleContainer:self];
        PZPuzzleCell *emptyCell = [self cellAtIndexPath:emptyCellIndexPath];
        emptyCell.isEmpty = YES;
        _emptyCell = emptyCell;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (!self.dataSource) {
        return;
    }
    
//    CGSize originalSize = [self.dataSource imageSizeForPuzzleContainer:self];
//    CGSize puzzleViewSize = [PZUtilities scaleSize:originalSize toFitInSize:self.frame.size];
//    CGRect puzzleViewFrame = CGRectMake(0, 0, puzzleViewSize.width, puzzleViewSize.height);
//    _puzzleView = [[UIView alloc] initWithFrame:puzzleViewFrame];
//    [self addSubview:_puzzleView];
//
//    _puzzleSize = [self.dataSource sizeForPuzzleContainer:self];
//    
//    NSMutableArray *cells = [@[] mutableCopy];
//    for (int cellRow = 0; cellRow < _puzzleSize.numberOfRows; cellRow++) {
//        for (int cellColumn = 0; cellColumn < _puzzleSize.numberOfColumns; cellColumn++) {
//            NSIndexPath *path = [NSIndexPath indexPathWithRow:cellRow column:cellColumn];
//            
//            UIImage *image = [self.dataSource imageForCellAtIndexPath:path];
//            PZPuzzleCell *cellForIndex = [[PZPuzzleCell alloc] init];
//            cellForIndex.image = image;
//            
//            PZPuzzleCellPlaceholder *placeholder = [[PZPuzzleCellPlaceholder alloc] init];
//            placeholder.originalIndexPath = path;
//            placeholder.currentIndexPath = path;
//            placeholder.cell = cellForIndex;
//            
//            [cells addObject:placeholder];
//            [_puzzleView addSubview:cellForIndex];
//        }
//    }
//    _puzzleMatrix = [[PZMatrix alloc] initWithSize:[self.dataSource sizeForPuzzleContainer:self]
//                                    objects:cells];
//    
//    NSIndexPath *emptyCellIndexPath = [self.dataSource indexOfEmptyPuzzleForPuzzleContainer:self];
//    PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:emptyCellIndexPath];
//    placeholder.empty = YES;
//    _emptyCell = placeholder.cell;
    
//    [_puzzleMatrix shuffle];
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
//            PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:cellPath];
//            PZPuzzleCell *cellAtIndex = placeholder.cell;
            PZPuzzleCell *cellAtIndex = [self cellAtIndexPath:cellPath];
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
        CGFloat cellWidth = _puzzleView.frame.size.width / self.puzzleSize.numberOfColumns;
        CGFloat cellHeight = _puzzleView.frame.size.height / self.puzzleSize.numberOfRows;
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
    
    for (int row = 0; row < _puzzleSize.numberOfRows; row++) {
        for (int column = 0; column < _puzzleSize.numberOfColumns; column++) {
            NSIndexPath *path = [NSIndexPath indexPathWithRow:row column:column];
            CGRect rectAtIndexPath = [self frameForCellAtIndexPath:path];
            if (CGRectContainsPoint(rectAtIndexPath, point)) {
                indexPathAtPoint = path;
            }
        }
    }
    
    return indexPathAtPoint;
}

- (NSIndexPath *)indexPathOfCell:(PZPuzzleCell *)cell
{
//    return [self]
    return [_puzzleMatrix indexPathOfObject:cell];
}

- (PZPuzzleCell *)puzzleCellAtPoint:(CGPoint)point
{
    PZPuzzleCell *puzzleCellAtPoint = nil;
    
    NSIndexPath *path = [self indexPathAtPoint:point];
//    PZPuzzleCellPlaceholder *placeholder = [_puzzleMatrix objectAtIndexPath:path];
//    cell = placeholder.cell;
    puzzleCellAtPoint = [self cellAtIndexPath:path];
    
    return puzzleCellAtPoint;
}

#pragma mark - 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:_puzzleView];
    
    if (CGRectContainsPoint(_puzzleView.frame, touchLocation)) {
        PZPuzzleCell *puzzleCell = [self puzzleCellAtPoint:touchLocation];
        _draggedCell = puzzleCell;
        _dX = touchLocation.x - puzzleCell.frame.origin.x;
        _dY = touchLocation.y - puzzleCell.frame.origin.y;
        _initialTouch = touchLocation;
        _indexPathOfDraggedCell = [self indexPathAtPoint:touchLocation];
        
        if ([self pathCellAtIndexCanSlide:_indexPathOfDraggedCell]) {
            _movementRect = CGRectUnion(_draggedCell.frame, _emptyCell.frame);
        }
    }
}

- (BOOL)isEmptyCellAtIndexPath:(NSIndexPath *)path
{
    PZPuzzleCell *cellAtIndex = [self cellAtIndexPath:path];
    return cellAtIndex.isEmpty;
}

- (NSIndexPath *)pathCellAtIndexCanSlide:(NSIndexPath *)cellIndex
{
    NSIndexPath *ip = cellIndex;
    
    if (ip.row > 0) {
        NSIndexPath *path = [NSIndexPath indexPathWithRow:ip.row - 1 column:ip.column];
        if ([self isEmptyCellAtIndexPath:path]) {
            return path;
        }
    }
    if (ip.row < _puzzleMatrix.size.numberOfRows - 1) {
        NSIndexPath *path = [NSIndexPath indexPathWithRow:ip.row + 1 column:ip.column];
        if ([self isEmptyCellAtIndexPath:path]) {
            return path;
        }
    }
    if (ip.column > 0) {
        NSIndexPath *path = [NSIndexPath indexPathWithRow:ip.row column:ip.column - 1];
        if ([self isEmptyCellAtIndexPath:path]) {
            return path;
        }
    }
    if (ip.column < _puzzleMatrix.size.numberOfColumns - 1) {
        NSIndexPath *path = [NSIndexPath indexPathWithRow:ip.row column:ip.column + 1];
        if ([self isEmptyCellAtIndexPath:path]) {
            return path;
        }
    }
    return nil;
}

- (BOOL)canSlideToDirection:(MoveDirection)direction
{
    BOOL canSlideToDirection = NO;
    
//    PZPuzzleCellPlaceholder *placeholder = [self placeholderAtDirection:direction];
    PZPuzzleCell *cell = [self cellAtDirection:direction];
    if (cell.isEmpty) {
        CGFloat maxX = CGRectGetMaxX(_draggedCell.frame);
        NSLog(@"%f", maxX);
        
        if (maxX < self.bounds.size.width) {
            canSlideToDirection = YES;
        }
    }
    
    return canSlideToDirection;
}

- (PZPuzzleCell *)cellAtDirection:(MoveDirection)direction
{
    PZPuzzleCell *cellAtDirection = nil;
    NSIndexPath *indexPathAtDirection = nil;
    switch (direction) {
        case LeftMoveDirection:
            if (_indexPathOfDraggedCell.column > 0) {
                indexPathAtDirection = [NSIndexPath indexPathWithRow:_indexPathOfDraggedCell.row
                                                              column:_indexPathOfDraggedCell.column - 1];
            }
            break;
        case RightMoveDirection:
            if (_indexPathOfDraggedCell.column < _puzzleMatrix.size.numberOfColumns - 1) {
                indexPathAtDirection = [NSIndexPath indexPathWithRow:_indexPathOfDraggedCell.row
                                                              column:_indexPathOfDraggedCell.column + 1];
            }
            break;
        case UpMoveDirection:
            if (_indexPathOfDraggedCell.row > 0) {
                indexPathAtDirection = [NSIndexPath indexPathWithRow:_indexPathOfDraggedCell.row - 1
                                                              column:_indexPathOfDraggedCell.column];
            }
            break;
        case DownMoveDirection:
            if (_indexPathOfDraggedCell.row < _puzzleMatrix.size.numberOfRows - 1) {
                indexPathAtDirection = [NSIndexPath indexPathWithRow:_indexPathOfDraggedCell.row
                                                              column:_indexPathOfDraggedCell.column - 1];
            }
            break;
            
        default:
            break;
    }
    
    if (indexPathAtDirection) {
        cellAtDirection = [self cellAtIndexPath:indexPathAtDirection];
    }
    return cellAtDirection;
}

- (NSArray *)slidableIndexPaths
{
    NSArray *slidableIndexPaths;
    
    NSIndexPath *emptyCellIndex = [self indexPathOfCell:_emptyCell];
    
    NSMutableArray *mutableSlidableIndexPaths = [@[] mutableCopy];
    if (emptyCellIndex.column > 0) {
        // Cell has left neighbor
        NSIndexPath *leftNeighborPath = [NSIndexPath indexPathWithRow:emptyCellIndex.row
                                                               column:emptyCellIndex.column - 1];
        [mutableSlidableIndexPaths addObject:leftNeighborPath];
    }
    
    if (emptyCellIndex.column < _puzzleMatrix.size.numberOfColumns - 1) {
        // Cell has right neighbor
        NSIndexPath *rightNeighborPath = [NSIndexPath indexPathWithRow:emptyCellIndex.row
                                                                column:emptyCellIndex.column + 1];
        [mutableSlidableIndexPaths addObject:rightNeighborPath];
    }
    
    if (emptyCellIndex.row > 0) {
        // Cell has top neighbor
        NSIndexPath *topNeighborPath = [NSIndexPath indexPathWithRow:emptyCellIndex.row - 1
                                                              column:emptyCellIndex.column];
        [mutableSlidableIndexPaths addObject:topNeighborPath];
    }
    
    if (emptyCellIndex.row < _puzzleMatrix.size.numberOfRows - 1) {
        // Cell has bottom neighbor
        NSIndexPath *bottomNeighborPath = [NSIndexPath indexPathWithRow:emptyCellIndex.row + 1
                                                                column:emptyCellIndex.column];
        [mutableSlidableIndexPaths addObject:bottomNeighborPath];
    }
    
    if (mutableSlidableIndexPaths.count > 0) {
        slidableIndexPaths = [NSArray arrayWithArray:mutableSlidableIndexPaths];
    }
    
    return slidableIndexPaths;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:_puzzleView];
    
    _dragging = YES;
    
    if (!CGRectEqualToRect(_movementRect, CGRectZero)) {
        CGRect newFrame = _draggedCell.frame;
        newFrame.origin.x = touchLocation.x - _dX;
        newFrame.origin.y = touchLocation.y - _dY;
        
        if (CGRectGetMinX(newFrame) < CGRectGetMinX(_movementRect)) {
            newFrame.origin.x = CGRectGetMinX(_movementRect);
        } else if (CGRectGetMaxX(newFrame) > CGRectGetMaxX(_movementRect)) {
            newFrame.origin.x = CGRectGetMaxX(_movementRect) - CGRectGetWidth(newFrame);
        }
        
        if (CGRectGetMinY(newFrame) < CGRectGetMinY(_movementRect)) {
            newFrame.origin.y = CGRectGetMinY(_movementRect);
        } else if (CGRectGetMaxY(newFrame) > CGRectGetMaxY(_movementRect)) {
            newFrame.origin.y = CGRectGetMaxY(_movementRect) - CGRectGetHeight(newFrame);
        }
        
        _draggedCell.frame = newFrame;
    }
}

- (void)moveCell:(PZPuzzleCell *)cell toPath:(NSIndexPath *)path animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            cell.frame = [self frameForCellAtIndexPath:path];
        }];
    } else {
        cell.frame = [self frameForCellAtIndexPath:path];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_dragging) {
        NSIndexPath *targetPath = [self pathCellAtIndexCanSlide:_indexPathOfDraggedCell];
        if (targetPath) {
            [self moveCell:_draggedCell toPath:targetPath animated:YES];
            _emptyCell.frame = [self frameForCellAtIndexPath:_indexPathOfDraggedCell];
            PZPuzzleCell *cell = [self cellAtIndexPath:targetPath];
            NSAssert(cell.isEmpty, @"Placeholeder not empty");
            [_puzzleMatrix swipeObjectAtIndexPath:targetPath withObjectAtIndexPath:_indexPathOfDraggedCell];
        }
    } else {
        _dragging = NO;
        
        CGPoint cellLocation = _draggedCell.center;
        
        NSIndexPath *indexPath = [self indexPathAtPoint:cellLocation];
        if (![_indexPathOfDraggedCell isEqualToIndexPath:indexPath]) {
            [_puzzleMatrix swipeObjectAtIndexPath:indexPath withObjectAtIndexPath:_indexPathOfDraggedCell];
            
        }
        [self setNeedsLayout];
    }
    
    _movementRect = CGRectZero;
}

#pragma mark - 

- (void)makeShuffle
{
    PZPuzzleCell *previousCell;
    for (int i = 0; i < _puzzleMatrix.size.numberOfRows * _puzzleMatrix.size.numberOfColumns; i++) {
        // Get possible cell index paths to slide
        NSArray *slidableIndexPaths = [self slidableIndexPaths];
        
        // Choose random puzzle to slide
        int random = arc4random_uniform((u_int)slidableIndexPaths.count);
        NSIndexPath *randomIndex = slidableIndexPaths[random];
        PZPuzzleCell *randomPuzzleCell = [self cellAtIndexPath:randomIndex];
        if (randomPuzzleCell == previousCell) {
            random = (random > 0) ? (random - 1) : (random + 1);
            randomIndex = slidableIndexPaths[random];
            randomPuzzleCell = [self cellAtIndexPath:randomIndex];
        }
        
        previousCell = randomPuzzleCell;
        
        // Slide random puzzle
        NSIndexPath *emptyCellIndex = [self indexPathOfCell:_emptyCell];
        [self moveCell:randomPuzzleCell toPath:emptyCellIndex animated:NO];
        [self moveCell:_emptyCell toPath:randomIndex animated:NO];
        [_puzzleMatrix swipeObjectAtIndexPath:randomIndex withObjectAtIndexPath:emptyCellIndex];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
    
    // Repeat
}

- (void)shuffle
{
    [_puzzleMatrix shuffleWithBlock:^(NSIndexPath *index1, NSIndexPath *index2) {
        CGRect frame1 = [self frameForCellAtIndexPath:index1];
        CGRect frame2 = [self frameForCellAtIndexPath:index2];
        PZPuzzleCell *cell1 = [self cellAtIndexPath:index1];
        PZPuzzleCell *cell2 = [self cellAtIndexPath:index2];
        
        __block BOOL completed = NO;
        [UIView animateWithDuration:.2 animations:^{
            cell1.frame = frame1;
            cell2.frame = frame2;
        } completion:^(BOOL finished) {
            completed = YES;
        }];
        
        while (!completed) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
    }];
}

@end
