//
//  NSIndexPath+RowColumn.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/25/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NSIndexPath+RowColumn.h"

@implementation NSIndexPath (RowColumn)

+ (instancetype)indexPathWithRow:(NSInteger)row column:(NSInteger)column
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:column];
    return path;
}

- (NSInteger)column
{
    return self.section;
}

@end
