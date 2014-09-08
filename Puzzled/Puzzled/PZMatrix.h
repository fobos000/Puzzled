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

- (id)initWithSize:(PuzzleSize)size objects:(NSArray *)objects;
- (id)objectAtIndexPath:(NSIndexPath *)path;

@end
