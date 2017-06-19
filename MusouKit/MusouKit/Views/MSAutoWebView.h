//
//  MSAutoWebView.h
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.b
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 * Auto calculate the height of a webView
 */
@interface MSAutoWebView : UIWebView <UIWebViewDelegate>
/** Callback when calculating done */
@property (nonatomic, copy) void (^onLoadFinished)(void);

/**
 * Load html, limit img tag with max-width
 * @param html Html to load
 * @param docWidth The width of the document
 */
- (void)loadHtmlWithFixImg:(NSString *)html docWidth:(CGFloat)docWidth;

@end



@interface MSAutoWKWebView : WKWebView <UIScrollViewDelegate, WKNavigationDelegate>
/** Callback when calculating done */
@property (nonatomic, copy) void (^onLoadFinished)(void);
@end
