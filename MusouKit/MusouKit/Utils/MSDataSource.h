//
//  MSDataSource.h
//  VGirl
//
//  Created by danal.luo on 3/1/14.
//  Copyright (c) 2014 danal. All rights reserved.
//
//  Data Source for a TableView

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MSDataRow;
@class MSDataSection;

@interface MSDataSource : NSObject{
     NSMutableArray *_sections;
}

- (NSArray *)sections;
- (NSInteger)sectionCount;
- (NSInteger)rowCountInSection:(NSInteger)sectionIndex;

/**
 * Clear data
 */
- (void)empty;

/**
 * Add one section
 */
- (MSDataSection *)addSection:(MSDataSection *)sect;

/**
 * Remove sections
 */
- (void)removeSections:(NSRange)range;

/**
 * Add one row to a section
 */
- (void)addRow:(id)object toSection:(MSDataSection *)sect;

/**
 * Retrieve a row object at rowIndex and in some section with sectionIndex
 */
- (id)rowAtIndex:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex;
- (id)rowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Retrieve a section
 */
- (id)sectionAtIndex:(NSInteger)sectionIndex;
- (id)sectionWithTag:(NSInteger)tag;
@end

/////////////////////////////////////////////////////////
@interface MSDataSection : NSObject {
    NSMutableArray *_rows;
}
@property (assign, nonatomic) NSInteger tag;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *icon;
@property (strong, nonatomic) id info;  //any info
@property (assign, nonatomic) float height;

- (NSArray *)rows;
- (NSInteger)rowCount;

- (void)addRow:(id)object;
- (void)addRows:(NSArray *)objects;

- (id)rowAtIndex:(NSInteger)rowIndex;

- (void)empty;

+ (MSDataSection *)sectionWithTitle:(NSString *)title tag:(NSInteger)tag;
@end

/////////////////////////////////////////////////////////
@interface MSDataRow : NSObject
@property (assign, nonatomic) NSInteger tag;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *detail;
@property (copy, nonatomic) NSString *icon;
@property (nonatomic) BOOL checked;
@property (strong, nonatomic) id info;  //any info
@property (assign, nonatomic) float rowHeight;

//Set info and return self
- (MSDataRow *)info:(id)info;

+ (MSDataRow *)rowWithTitle:(NSString *)title tag:(NSInteger)tag;
+ (MSDataRow *)rowWithTitle:(NSString *)title tag:(NSInteger)tag icon:(NSString *)icon;
@end
