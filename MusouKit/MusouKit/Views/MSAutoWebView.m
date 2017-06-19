//
//  MSAutoWebView.m
//  MusouKit
//
//  Created by danal.luo on 17/5/3.
//  Copyright © 2017年 DANAL. All rights reserved.
//

#import "MSAutoWebView.h"

@implementation MSAutoWebView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup{
    self.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.scrollEnabled = NO;
    //    self.scalesPageToFit = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat h = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    NSLog(@"AutoHeightWebViewHeight:%f",h);
    NSLayoutConstraint *height;
    for (NSLayoutConstraint *c in webView.constraints){
        if (c.firstAttribute == NSLayoutAttributeHeight){
            height = c;
            break;
        }
    }
    if (height == nil){
        height = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:h];
        [webView addConstraint:height];
    }
    height.constant = h;
    
    if (_onLoadFinished) {
        _onLoadFinished();
    }
}

//extends
- (void)loadHtmlWithFixImg:(NSString *)html docWidth:(CGFloat)docWidth{
    NSString *str = [NSString stringWithFormat:@"<head><style>img{max-width:%f !important;} body{margin:0px;}</style></head>", docWidth];
    [self loadHTMLString:str baseURL:nil];
}

@end



@implementation MSAutoWKWebView

- (WKNavigation *)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    self.scrollView.bounces = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.delegate = self;
    self.navigationDelegate = self;
    
    NSString *html = [NSString stringWithFormat:@"<head><meta name='viewport' content='width=device-width'/></head>%@", string];
    return [super loadHTMLString:html baseURL:baseURL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable val, NSError * _Nullable error) {
        
        NSLog(@"AutoHeightWebViewHeight:%@", val);
        CGFloat h = [val doubleValue];
        for (NSLayoutConstraint *c in webView.constraints){
            if (c.firstAttribute == NSLayoutAttributeHeight){
                c.constant = h;
                break;
            }
        }
        if (_onLoadFinished) {
            _onLoadFinished();
        }
    }];
}

@end
