//
//  MyBooksViewController.m
//  my Library
//
//  Created by Niklas Rose on 26/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import "MyBooksViewController.h"
#import "BookDetailViewController.h"
#import "Book.h"


@implementation MyBooksViewController{
    NSArray *_books;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self= [super initWithCoder:aDecoder];
    if( self ) {
        //[self removeAllBooks];
        [self loadBooks];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if( self.tableView.indexPathForSelectedRow ) {
        [self.tableView reloadData];
        [self storeBooks];
    }
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

- (void)removeAllBooks{
    NSMutableArray* bookArray = [NSMutableArray arrayWithCapacity:_books.count];
    
    bookArray = (NSMutableArray*)_books;
    
    [bookArray removeAllObjects];
    
    _books = bookArray;
    
    [self storeBooks];
    [self loadBooks];
}


- (void)removeBook:(Book*)book{
    NSMutableArray* bookArray = [NSMutableArray arrayWithCapacity:_books.count];
    
    bookArray = (NSMutableArray*)_books;
    [bookArray removeObject:book];
    _books = bookArray;
    
    [self storeBooks];
    [self loadBooks];
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
    // Write books into file
    BOOL success= [writableArray writeToURL:file atomically:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Book *books= _books[indexPath.row];
    
    if(!books.isRemoved){
        cell.textLabel.text= books.title;
        if ([books.author  isEqual: @""]) {
            cell.detailTextLabel.text = @"Unknown Author";
        }else{
            cell.detailTextLabel.text= books.author;
        }
        return cell;
    }else{
        cell.textLabel.text = @"Book deleted";
        cell.detailTextLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self removeBook:books];
        return cell;
    }
}

#pragma mark - Segue Handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if( [segue.identifier isEqualToString:@"Show Book Details"] ) {
        BookDetailViewController *bookDetailViewController= segue.destinationViewController;
        bookDetailViewController.book= _books[self.tableView.indexPathForSelectedRow.row];
    }
}


@end
