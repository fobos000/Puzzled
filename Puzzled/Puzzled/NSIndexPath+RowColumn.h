//
//  NSIndexPath+RowColumn.h
//  Puzzled
//
//  Created by Ostap Horbach on 8/25/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (RowColumn)

+ (id)indexPathWithRow:(NSInteger)row column:(NSInteger)column;

@property (nonatomic, readonly) NSInteger column;

@end
