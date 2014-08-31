//
//  PZPuzzleViewController.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/31/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZPuzzleViewController.h"
#import "PZPuzzleContainer.h"

@interface PZPuzzleViewController () <PZPuzzleContainerDataSorce, PZPuzzleContainerDelegate>
@property (weak, nonatomic) IBOutlet PZPuzzleContainer *puzzleContainer;

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
    PuzzleSize size = {3, 3};
    return size;
}

- (UIImage *)imageForCellAtIndexPath:(NSIndexPath *)index
{
    return [UIImage imageNamed:@"half-life"];
}


@end
