//
//  Book.m
//  my Library
//
//  Created by Niklas Rose on 21/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import "Book.h"

@implementation Book

- (instancetype)initWithIsbn:(NSInteger)isbn
                       Title:(NSString*)title
                      Author:(NSString*)author
                        Room:(NSString *)room
                   Bookshelf:(NSString *)bookshelf
                         Row:(NSInteger)row
                    Position:(NSInteger)position{
    self = [super init];
    
    if( self ) {
        self.title = title;
        self.author = author;
        self.isbn = isbn;
        self.room = room;
        self.bookshelf = bookshelf;
        self.row = row;
        self.position = position;
        self.isRemoved = NO;
    }
    
    return self;
}

- (NSDictionary*)writableRepresentation {
    NSMutableDictionary *writableRepresentation= [NSMutableDictionary dictionary];
    NSLog(@"ISBN: %lu", self.getIsbn);
    NSLog(@"Author: %@", self.getAuthor);
    NSLog(@"Title: %@", self.getTitle);
    [writableRepresentation setValue:[NSNumber numberWithInteger:(self.getIsbn)] forKey:@"ISBN"];
    [writableRepresentation setValue:self.getTitle forKey:@"Title"];
    [writableRepresentation setValue:self.getAuthor forKey:@"Author"];
    [writableRepresentation setValue:self.room forKey:@"Room"];
    [writableRepresentation setValue:self.bookshelf forKey:@"Bookshelf"];
    [writableRepresentation setValue:[NSNumber numberWithInteger:(self.row)]  forKey:@"Row"];
    [writableRepresentation setValue:[NSNumber numberWithInteger:(self.position)]  forKey:@"Position"];
    return writableRepresentation;
}

+ (Book*)booksFromDictionary:(NSDictionary*)dictionaryRepresentation {
    
    return [[Book alloc] initWithIsbn:[[dictionaryRepresentation objectForKey:@"ISBN"] integerValue]
                                Title:[dictionaryRepresentation valueForKey:@"Title"]
                               Author:[dictionaryRepresentation valueForKey:@"Author"]
                                Room:[dictionaryRepresentation valueForKey:@"Room"]
                                Bookshelf:[dictionaryRepresentation valueForKey:@"Bookshelf"]
                                  Row:[[dictionaryRepresentation objectForKey:@"Row"] integerValue]
                             Position:[[dictionaryRepresentation objectForKey:@"Position"] integerValue]];
}

- (NSString*)description{
    return [NSString stringWithFormat: @"Book: ISBN=%lu Title=%@ Author=%@", self.isbn, self.title, self.author];
}

//All Getter and Setters for Books at this Status


- (NSString*) getTitle{
    return self.title;
}

- (NSString*) getAuthor{
    return self.author;
}

- (NSInteger) getIsbn{
    return self.isbn;
}

@end
