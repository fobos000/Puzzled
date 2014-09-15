//
//  PZMatrix.m
//  Puzzled
//
//  Created by Ostap Horbach on 9/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZMatrix.h"
#import "NSIndexPath+RowColumn.h"

@interface PZMatrix ()

@property (nonatomic, strong) NSMutableArray *cells;

@end

@implementation PZMatrix

- (id)initWithSize:(PuzzleSize)size objects:(NSArray *)objects
{
    NSAssert(objects.count == size.numberOfRows * size.numberOfColumns,
             @"matrix size doesn't match number of elements");
    
    self = [super init];
    if (self) {
        _size = size;
        _cells = [NSMutableArray arrayWithCapacity:size.numberOfRows];
        int objectIndex = 0;
        for (int column = 0; column < size.numberOfColumns; column++) {
            [_cells addObject:[NSMutableArray arrayWithCapacity:size.numberOfColumns]];
            for (int row = 0; row < size.numberOfRows; row++) {
                [_cells[column] addObject:objects[objectIndex]];
                objectIndex++;
            }
        }
    }
    return self;
}

- (id)objectAtIndexPath:(NSIndexPath *)path
{
    NSAssert(path.row < _cells.count, @"row index is too big");
    NSAssert(path.column < _cells.count, @"column index is too big");
    return _cells[path.row][path.column];
}

@end
