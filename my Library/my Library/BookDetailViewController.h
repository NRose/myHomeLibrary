//
//  BookDetailViewController.h
//  my Library
//
//  Created by Niklas Rose on 26/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Book.h"

@interface BookDetailViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Book *book;

@end
