//
//  SearchViewController.m
//  my Library
//
//  Created by Niklas Rose on 28/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import "SearchViewController.h"
#import "Book.h"

@interface SearchViewController()
    @property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation SearchViewController{
    NSArray *_myBooks;
    NSArray *_searchBooks;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self= [super initWithCoder:aDecoder];
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadBooks];
}

- (IBAction)searchButtonIsPressed:(id)sender {
 
    NSString *accessKey = @"XNN9RBOC";
    
    NSString *input = self.searchTextField.text;
    NSString *newString =[input stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *requestedURL=[NSString stringWithFormat:@"http://isbndb.com/api/v2/json/%@/books?q=%@", accessKey, newString];

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:requestedURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                //Here should be the data from jsonDict put into other NSDictionaries for example all Titles
                NSArray *title = [[jsonDict objectForKey:@"data"] valueForKey:@"title_latin"];
                NSArray *isbn = [[jsonDict objectForKey:@"data"] valueForKey:@"isbn13"];
                NSArray *author = [[[jsonDict objectForKey:@"data"] valueForKey:@"author_data"]valueForKey:@"name"];
                NSArray *booksNotFound = [jsonDict objectForKey:@"error"];
                            
                NSString* resultTitle = [title description];
                NSString* resultAuthor = [author description];
                            
                //Regex brackets
                NSCharacterSet *unwantedChars = [NSCharacterSet characterSetWithCharactersInString:@"()\n\""];
                //clear Strings from brackets
                NSString *requiredStringForTitle = [[resultTitle componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
                NSString *requiredStringForAuthor = [[resultAuthor componentsSeparatedByCharactersInSet:unwantedChars] componentsJoinedByString: @""];
                            
                NSString* resultAuthorNoWhitespaces = [requiredStringForAuthor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSLog(@"Title: %@", title);
                NSLog(@"ISBN: %@", isbn);
                NSLog(@"Author: %@", author);
                
            }] resume];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_searchBooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Book *books= _searchBooks[indexPath.row];
    NSLog(@"Buch: %@", books.title);
    cell.textLabel.text= books.title;
    if ([books.author  isEqual: @""]) {
        cell.detailTextLabel.text = @"Unknown Author";
    }else{
        cell.detailTextLabel.text= books.author;
    }
    
    return cell;
}

#pragma mark - Load & Storing of the books-array

- (NSURL*)libraryPath {
    NSFileManager *sharedFileManager= [NSFileManager defaultManager];
    NSArray *paths= [sharedFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsPath= paths[0];
    
    NSURL *filePath= [documentsPath URLByAppendingPathComponent:@"Library.plist"];
    
    return filePath;
}

- (NSArray*)writableRepo {
    NSMutableArray *writableArray= [NSMutableArray arrayWithCapacity:_myBooks.count];
    for( Book *books in _myBooks )
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
    NSMutableArray *bookArray = [NSMutableArray arrayWithCapacity:_myBooks.count+1];
    bookArray = (NSMutableArray*)_myBooks;
    [bookArray addObject:book];
    _myBooks = bookArray;
    [self storeBooks];
    [self loadBooks];
}

-(BOOL)isBookAlreadyInMyLibrary:(NSInteger)isbn{
    NSMutableArray* bookArray = [NSMutableArray arrayWithCapacity:_myBooks.count];
    
    bookArray = (NSMutableArray*)_myBooks;
    for( Book *books in _myBooks ){
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
        NSLog(@"Could not load books!");
        return;
    }
    
    _myBooks= [self booksFromDictionaryArray:dictionaryResult];
    NSLog(@"Books loaded");
}

- (void)storeBooks {
    NSURL *file= [self libraryPath];
    NSArray *writableArray= [self writableRepo];
    // Write addresses file
    BOOL success= [writableArray writeToURL:file atomically:YES];
    NSLog(@"%@", success ? @"Books written" : @"Error writing Books");
}


@end
