//
//  Book.h
//  my Library
//
//  Created by Niklas Rose on 21/02/16.
//  Copyright © 2016 Niklas Rose. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, assign )NSInteger isbn;
@property (nonatomic, strong)NSString *author;
@property (nonatomic, strong)NSString *room;
@property (nonatomic, strong)NSString *bookshelf;
@property (readwrite, assign )NSInteger row;
@property (readwrite, assign )NSInteger position;
@property (readwrite, assign) BOOL isRemoved;

- (instancetype)initWithIsbn:(NSInteger)isbn Title:(NSString*)title Author:(NSString*)author Room:(NSString*)room Bookshelf:(NSString*)bookshelf Row:(NSInteger)row Position:(NSInteger)position;
- (NSString*) getTitle;
- (NSString*) getAuthor;
- (NSInteger) getIsbn;
- (NSDictionary*)writableRepresentation;
+ (Book*)booksFromDictionary:(NSDictionary*)dictionaryRepresentation;
- (NSString*)description;

@end
