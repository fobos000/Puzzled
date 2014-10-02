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

- (void)replaceObjectAtIndexPath:(NSIndexPath *)path withObject:(id)object
{
    NSAssert(path.row < _cells.count, @"row index is too big");
    NSAssert(path.column < _cells.count, @"column index is too big");
    
    [_cells[path.row] replaceObjectAtIndex:path.column withObject:object];
}

- (void)swipeObjectAtIndexPath:(NSIndexPath *)path1 withObjectAtIndexPath:(NSIndexPath *)path2
{
    NSLog(@"%@", self);
    
    id object1 = [self objectAtIndexPath:path1];
    id object2 = [self objectAtIndexPath:path2];
    [self replaceObjectAtIndexPath:path1 withObject:object2];
    [self replaceObjectAtIndexPath:path2 withObject:object1];
    
    NSLog(@"%@", self);
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    for (int i = 0; i < _cells.count; i++) {
        for (int j = 0; j < [_cells[i] count]; j++) {
            id objectAtIndex = _cells[i][j];
            [description appendString:[objectAtIndex description]];
        }
        [description appendString:@"\n"];
    }
    
    return description;
}

@end
