//
//  NSIndexPath+RowColumn.h
//  Puzzled
//
//  Created by Ostap Horbach on 8/25/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (RowColumn)

@property (nonatomic, readonly) NSInteger column;

- (BOOL)isEqualToIndexPath:(NSIndexPath *)path;

+ (instancetype)indexPathWithRow:(NSInteger)row column:(NSInteger)column;

@end
