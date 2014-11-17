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

- (void)createPuzzleView
{
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
            [cells addObject:cellForIndex];
            [_puzzleView addSubview:cellForIndex];
        }
    }
    _puzzleMatrix = [[PZMatrix alloc] initWithSize:[_dataSource sizeForPuzzleContainer:self]
                                           objects:cells];
    
    NSIndexPath *emptyCellIndexPath = [_dataSource indexOfEmptyPuzzleForPuzzleContainer:self];
    PZPuzzleCell *emptyCell = [self cellAtIndexPath:emptyCellIndexPath];
    _emptyCell = emptyCell;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//- (void)setDataSource:(id<PZPuzzleContainerDataSorce>)dataSource
//{
//    if (dataSource) {
//        _dataSource = dataSource;
//        
//        [self createPuzzleView];
//    }
//}

- (void)reloadData
{
    if (_dataSource) {
        [_puzzleView removeFromSuperview];
        _puzzleView = nil;
        
        [self createPuzzleView];
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
    puzzleCellAtPoint = [self cellAtIndexPath:path];
    
    return puzzleCellAtPoint;
}

- (void)animateCell:(PZPuzzleCell *)cell toPath:(NSIndexPath *)path
{
    [UIView animateWithDuration:0.1 animations:^{
        cell.frame = [self frameForCellAtIndexPath:path];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:_puzzleView];
    
    if (CGRectContainsPoint(_puzzleView.bounds, touchLocation)) {
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

- (void)shuffle
{
    NSMutableArray *animations = [@[] mutableCopy];
    
    [_puzzleMatrix shuffleWithBlock:^(NSIndexPath *index1, NSIndexPath *index2) {
        PZPuzzleCell *cell1 = [self cellAtIndexPath:index1];
        CGRect frame1 = [self frameForCellAtIndexPath:index1];
        PZPuzzleCell *cell2 = [self cellAtIndexPath:index2];
        CGRect frame2 = [self frameForCellAtIndexPath:index2];
        
        [animations addObject:^{
            cell1.frame = frame1;
            cell2.frame = frame2;
        }];
    }];
    
    __block NSMutableArray* animationBlocks = [NSMutableArray new];
    typedef void(^animationBlock)(BOOL);
    typedef void(^chainBlock)(void);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        
        if ([animationBlocks count] > 0){
            animationBlock block = (animationBlock)[animationBlocks objectAtIndex:0];
            [animationBlocks removeObjectAtIndex:0];
            return block;
        } else {
            return ^(BOOL finished){
                animationBlocks = nil;
            };
        }
    };
    
    for (chainBlock block in animations) {
        [animationBlocks addObject:^(BOOL finished){
            [UIView animateWithDuration:1.0
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:block
                             completion:getNextAnimation()];
        }];
    }
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}

#pragma mark - 

- (void)makeShuffle
{
    //Disable user interacion during shuffling
    self.userInteractionEnabled = NO;
    
    NSMutableArray *animations = [@[] mutableCopy];
    [animations addObject:^{
        [_puzzleMatrix enumerateObjectsUsingBlock:^(id obj, NSUInteger row, NSUInteger column, BOOL *stop) {
            PZPuzzleCell *cell = obj;
            cell.bordersEnabled = YES;
        }];
        _emptyCell.isEmpty = YES;
    }];
    
    PZPuzzleCell *previousCell;
    for (int i = 0; i < _puzzleMatrix.size.numberOfRows * _puzzleMatrix.size.numberOfColumns * 2; i++) {
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
        [_puzzleMatrix swipeObjectAtIndexPath:randomIndex withObjectAtIndexPath:emptyCellIndex];
        
        [animations addObject:^{
            CGRect emptyCellFrame = _emptyCell.frame;
            _emptyCell.frame = randomPuzzleCell.frame;
            randomPuzzleCell.frame = emptyCellFrame;
        }];
    }
    
    [animations addObject:^{
        // Restore user interaction at the end of all animations
        self.userInteractionEnabled = YES;
    }];
    
    __block NSMutableArray* animationBlocks = [NSMutableArray new];
    typedef void(^animationBlock)(BOOL);
    typedef void(^chainBlock)(void);
    
    // getNextAnimation
    // removes the first block in the queue and returns it
    animationBlock (^getNextAnimation)() = ^{
        
        if ([animationBlocks count] > 0){
            animationBlock block = (animationBlock)[animationBlocks objectAtIndex:0];
            [animationBlocks removeObjectAtIndex:0];
            return block;
        } else {
            return ^(BOOL finished){
                animationBlocks = nil;
            };
        }
    };
    
    for (chainBlock block in animations) {
        [animationBlocks addObject:^(BOOL finished){
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:block
                             completion:getNextAnimation()];
        }];
    }
    
    // execute the first block in the queue
    getNextAnimation()(YES);
}

@end
