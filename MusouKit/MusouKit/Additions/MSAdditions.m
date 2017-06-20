//
//  MSUINavigationController+Additions.m
//  MusouKit
//
//  Created by danal on 13-4-8.
//  Copyright (c) 2013年 danal. All rights reserved.
//

#import "MSAdditions.h"
#import <objc/runtime.h>
#import "sys/utsname.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation NSBundle (Musou)

+ (BOOL)isNewVersion:(NSString *)appVersion{
    if (appVersion == nil){
        return NO;
    }
    return [[self appVersion] compare:appVersion] == NSOrderedAscending;
}

+ (NSString *)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSNumber *)buildNumber{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end


@implementation NSFileManager (Musou)

+ (void)clearDirectory:(NSString *)dirPath complete:(void (^)(void))block{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *subpaths = [fm subpathsAtPath:dirPath];
    for (NSString *f in subpaths) {
        [fm removeItemAtPath:[dirPath stringByAppendingPathComponent:f] error:nil];
    }
    if (block != NULL) {
        block();
    }
}

+ (NSString *)documentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)pathInDocuments:(NSString *)file{
    return [[self documentsDirectory] stringByAppendingPathComponent:file];
}

+ (NSString *)pathInCaches:(NSString *)file{
    return [[self cachesDirectory] stringByAppendingPathComponent:file];
}

@end

@implementation NSDate (Musou)

+ (NSDate *)localDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate = [date  dateByAddingTimeInterval: interval];
    return localDate;
}

static NSDateFormatter *_localDF = nil;
+ (NSDateFormatter *)localDateFormatter{
    if (_localDF == nil){
        _localDF = [[NSDateFormatter alloc] init];
        _localDF.dateFormat = @"yyyy-MM-dd HH:mm:ss z";
    }
    return _localDF;
}

@end


@implementation NSObject (Musou)

- (void)invokeMethod:(SEL)selector object:(id)object{
    NSMethodSignature *sign = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    if (object != nil){
        id ptr = object;
        [invocation setArgument:&ptr atIndex:2];
    }
    [invocation invoke];
}

static NSString * const s_attachment = @"attachment";

- (id)attachment{
    return objc_getAssociatedObject(self, &s_attachment);
}

- (void)setAttachment:(id)attachment{
    objc_setAssociatedObject(self, &s_attachment, attachment, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)copyValueTo:(id)anotherObj{
    Class cls = self.class;
    do {
        unsigned int count = 0;
        const char *type = NULL;
        Ivar *vars = class_copyIvarList(cls, &count);
        for (unsigned i = 0; i < count; i++){
            Ivar v = vars[i];
            type = ivar_getTypeEncoding(v);
            if ([@(type) hasPrefix:@"@"]){ //object_setIvar only accepts OC types
                object_setIvar(anotherObj, v, object_getIvar(self, v));
            } else {
                NSLog(@"copytValueTo %@: cannot copy scalar variable '%s'", self.class, ivar_getName(v));
            }
        }
        free(vars);
        cls = class_getSuperclass(cls);
        
    } while (![NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])]);
    
}

//Coding
- (void)decode:(NSCoder *)aDecoder{
    Class cls = self.class;
    do {
        unsigned int count = 0;
        const char *type = NULL;
        const char *name = NULL;
        Ivar *vars = class_copyIvarList(cls, &count);
        for (unsigned i = 0; i < count; i++){
            Ivar v = vars[i];
            type = ivar_getTypeEncoding(v);
            name = ivar_getName(v);
            if ([@(type) hasPrefix:@"@"]){ //object_setIvar only accepts OC types
                object_setIvar(self, v, [aDecoder decodeObjectForKey:@(name)]);
            } else {
                NSLog(@"decode %@: cannot decode scalar variable '%s'", self.class, name);
            }
        }
        free(vars);
        cls = class_getSuperclass(cls);
        
    } while (![NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])]);
    
}

- (void)encode:(NSCoder *)aCoder{
    Class cls = self.class;
    do {
        unsigned int count = 0;
        const char *type = NULL;
        const char *name = NULL;
        Ivar *vars = class_copyIvarList(cls, &count);
        for (unsigned i = 0; i < count; i++){
            Ivar v = vars[i];
            type = ivar_getTypeEncoding(v);
            name = ivar_getName(v);
            if ([@(type) hasPrefix:@"@"]){ //object_setIvar only accepts OC types
                [aCoder encodeObject:object_getIvar(self, v) forKey:@(name)];
            } else {
                NSLog(@"encode %@: cannot encode scalar variable '%s'", self.class, name);
            }
        }
        free(vars);
        cls = class_getSuperclass(cls);
        
    } while (![NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])]);
    
}

@end


@implementation NSString (Musou)

- (NSString *)stringValue{
    return self;
}

- (NSString *)md5{
    return [self dataUsingEncoding:NSUTF8StringEncoding].md5;
}

- (NSString *)sha1{
    return [self dataUsingEncoding:NSUTF8StringEncoding].sha1;
}

- (NSString *)base64{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

- (CGSize)limitToSize:(CGSize)size attrs:(NSDictionary *)attrs{
    CGRect rect =
    [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil];
    return CGSizeMake(ceil(rect.size.width), ceil(rect.size.height));
}

- (CGSize)limitToSize:(CGSize)size font:(UIFont *)font{
    return [self limitToSize:size attrs:@{NSFontAttributeName: font}];
}

+ (NSStringEncoding)GBKEncoding{
    NSStringEncoding encoding =
    CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return encoding;
}

+ (NSString *)SSS:(NSString *)s1,...{
    NSMutableString *str = [NSMutableString string];
    NSString *s = s1;
    if (s != nil){
        [str appendString:s];
    }
    
    va_list ap;
    va_start(ap, s1);
    while ((s = va_arg(ap, NSString *))) {
        [str appendFormat:@"%@",s];
    }
    va_end(ap);
    return str;
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL) goto done;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) goto done;
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = 1024*8;   // FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed) goto done;
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    
    
done:
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

+ (NSString *)getFileMD5Hash:(NSString *)filePath{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, 0);
}

static NSBundle *_langBundle = nil;

+ (void)setupLanguageBundle{
    NSString *path = [[NSBundle mainBundle] pathForResource:[self languageIdentifier] ofType:@"lproj"];
    _langBundle = [NSBundle bundleWithPath:path];
}

+ (NSString *)languageIdentifier{
    return @"zh-Hant";
//    NSString *lang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
//    return lang;
}

+ (void)setLanguageIdentifier:(NSString *)lang{
    [[NSUserDefaults standardUserDefaults] setValue:@[lang] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"];
    _langBundle = [NSBundle bundleWithPath:path];
}

+ (NSString *)localized:(NSString *)key{
    //    return NSLocalizedString(key, nil);
    if (_langBundle == nil){
        [self setLanguageIdentifier:@"zh-Hant"];
    }
    return [_langBundle localizedStringForKey:key value:nil table:nil];
}

@end


@implementation NSNull (Musou)

- (NSUInteger)length{
    return 0;
}

- (NSString *)stringValue{
    return nil;
}

- (NSInteger)integerValue{
    return 0;
}

- (NSUInteger)unsignedIntegerValue{
    return 0;
}

- (int)intValue{
    return 0;
}

- (float)floatValue{
    return 0.f;
}

- (double)doubleValue{
    return 0.0;
}

- (long)longValue{
    return 0;
}

- (long long)longLongValue{
    return 0;
}

- (BOOL)boolValue{
    return NO;
}

- (id)objectForKey:(id)key{
    return nil;
}

- (id)objectAtIndex:(NSUInteger)idx{
    return nil;
}

@end


@implementation NSNumber (Musou)

- (NSUInteger)length{
    return 0;
}

@end

@implementation NSUserDefaults (Musou)

+ (id)objectForKey:(id)key defalutValue:(id)defalutVal{
    id val = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return val != nil ? val : defalutVal;
}

+ (NSMutableDictionary *)udcfg{
    NSDictionary *d = [[NSUserDefaults standardUserDefaults] objectForKey:@"udcfg"];
    if (d){
        return [NSMutableDictionary dictionaryWithDictionary:d];
    }
    return [NSMutableDictionary dictionary];
}

+ (void)saveCfg:(NSDictionary *)udcfg{
    [[NSUserDefaults standardUserDefaults] setObject:udcfg forKey:@"udcfg"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation NSLayoutConstraint (Musou)

+ (NSString *)attributeName:(NSLayoutAttribute)attr{
    NSString *name = nil;
    switch (attr) {
        case NSLayoutAttributeLeft: //1
            name = @"Left";
            break;
        case NSLayoutAttributeRight:
            name = @"Right";
            break;
        case NSLayoutAttributeTop:
            name = @"Top";
            break;
        case NSLayoutAttributeBottom:
            name = @"Bottom";
            break;
        case NSLayoutAttributeLeading:
            name = @"Leading";
            break;
        case NSLayoutAttributeTrailing:
            name = @"Trailing";
            break;
        case NSLayoutAttributeWidth:
            name = @"Width";
            break;
        case NSLayoutAttributeHeight:
            name = @"Height";
            break;
        case NSLayoutAttributeCenterX:
            name = @"CenterX";
            break;
        case NSLayoutAttributeCenterY:
            name = @"CenterY";
            break;
        case NSLayoutAttributeBaseline:
            name = @"Baseline";
            break;
        default:
            break;
    }
    return name;
}

@end

@implementation UIControl (Musou)

static NSString * const s_touchUpInside = @"touchUpInside";

- (void)setOnTouchUpInside:(void (^)(id))onTouchUpInside{
    objc_setAssociatedObject(self, &s_touchUpInside, onTouchUpInside, OBJC_ASSOCIATION_COPY);
    [self addTarget:self action:@selector(_onClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void (^)(id))onTouchUpInside{
    return objc_getAssociatedObject(self, &s_touchUpInside);
}

- (void)_onClick{
    self.onTouchUpInside(self);
}

@end


@implementation UIView (Musou)

static NSString * const s_tapGesture = @"tapGesture";

- (void)_onTap{
    self.onTapAction(self);
}

- (void)setOnTapAction:(void (^)(id))onTapAction{
    objc_setAssociatedObject(self, &s_tapGesture, onTapAction, OBJC_ASSOCIATION_COPY);
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &s_tapGesture);
    if (!tap){
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onTap)];
        [self addGestureRecognizer:tap];
        objc_setAssociatedObject(self, &s_tapGesture, tap, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void (^)(id))onTapAction{
    return objc_getAssociatedObject(self, &s_tapGesture);
}

- (void)fitParent{
    [self fitParentEdge:UIEdgeInsetsZero];
}

- (void)fitParentEdge:(UIEdgeInsets)edge{
    UIView *view = self;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = @{@"t":@(edge.top),@"l":@(edge.left),@"b":@(edge.bottom),@"r":@(edge.right)};
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-t-[view]-b-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-l-[view]-r-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
}

+ (UIImage *)renderToImage:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:c];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSString *)nibFile{
    return nil;
}

+ (instancetype)loadFromNib{
    NSString *nibFile = [self nibFile];
    if (nibFile){
        return [self loadFromNib:nibFile];
    } else {
        return [self loadFromNib:NSStringFromClass([self class])];
    }
}

+ (instancetype)loadFromNib:(NSString *)nibFile{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:nibFile owner:nil options:nil];
    for (UIView *v in views){
//        if ([v isKindOfClass:[self class]]){
        if ([NSStringFromClass(v.class) isEqualToString:NSStringFromClass([self class])]){
            return v;
        }
    }
    return nil;
}

+ (CGRect)convertViewFrame:(UIView *)view toSuperview:(UIView *)superview{
    CGRect rect = view.frame;
    UIView *v = view.superview;
    while (v != superview) {
        rect.origin.x += v.frame.origin.x;
        rect.origin.y += v.frame.origin.y;
        v = v.superview;
    }
    return rect;
}

@end



@implementation UITextView (Musou)

- (void)setPlaceholder:(NSString *)placeholder{
    UITextView *pv = (id)[self viewWithTag:0x100];
    if (!pv){
        pv = [[UITextView alloc] initWithFrame:self.bounds];
        pv.tag = 0x100;
        pv.editable = NO;
        pv.userInteractionEnabled = NO;
        pv.font = self.font;
        pv.textAlignment = self.textAlignment;
        pv.textColor = [UIColor lightGrayColor];
        pv.backgroundColor = [UIColor clearColor];
        [self addSubview:pv];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didTextChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:nil];
        
    }
    pv.text = placeholder;
}

- (NSString *)placeholder{
    return self.placeholderView.text;
}

- (UITextView *)placeholderView{
    return (UITextView *)[self viewWithTag:0x100];
}

- (void)didTextChange{
    self.placeholderView.hidden = [self hasText];
    if (self.text.length > 0){
        unichar ch = [self.text characterAtIndex:self.text.length-1];
        if (ch == '\n'){
            [self resignFirstResponder];
            self.text = [self.text substringToIndex:self.text.length-1];
        }
    }
}

- (void)removePlaceholderObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation UIColor (Musou)

+ (UIColor *)rgb:(NSString *)rgbHex{
    unsigned int r = 0, g = 0, b = 0;
    NSInteger length = [rgbHex length];
    if (length%3 == 1) {        //With # prefix
        rgbHex = [rgbHex substringFromIndex:1];
        length = [rgbHex length];
    }
    NSInteger segment = length/3;
    if (length == 6 || length == 3) {          //EFEFEF | CCC
        NSScanner *scanner = nil;
        NSString *s = [rgbHex substringWithRange:NSMakeRange(0, segment)];
        scanner = [NSScanner scannerWithString:s];
        [scanner scanHexInt:&r];
        s = [rgbHex substringWithRange:NSMakeRange(segment, segment)];
        scanner = [NSScanner scannerWithString:s];
        [scanner scanHexInt:&g];
        s = [rgbHex substringWithRange:NSMakeRange(segment*2, segment)];
        scanner = [NSScanner scannerWithString:s];
        [scanner scanHexInt:&b];
    }
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
}

+ (UIColor *)randomColor{
    NSInteger r,g,b;
    r = arc4random()%255;
    g = arc4random()%255;
    b = arc4random()%255;
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
}

+ (UIColor *)skyblueColor{
    return [UIColor colorWithRed:0/255.f green:158/255.f blue:230/255.f alpha:1.f];
}

+ (UIColor *)fashionRed{
    return [UIColor colorWithRed:252/255.f green:42/255.f blue:29/255.f alpha:1.f];
}

+ (UIColor *)fashionGreen{
    return [UIColor colorWithRed:40/255.f green:247/255.f blue:45/255.f alpha:1.f];
}

+ (UIColor *)fashionBlue{
    return [UIColor colorWithRed:25/255.f green:153/255.f blue:252/255.f alpha:1.f];
}

+ (UIColor *)fashionPink{
    return [UIColor colorWithRed:253/255.f green:80/255.f blue:250/255.f alpha:1.f];
}

+ (UIColor *)fashionOrange{
     return [UIColor colorWithRed:253/255.f green:146/255.f blue:36/255.f alpha:1.f];
}

+ (UIColor *)fashionRedColor{
    return [UIColor colorWithRed:223/255.f green:72/255.f blue:61/255.f alpha:1.f];
}

+ (UIColor *)fashionPurple{
    return [UIColor colorWithRed:200/255.f green:158/255.f blue:231/255.f alpha:1.f];
}

+ (UIColor *)fashionCyan{
    return [UIColor colorWithRed:0/255.f green:158/255.f blue:200/255.f alpha:1.f]; 
}

+ (UIColor *)seperatorColor{
    return [UIColor colorWithRed:200/255.f green:199/255.f blue:204/255.f alpha:1.f];
}

+ (UIImage *)imageWithColor:(UIColor *)c{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, c.CGColor);
    CGContextFillRect(ctx, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)circleImageWithColor:(UIColor *)c size:(CGFloat)size border:(CGFloat)border{
    
    CGFloat radius = size/2 - border/2;
    
    CGRect rect = CGRectMake(0, 0, size, size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineWidth(ctx, border);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextFillRect(ctx, rect);
    CGContextAddArc(ctx, size/2, size/2, radius, 0, M_PI*2, 0);
    CGContextSetStrokeColorWithColor(ctx, c.CGColor);
    CGContextStrokePath(ctx);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, size/2, 0, size/2)];
}

@end

#import <AudioToolbox/AudioToolbox.h>
@implementation UIDevice (Musou)

+ (BOOL)iOS7{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f;
}

+ (BOOL)isPad{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isJailbroken {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (void)playVibrate{
    SystemSoundID soundID = kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(soundID);
}

+ (void)playEffect:(NSString *)soundFile{
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:soundFile ofType:nil];  //caf,wav
    CFStringRef strRef = CFStringCreateWithCString(NULL, [path cStringUsingEncoding:NSUTF8StringEncoding], kCFStringEncodingUTF8);
    CFURLRef fileURL = CFURLCreateWithString(NULL, strRef, NULL);
    AudioServicesCreateSystemSoundID(fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
    CFRelease(strRef);
    CFRelease(fileURL);
}

+ (NSString *)getUUID:(NSString *)identifier{
    //name = @"public.utf8-plain-text";
    UIPasteboard *pb = [UIPasteboard pasteboardWithName:identifier create:YES];
    if ([pb string]){
        return [pb string];
    } else {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
        NSString *result = [NSString stringWithFormat:@"%@", uuidString];
        CFRelease(uuid);
        CFRelease(uuidString);
        
        [pb setString:result];
        return result;
    }
}

+ (NSString *)deviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)buildVersion{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [appInfo objectForKey:@"CFBundleVersion"];
}

+ (NSString *)appVersion{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [appInfo objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)systemLanguage{
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return [languages firstObject];
}

@end

#import <sys/time.h>
#import <mach/mach_time.h>
@implementation UIApplication (Musou)

+ (double)currentTimestamp{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return (tv.tv_sec * 1000. + tv.tv_usec / 1000.);
}

+ (double)machTimeToSecs:(uint64_t)time{
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    return (double)time * (double)timebase.numer /
    (double)timebase.denom /1e9;
}

- (void)registerApns{
    if ([self respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [self registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [self registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [self registerForRemoteNotificationTypes:notificationTypes];
    }
    
}

- (NSString *)handleDeviceToken:(NSData *)deviceToken{
    NSString *token = [NSString stringWithFormat:@"%@",deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"[ <>]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [token length])];
    return token;
}

- (void)showNotificationWithView:(UIView *)contentView{
    UIView *v = contentView;   //contentView could not be a window
    
    UIView *parent = [[[UIApplication sharedApplication] delegate] window];
    [parent addSubview:v];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    //parent.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat h = v.bounds.size.height;
    CGFloat w = MIN(parent.bounds.size.width, parent.bounds.size.height);
    
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:w]];
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:h]];
    
    [parent addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:v attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeTop multiplier:1.0 constant:-h];
    [parent addConstraint:top];
    
    [parent layoutIfNeeded];
    
    //Animation
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         top.constant = 20;
                         [parent layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2 delay:1 options:0 animations:^{
                             v.alpha = 0;
                         } completion:^(BOOL finished) {
                             [v removeFromSuperview];
                         }];
                         
                     }];
}

@end


@implementation UIImage (Musou)

- (UIImage *)clipsToRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextDrawImage(ctx, CGRectMake(rect.origin.x, rect.origin.y, self.size.width, self.size.height), self.CGImage);
    CGContextClipToRect(ctx, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)scaleToSize:(CGSize)newSize {
    float max = MAX(self.size.width, self.size.height);
    if (max > MAX(newSize.width, newSize.height)) {
        float factor = MAX(newSize.width,newSize.height)/max;
        return [self scaleByFactor:factor];
    }
    return self;
}

- (UIImage *)scaleByFactor:(float)scaleBy {
    UIImage *image = self;
    CGSize size = CGSizeMake((NSInteger)(image.size.width * scaleBy), (NSInteger)(image.size.height * scaleBy));
    
    UIGraphicsBeginImageContext(size);
//    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scaleBy, scaleBy);
    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (UIImage *)tint:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(ctx, 0, rect.size.height);
    //CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextClipToMask(ctx, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(ctx, rect);
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

- (UIImage *)withCorner:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

@end


@implementation UIImage (Rotation)

- (UIImage *)rotateBy90WH{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, size.width, 0);
    CGContextRotateCTM(ctx, M_PI_2);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.height,size.width), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)rotateBy90{
    CGSize size = CGSizeMake(self.size.height, self.size.width);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, size.width, 0);
    CGContextRotateCTM(ctx, M_PI_2);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.height,size.width), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)rotateBy180{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, size.width, size.height);
    CGContextRotateCTM(ctx, M_PI);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.width,size.height), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)rotateBy270{
    CGSize size = CGSizeMake(self.size.height, self.size.width);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextRotateCTM(ctx, -M_PI_2);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.height,size.width), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)flipX{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, size.width, 0);
    CGContextScaleCTM(ctx, -1, 1);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.width,size.height), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)flipY{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextDrawImage(ctx, CGRectMake(0, 0, size.width,size.height), self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end


#import <Security/Security.h>

@implementation NSData (Musou)

- (NSString *)md5{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([self bytes], (CC_LONG)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)sha1{
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], (CC_LONG)[self length], result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
            ];
}

- (NSData*)AES256Encrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
//                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//                                          keyPtr, kCCBlockSizeAES128,
//                                          NULL,
//                                          [self bytes], dataLength,
//                                          buffer, bufferSize,
//                                          &numBytesEncrypted);
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

- (NSData *)AES256Decrypt:(NSString *)key{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
//                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
//                                          keyPtr, kCCBlockSizeAES128,
//                                          NULL,
//                                          [self bytes], dataLength,
//                                          buffer, bufferSize,
//                                          &numBytesDecrypted);
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)encryptRSAWithPublicKey:(SecKeyRef)publicKey maxPlainLen:(size_t)maxPlainLen {
    NSData *content = self;
    size_t plainLen = [content length];
    if (plainLen > maxPlainLen) {
        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLen);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain
               length:plainLen];
    
    size_t cipherLen = 128; // currently RSA key length is set to 128 bytes
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plain,
                                        plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %ld", (long)returnCode);
    }
    else {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

-(NSString *)RSAEncrypotoTheData:(NSString *)plainText
{
    
    SecKeyRef publicKey = nil;
    publicKey = [[self class] getPublicKey:nil];
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger blockSize = cipherBufferSize-11;  // 这个地方比较重要是加密问组长度
    NSInteger numBlock = (NSInteger)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (NSInteger i=0; i<numBlock; i++) {
        NSInteger bufferSize = MIN(blockSize,[plainTextBytes length]-i*blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr)
        {
            NSData *encryptedBytes = [[NSData alloc]
                                       initWithBytes:(const void *)cipherBuffer
                                       length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else
        {
            return nil;
        }
    }
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    NSString *encrypotoResult = [encryptedData base64EncodedStringWithOptions:0];
    return encrypotoResult;
}

+ (SecKeyRef)getPublicKey:(NSString *)certificatePath{
    //    NSString *certificatePath = [[NSBundle mainBundle] pathForResource:@"keystore" ofType:@"p7b"];
    SecCertificateRef myCertificate = nil;
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:certificatePath];
    myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    CFRelease(myPolicy);
    CFRelease(myCertificate);
    if (status == noErr){
        return SecTrustCopyPublicKey(myTrust);
    }
    return nil;
}

@end


//CGContext

void CGAddRoundedCornerPath(CGRect rect, float corner, RounedCornerPosition position, CGContextRef c){
    float x = rect.origin.x, y = rect.origin.y;
    float w = rect.size.width, h = rect.size.height;
    CGContextMoveToPoint(c, x, y + h/2);
    
    switch (position) {
        case kRounderCornerPostionAll:
        {
            //left-top
            CGContextAddArcToPoint(c, x, y, x+w/2, y, corner);
            //right-top
            CGContextAddArcToPoint(c, x+w, y, x + w, y+h/2, corner);
            //right-bottom
            CGContextAddArcToPoint(c, x+w, y+h, x+w/2, y+h, corner);
            //left-bottom
            CGContextAddArcToPoint(c, x, y+h, x, y, corner);
        }
            break;
        case kRounderCornerPostionTop:
        {
            //left-top
            CGContextAddArcToPoint(c, x, y, x+w/2, y, corner);
            //right-top
            CGContextAddArcToPoint(c, x+w, y, x + w, y+h/2, corner);
            //right-bottom
            CGContextAddLineToPoint(c, x + w, y + h);
            //left-bottom
            CGContextAddLineToPoint(c, x, y + h);
        }
            break;
        case kRounderCornerPostionLeft:
        {
            //left-top
            CGContextAddArcToPoint(c, x, y, x+w/2, y, corner);
            //right-top
            CGContextAddLineToPoint(c, x + w, y);
            //right-bottom
            CGContextAddLineToPoint(c, x + w, y + h);
            //left-bottom
            CGContextAddArcToPoint(c, x, y+h, x, y, corner);
        }
            break;
        case kRounderCornerPostionBottom:
        {
            //left-top
            CGContextAddLineToPoint(c, x, y);
            //right-top
            CGContextAddLineToPoint(c, x + w, y);
            //right-bottom
            CGContextAddArcToPoint(c, x+w, y+h, x+w/2, y+h, corner);
            //left-bottom
            CGContextAddArcToPoint(c, x, y+h, x, y, corner);
        }
            break;
        case kRounderCornerPostionRight:
        {
            //left-top
            CGContextAddLineToPoint(c, x, y);
            //right-top
            CGContextAddArcToPoint(c, x+w, y, x + w, y+h/2, corner);
            //right-bottom
            CGContextAddArcToPoint(c, x+w, y+h, x+w/2, y+h, corner);
            //left-bottom
            CGContextAddLineToPoint(c, x, y + h);
        }
            break;
        default:
            break;
    }
    CGContextClosePath(c);
}

void CGDrawLinearGradient(NSArray *cgColors, CGPoint start, CGPoint end, CGContextRef c){
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //    NSArray *cgColors = [NSArray arrayWithObjects:
    //                       (id)[[UIColor blueColor] colorWithAlphaComponent:.5f].CGColor,
    //                       (id)[[UIColor blueColor] colorWithAlphaComponent:.7f].CGColor,
    //                       (id)[[UIColor blueColor] colorWithAlphaComponent:.5f].CGColor,
    //                       nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)cgColors, NULL);
    CGContextDrawLinearGradient(c, gradient, start, end, 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
