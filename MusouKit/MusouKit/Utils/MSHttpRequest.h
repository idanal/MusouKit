//
//  MSHttpRequest.h
//  MusouKit - Extension for NSMutableURLRequest
//
//  Created by DANAL LUO on 2017/5/17.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (Musou)

/** Call it when Begin appending */
- (void)beginAppending;

/** Call it when End Appending */
- (void)endAppending;

/** Set content type, default set to multipart/form-data */
- (void)setContentType:(NSString *)contentType;

/** Set the whole body with data */
- (void)setBodyData:(NSData *)data;

#pragma mark - For Multipart form

/** Append a string or number */
- (void)appendFormValue:(id)val name:(NSString *)name;

/** Append data with param name */
- (void)appendFormData:(NSData *)data name:(NSString *)name;

/** Append file data with param name */
- (void)appendFileFormData:(NSData *)data name:(NSString *)name filename:(NSString *)filename;

@end
