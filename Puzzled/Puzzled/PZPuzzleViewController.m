//
//  PZPuzzleViewController.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/31/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZPuzzleViewController.h"
#import "PZPuzzleContainer.h"
#import "PZImageSlicer.h"
#import "PZMatrix.h"
#import "NSIndexPath+RowColumn.h"

@interface PZPuzzleViewController () <PZPuzzleContainerDataSorce, PZPuzzleContainerDelegate>
@property (weak, nonatomic) IBOutlet PZPuzzleContainer *puzzleContainer;

@property (nonatomic, strong) PZMatrix *slicedImages;
@property (nonatomic) PuzzleSize puzzleSize;

@end

@implementation PZPuzzleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PuzzleSize size = {3, 3};
    self.puzzleSize = size;
    self.slicedImages = [PZImageSlicer slicedImagesWithImage:[UIImage imageNamed:@"half-life"] size:self.puzzleSize];
    
    self.puzzleContainer.dataSource = self;
    self.puzzleContainer.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (PuzzleSize)sizeForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer
{
    return self.puzzleSize;
}

- (UIImage *)imageForCellAtIndexPath:(NSIndexPath *)path
{
    return [self.slicedImages objectAtIndexPath:path];
}

- (NSIndexPath *)indexOfEmptyPuzzleForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer
{
    return [NSIndexPath indexPathWithRow:_puzzleSize.numberOfRows - 1 column:_puzzleSize.numberOfColumns - 1];
}

@end
