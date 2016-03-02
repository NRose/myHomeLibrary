//
//  BookDetailViewController.m
//  my Library
//
//  Created by Niklas Rose on 26/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import "BookDetailViewController.h"
#import "MyBooksViewController.h"

@interface BookDetailViewController ()
    @property (weak,nonatomic) IBOutlet UILabel *titleLabel;
    @property (weak,nonatomic) IBOutlet UILabel *authorLabel;
    @property (weak,nonatomic) IBOutlet UILabel *rowSliderLabel;
    @property (weak,nonatomic) IBOutlet UILabel *positionSliderLabel;
    @property (weak, nonatomic) IBOutlet UITextField *roomTextField;
    @property (weak, nonatomic) IBOutlet UITextField *bookshelfTextField;
    @property (weak, nonatomic) IBOutlet UISlider *rowSlider;
    @property (weak, nonatomic) IBOutlet UISlider *positionSlider;

@end

@implementation BookDetailViewController{
    BOOL bookIsRemoved;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize Data
    bookIsRemoved = NO;
    self.roomTextField.delegate= self;
    self.bookshelfTextField.delegate= self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.titleLabel.text= self.book.title;
    self.authorLabel.text= self.book.author;
    self.roomTextField.text = self.book.room;
    self.bookshelfTextField.text = self.book.bookshelf;
    self.rowSlider.value = self.book.row;
    self.positionSlider.value = self.book.position;
    self.rowSliderLabel.text = [NSString stringWithFormat:@"%lu",self.book.row];
    self.positionSliderLabel.text = [NSString stringWithFormat:@"%lu",self.book.position];
}

- (void)viewWillDisappear:(BOOL)animated {
    if(!bookIsRemoved){
        // Update Book-Information
        self.book.room= self.roomTextField.text;
        self.book.bookshelf= self.bookshelfTextField.text;
        self.book.row = [self.rowSliderLabel.text integerValue];
        self.book.position = [self.positionSliderLabel.text integerValue];
    }
    else{
        self.book.isRemoved = YES;
    }
}

- (IBAction)buttonRemoveIsClicked:(id)sender{
    bookIsRemoved = YES;
}

- (IBAction)rowSliderValueChanged:(id)sender {
    int rowNumber = (int)[self.rowSlider value];
    NSString *rowStrFromInt = [NSString stringWithFormat:@"%d",rowNumber];
    // Set the label text to the value of the slider as it changes
    self.rowSliderLabel.text = rowStrFromInt;
}

- (IBAction)positionSliderValueChanged:(id)sender {
    int positionNumber = (int)[self.positionSlider value];
    NSString *positionStrFromInt = [NSString stringWithFormat:@"%d",positionNumber];
    // Set the label text to the value of the slider as it changes
    self.positionSliderLabel.text = positionStrFromInt;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
