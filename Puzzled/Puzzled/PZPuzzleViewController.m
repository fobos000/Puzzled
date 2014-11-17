//
//  PZPuzzleViewController.m
//  Puzzled
//
//  Created by Ostap Horbach on 8/31/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "PZPuzzleViewController.h"
#import "PZImagePickerViewController.h"
#import "PZPuzzleContainer.h"
#import "PZImageSlicer.h"
#import "PZMatrix.h"
#import "NSIndexPath+RowColumn.h"

@interface PZPuzzleViewController () <PZPuzzleContainerDataSorce, PZPuzzleContainerDelegate, PZImagePickerDelegate>
@property (weak, nonatomic) IBOutlet PZPuzzleContainer *puzzleContainer;
@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;

@property (nonatomic, strong) PZMatrix *slicedImages;
@property (nonatomic) PuzzleSize puzzleSize;
@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) BOOL firstRun;


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
    _firstRun = YES;
    
//    PuzzleSize size = {6, 4};
//    self.puzzleSize = size;
//    self.slicedImages = [PZImageSlicer slicedImagesWithImage:[UIImage imageNamed:@"half-life"] size:self.puzzleSize];
//    self.selectedImage = [UIImage imageNamed:@"half-life"];
//    
//    self.puzzleContainer.dataSource = self;
//    self.puzzleContainer.delegate = self;
    
//    [self.puzzleContainer shuffle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_firstRun) {
        [self performSegueWithIdentifier:@"ImagePicker" sender:self];
        _firstRun = NO;
    } else {
        PuzzleSize size = {6, 4};
        self.puzzleSize = size;
        self.slicedImages = [PZImageSlicer slicedImagesWithImage:self.selectedImage size:self.puzzleSize];
        
        self.puzzleContainer.dataSource = self;
        self.puzzleContainer.delegate = self;
        
        [self.puzzleContainer reloadData];
        
        self.originalImageView.hidden = YES;
        [self.puzzleContainer makeShuffle];
    }
    
//    [self.puzzleContainer makeShuffle];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ImagePicker"]) {
        PZImagePickerViewController *picker = segue.destinationViewController;
        picker.delegate = self;
    }
}

#pragma mark - 

- (void)imagePicker:(PZImagePickerViewController *)picker didPickImage:(UIImage *)image
{
    self.selectedImage = image;
    self.originalImageView.image = image;
    self.originalImageView.hidden = NO;
    
}

#pragma mark -

- (CGSize)imageSizeForPuzzleContainer:(PZPuzzleContainer *)puzzleContainer
{
    return self.selectedImage.size;
}

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

#pragma mark - IBAction

- (IBAction)hintTouchDown:(id)sender
{
    self.originalImageView.hidden = NO;
}

- (IBAction)hintTouchUp:(id)sender
{
    self.originalImageView.hidden = YES;
}

- (IBAction)changeImage:(id)sender
{
    [self performSegueWithIdentifier:@"ImagePicker" sender:self];
}


@end
