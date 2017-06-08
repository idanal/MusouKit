//
//  ViewController.m
//  MusouSample
//
//  Created by danal.luo on 17/5/13.
//  Copyright © 2017年 danal. All rights reserved.
//

#import "ViewController.h"
#import "MSHttpRequest.h"
#import "MusouKit.h"
#import <objc/runtime.h>


@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = [NSString stringWithFormat:@"vc%d", arc4random()%10];
    
    NSMutableURLRequest *req = [NSMutableURLRequest new];
    req.URL = [NSURL URLWithString:@"http://10.0.0.18:8080/api/login"];
    req.HTTPMethod = @"post";
    [req beginAppending];
    [req appendFormValue:@"danal" name:@"username"];
    [req appendFormValue:@"123" name:@"password"];
    [req endAppending];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
    
    [_button setImage:[MSQRCodeController createQRCodeImage:@"test"] forState:0];
    NSLog(@"%s %@", __func__, self.title);
    [_imageView setUrl:[NSURL URLWithString:@"http://wx4.sinaimg.cn/mw690/7348e379gy1fgcx72nt0kj21w01w0b2a.jpg"]
                  placeholder:[UIImage imageNamed:@"fun.jpg"] thumbSize:CGSizeMake(200, 200)];
    [_button.imageView setUrl:[NSURL URLWithString:@"http://d.lanrentuku.com/down/png/1101/paradise_fruit/apple512.png"] placeholder:nil thumbSize:CGSizeMake(200, 200)];
    
    NSArray *urls = @[
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123206&di=c1b97922a2b2d0a77292f5e2286d72ea&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F131116%2F234936-1311160T93771.jpg",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123669&di=244a1d28b51a901c4f2d2def770216cf&imgtype=0&src=http%3A%2F%2Fwww.taopic.com%2Fuploads%2Fallimg%2F120119%2F2379-12011912011919.jpg",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123669&di=ca1c699fb1fc4939a9e55cad0bea82ca&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F120207%2F10022-12020G6320177.jpg",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123669&di=3177d671215dc58eeb62ab297ad2ede8&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F110818%2F1210-110QPRI79.jpg",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123669&di=d50655a5f869779fb493ce22ddde0512&imgtype=0&src=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F120326%2F2722-12032609394067.jpg",
                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1496915123669&di=6e6eebba76983172582d6ed11ced0925&imgtype=0&src=http%3A%2F%2Fimg3.redocn.com%2Ftupian%2F20160129%2Fhuangseshuiguotuanjpggeshibeijingtupian_5832527.jpg"
                      ];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%s %@", __func__, self.title);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view showToast:@"message"];    
}

+ (NSString *)storyboardName{
    return @"Main";
}

@end


@implementation TestImageView

- (void)dealloc{
    NSLog(@"%s", __func__);
}

@end
