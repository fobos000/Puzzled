//
//  PZMatrix.h
//  Puzzled
//
//  Created by Ostap Horbach on 9/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PZPuzzleSize.h"

@interface PZMatrix : NSObject

@property (nonatomic, readonly) PuzzleSize size;

- (id)initWithSize:(PuzzleSize)size objects:(NSArray *)objects;
- (id)objectAtIndexPath:(NSIndexPath *)path;
- (void)swipeObjectAtIndexPath:(NSIndexPath *)path1 withObjectAtIndexPath:(NSIndexPath *)path2;
- (NSIndexPath *)indexPathOfObject:(id)object;

@end
