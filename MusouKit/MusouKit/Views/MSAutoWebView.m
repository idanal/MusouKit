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
    //    self.scrollView.bounces = NO;
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
