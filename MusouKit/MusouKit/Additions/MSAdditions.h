//
//  MSUINavigationController+Additions.h
//  MusouKit
//
//  Created by danal on 13-4-8.
//  Copyright (c) 2013年 danal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSBundle (Musou)

+ (BOOL)isNewVersion:(NSString *)appVersion;
+ (NSString *)appVersion;
+ (NSNumber *)buildNumber;

@end

@interface NSFileManager (Musou)

+ (void)clearDirectory:(NSString *)dirPath complete:(void(^)(void))block;

+ (NSString *)documentsDirectory;
+ (NSString *)cachesDirectory;
+ (NSString *)pathInDocuments:(NSString *)file;
+ (NSString *)pathInCaches:(NSString *)file;

@end

@interface NSDate (Musou)

+ (NSDate *)localDate;
+ (NSDateFormatter *)localDateFormatter;

@end


@interface NSObject (Musou)
@property (nonatomic, strong) id attachment;

/**
 * Invoke a method
 * @param object A sender object
 */
- (void)invokeMethod:(SEL)selector object:(id)object;

//Value
/** The object should not contain scalar vars such as int,bool */
- (void)copyValueTo:(id)anotherObj;

//Coding
- (void)decode:(NSCoder *)aDecoder;
- (void)encode:(NSCoder *)aCoder;
@end


@interface NSString (Musou)

- (NSString *)stringValue;
- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)base64;

/** 
 * Estimate the size of the string with attributes
 * @param size Constrained size
 * @param attrs Text attributes. e.g {NSFontAttributeName:font}
 * @return The real size
 */
- (CGSize)limitToSize:(CGSize)size attrs:(NSDictionary *)attrs;
/** Simple method */
- (CGSize)limitToSize:(CGSize)size font:(UIFont *)font;

+ (NSString *)UUID:(NSString *)uuidIdentifier;
+ (NSStringEncoding)GBKEncoding;
+ (NSString *)SSS:(NSString *)s1,...;
+ (NSString *)getFileMD5Hash:(NSString *)filePath;

+ (void)setupLanguageBundle;
+ (NSString *)languageIdentifier;
+ (void)setLanguageIdentifier:(NSString *)lang;
+ (NSString *)localized:(NSString *)key;

@end


//Compat for JSON/Dict parse
@interface NSNull (Musou)

- (NSUInteger)length;
- (NSString *)stringValue;

- (int)intValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;

- (long)longValue;
- (long long)longLongValue;

- (float)floatValue;
- (double)doubleValue;

- (BOOL)boolValue;

//Dict
- (id)objectForKey:(id)key;
//Array
- (id)objectAtIndex:(NSUInteger)idx;

@end


@interface NSNumber (Musou)

- (NSUInteger)length;

@end


@interface NSData (Musou)

- (NSString *)md5;
- (NSString *)sha1;
- (NSData*)AES256Encrypt:(NSString *)key;
- (NSData*)AES256Decrypt:(NSString *)key;
- (NSData *)encryptRSAWithPublicKey:(SecKeyRef)publicKey maxPlainLen:(size_t)maxPlainLen;

+ (SecKeyRef)getPublicKey:(NSString *)certificatePath;

@end


@interface NSLayoutConstraint (Musou)
+ (NSString *)attributeName:(NSLayoutAttribute)attr;
@end


#pragma mark - UI Additions

@interface UIControl (Musou)
//Set a target action
@property (nonatomic, copy) void (^onTouchUpInside)(id sender);
@end


@interface UIView (Musou)

//Set a tap gesture
@property (nonatomic, copy) void (^onTapAction)(id sender);

//Constraints to fit parent
- (void)fitParent;
- (void)fitParentEdge:(UIEdgeInsets)edge;

//Render
+ (UIImage *)renderToImage:(UIView *)view;

//Nib
+ (NSString *)nibFile;
+ (instancetype)loadFromNib;
+ (instancetype)loadFromNib:(NSString *)nibFile;

//Coordinate
+ (CGRect)convertViewFrame:(UIView *)view toSuperview:(UIView *)superview;

@end


@interface UITextView (Musou)

- (void)setPlaceholder:(NSString *)placeholder;
- (NSString *)placeholder;
- (void)didTextChange;
- (BOOL)shouldEndOnReturn:(NSString *)replaceText;

@end


@interface UIColor (Musou)

+ (UIColor *)rgb:(NSString *)rgbHex;
+ (UIColor *)randomColor;
+ (UIColor *)skyblueColor;
+ (UIColor *)fashionRed;
+ (UIColor *)fashionGreen;
+ (UIColor *)fashionBlue;
+ (UIColor *)fashionPink;
+ (UIColor *)fashionOrange;
+ (UIColor *)fashionPurple;
+ (UIColor *)fashionCyan;
+ (UIColor *)seperatorColor;    //C8C7CC

//Create an image with the color
+ (UIImage *)imageWithColor:(UIColor *)c;
//Create an circle image
+ (UIImage *)circleImageWithColor:(UIColor *)c size:(CGFloat)size border:(CGFloat)border;

@end


@interface UIDevice (Musou)

+ (BOOL)iOS7;
+ (BOOL)isPad;
+ (BOOL)isJailbroken;
+ (void)playVibrate;
+ (void)playEffect:(NSString *)soundFile;

+ (NSString *)buildVersion;
+ (NSString *)appVersion;
+ (NSString *)deviceModel;  //e.g. iPhone5,1
+ (NSString *)getUUID:(NSString *)identifier;      //获取UUID
+ (NSString *)systemLanguage;
@end


@interface UIApplication (Musou)
+ (double)currentTimestamp;
+ (double)machTimeToSecs:(uint64_t)time;

//Register remote notification
- (void)registerApns;

//Convert deviceToken to String
- (NSString *)handleDeviceToken:(NSData *)deviceToken;

//Simulate a apns alert
- (void)showNotificationWithView:(UIView *)contentView;

@end


@interface UIImage (Musou)

- (UIImage *)clipsToRect:(CGRect)rect;
- (UIImage *)scaleToSize:(CGSize)newSize;
- (UIImage *)scaleByFactor:(float)scaleBy;

//Change color
- (UIImage *)tint:(UIColor *)color;

@end


@interface UIImage (Rotation)
- (UIImage *)rotateBy90WH;
- (UIImage *)rotateBy90;
- (UIImage *)rotateBy180;
- (UIImage *)rotateBy270;
- (UIImage *)flipX;
- (UIImage *)flipY;

@end


//CGContext
typedef enum {
    kRounderCornerPostionAll = 0,
    kRounderCornerPostionTop,
    kRounderCornerPostionLeft,
    kRounderCornerPostionBottom,
    kRounderCornerPostionRight,
} RounedCornerPosition;

void CGAddRoundedCornerPath(CGRect rect, float corner, RounedCornerPosition position, CGContextRef c);

void CGDrawLinearGradient(NSArray *cgColors, CGPoint start, CGPoint end, CGContextRef c);

