//
//  MSDataSource.m
//  VGirl
//
//  Created by danal.luo on 3/1/14.
//  Copyright (c) 2014 danal. All rights reserved.
//

#import "MSDataSource.h"


@implementation MSDataSource

- (void)dealloc{
#if !__has_feature(objc_arc)
    [_sections release];
    [super dealloc];
#endif
}

- (id)init{
    self = [super init];
    if (self){
        _sections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)sections{
    return [NSArray arrayWithArray:_sections];
}

- (NSInteger)sectionCount{
    return [_sections count];
}

- (NSInteger)rowCountInSection:(NSInteger)sectionIndex{
    if (sectionIndex < [_sections count]){
        MSDataSection *sect = [_sections objectAtIndex:sectionIndex];
        return [sect rowCount];
    }
    return 0;
}

- (void)empty{
    [_sections removeAllObjects];
}

- (MSDataSection *)addSection:(MSDataSection *)sect{
    [_sections addObject:sect];
    return sect;
}

- (void)removeSections:(NSRange)range{
    [_sections removeObjectsInRange:range];
}

- (void)addRow:(id)object toSection:(MSDataSection *)sect{
    [sect addRow:object];
}

- (id)rowAtIndex:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex{
    MSDataSection *sect = [_sections objectAtIndex:sectionIndex];
    return [sect rowAtIndex:rowIndex];
}

- (id)rowAtIndexPath:(NSIndexPath *)indexPath{
    return [self rowAtIndex:indexPath.row inSection:indexPath.section];
}

- (id)sectionAtIndex:(NSInteger)sectionIndex{
    return _sections[sectionIndex];
}

- (id)sectionWithTag:(NSInteger)tag{
    for (MSDataSection *sect in _sections){
        if (sect.tag == tag) return sect;
    }
    return nil;
}

@end

/////////////////////////////////////////////////////////
@implementation MSDataSection

- (void)dealloc{
#if !__has_feature(objc_arc)
    [_icon release];
    [_rows release];
    [super dealloc];
#endif
}

- (id)init{
    self = [super init];
    if (self){
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)rows{
    return [NSArray arrayWithArray:_rows];
}

- (NSInteger)rowCount{
    return [_rows count];
}

- (void)addRow:(MSDataRow *)row{
    [_rows addObject:row];
}

- (void)addRows:(NSArray *)objects{
    [_rows addObjectsFromArray:objects];
}

- (id)rowAtIndex:(NSInteger)rowIndex{
    return [_rows objectAtIndex:rowIndex];
}

- (void)empty{
    [_rows removeAllObjects];
}

+ (MSDataSection *)sectionWithTitle:(NSString *)title tag:(NSInteger)tag{
    MSDataSection *sect = [[MSDataSection alloc] init];
    sect.title = title;
    sect.tag = tag;
#if !__has_feature(objc_arc)
    [sect autorelease];
#endif
    return sect;
}


@end

/////////////////////////////////////////////////////////
@implementation MSDataRow
- (void)dealloc{
    self.title = nil;
    self.icon = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

+ (MSDataRow *)rowWithTitle:(NSString *)title tag:(NSInteger)tag{
    MSDataRow *row = [[MSDataRow alloc] init];
    row.title = title;
    row.tag = tag;
#if !__has_feature(objc_arc)
    [row autorelease];
#endif
    return row;
}

+ (MSDataRow *)rowWithTitle:(NSString *)title tag:(NSInteger)tag icon:(NSString *)icon{
    MSDataRow *row = [self rowWithTitle:title tag:tag];
    row.icon = icon;
    return row;
}

- (MSDataRow *)info:(id)info{
    self.info = info;
    return self;
}

@end
