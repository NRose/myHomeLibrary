//
//  BarcodeScannerViewController.m
//  my Library
//
//  Created by Niklas Rose on 13/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import "BarcodeScannerViewController.h"
#import "MTBBarcodeScanner.h"
#import "Book.h"

@interface BarcodeScannerViewController () <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *toggleScanningButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *toggleTorchButton;

@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, assign) BOOL captureIsFrozen;
@property (nonatomic, assign) BOOL didShowCaptureWarning;
@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation BarcodeScannerViewController{
    NSArray *_books;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self= [super initWithCoder:aDecoder];
    
    return self;
}


#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [self.previewView addGestureRecognizer:tapGesture];
    [self loadBooks];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

#pragma mark - Scanner

- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}

- (void)handleReachabilityChange:(NSNotification *)note {
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSNumber *n = [theData objectForKey:@"isReachable"];
        BOOL isReachable = [n boolValue];
        NSLog(@"reachable: %d", isReachable);
    }
}

#pragma mark - Scanning

- (void)startScanning {
    self.uniqueCodes = [[NSMutableArray alloc] init];
    NSString *accessKey = @"XNN9RBOC";
   
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                NSString *isbn = code.stringValue;
                NSString *requestedURL=[NSString stringWithFormat:@"http://isbndb.com/api/v2/json/%@/book/%@", accessKey, isbn];
               
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithURL:[NSURL URLWithString:requestedURL]
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
                            // handle response
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                            
                            NSArray *title = [[jsonDict objectForKey:@"data"] valueForKey:@"title_latin"];
                            NSArray *author = [[[jsonDict objectForKey:@"data"] valueForKey:@"author_data"]valueForKey:@"name"];
                            NSArray *bookNotFound = [jsonDict objectForKey:@"error"];
                            
                            NSString* resultTitle = [title description];
                            NSString* resultAuthor = [author description];
                            
                            //Regex brackets
                            NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"()\n\""];
                            //clear Strings from brackets
                            NSString *requiredStringForTitle = [[resultTitle componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
                            NSString *requiredStringForAuthor = [[resultAuthor componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
                            
                            NSString* resultAuthorNoWhitespaces = [requiredStringForAuthor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                            if (bookNotFound == nil) {
                                
                                NSInteger isbn = [code.stringValue integerValue];
                                if(![self isBookAlreadyInMyLibrary:isbn]){
                                    //saving the book in library
                                    Book* newBook = [[Book alloc] initWithIsbn: isbn
                                                                     Title:requiredStringForTitle
                                                                    Author:resultAuthorNoWhitespaces
                                                                    Room:@""
                                                                    Bookshelf:@"" Row:1 Position:1];
                                
                                    [self addBookObject:newBook];
                                }
                                else
                                {
                                    //later put NSNotification in here
                                     NSLog(@"Book is already in your Library!");
                                }
                            }else{
                                //later put NSNotification in here
                                NSLog(@"ERROR: %@", bookNotFound);
                            }
                        }] resume];
  
                [self.uniqueCodes addObject:code.stringValue];
                
                // Update the tableview
                [self.tableView reloadData];
                [self scrollToLastTableViewCell];
            }
        }
    }];
    
    [self.toggleScanningButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
    self.toggleScanningButton.backgroundColor = [UIColor redColor];
}

- (void)stopScanning {
    [self.scanner stopScanning];
    
    [self.toggleScanningButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
    self.toggleScanningButton.backgroundColor = self.view.tintColor;
    
    self.captureIsFrozen = NO;
}

#pragma mark - Actions

- (IBAction)toggleScanningTapped:(id)sender {
    if ([self.scanner isScanning] || self.captureIsFrozen) {
        [self stopScanning];
    } else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self startScanning];
            } else {
                [self displayPermissionMissingAlert];
            }
        }];
    }
}

- (void)backTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"BarcodeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.text = self.uniqueCodes[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uniqueCodes.count;
}

#pragma mark - Helper Methods

- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have permission to use the camera.";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

- (void)scrollToLastTableViewCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.uniqueCodes.count - 1
                                                inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

#pragma mark - Gesture Handlers

- (void)previewTapped {
    if (![self.scanner isScanning] && !self.captureIsFrozen) {
        return;
    }
    
    if (!self.didShowCaptureWarning) {
        [[[UIAlertView alloc] initWithTitle:@"Capture Frozen"
                                    message:@"The capture is now frozen. Tap the preview again to unfreeze."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        self.didShowCaptureWarning = YES;
    }
    
    if (self.captureIsFrozen) {
        [self.scanner unfreezeCapture];
    } else {
        [self.scanner freezeCapture];
    }
    
    self.captureIsFrozen = !self.captureIsFrozen;
}

#pragma mark - Setters

- (void)setUniqueCodes:(NSMutableArray *)uniqueCodes {
    _uniqueCodes = uniqueCodes;
    [self.tableView reloadData];
}

#pragma mark - Load & Storing of the books-array

- (NSURL*)libraryPath {
    NSFileManager *sharedFileManager= [NSFileManager defaultManager];
    NSArray *paths= [sharedFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsPath= paths[0];
    
    NSURL *filePath= [documentsPath URLByAppendingPathComponent:@"Library.plist"];
    
    return filePath;
}

- (NSArray*)writableRepresentation {
    NSMutableArray *writableArray= [NSMutableArray arrayWithCapacity:_books.count];
    for( Book *books in _books )
        [writableArray addObject:[books writableRepresentation]];

    return writableArray;
}

- (NSArray*)booksFromDictionaryArray:(NSArray*)dictionaryArray {
    NSMutableArray *books= [NSMutableArray arrayWithCapacity:dictionaryArray.count];
    
    for( NSDictionary *dict in dictionaryArray )
        [books addObject:[Book booksFromDictionary:dict]];
    
    return books;
}

- (void)addBookObject:(Book *)book{
    [self loadBooks];
    NSMutableArray *bookArray = [NSMutableArray arrayWithCapacity:_books.count+1];
    bookArray = (NSMutableArray*)_books;
    [bookArray addObject:book];
    _books = bookArray;
    [self storeBooks];
    [self loadBooks];
}

-(BOOL)isBookAlreadyInMyLibrary:(NSInteger)isbn{
    NSMutableArray* bookArray = [NSMutableArray arrayWithCapacity:_books.count];
    
    bookArray = (NSMutableArray*)_books;
    for( Book *books in _books ){
        if(books.isbn == isbn){
            return YES;
        }
    }
    return NO;
}

- (void)loadBooks {
    NSURL *file= [self libraryPath];
    
    NSArray *dictionaryResult= [NSArray arrayWithContentsOfURL:file];
    
    if( !dictionaryResult ) {
        return;
    }
    _books= [self booksFromDictionaryArray:dictionaryResult];
}

- (void)storeBooks {
    NSURL *file= [self libraryPath];
    NSArray *writableArray= [self writableRepresentation];
    // Write books in file
    BOOL success= [writableArray writeToURL:file atomically:YES];
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if (error) {
        NSLog(@"Connection Error: %@", error);
    }
}

@end
