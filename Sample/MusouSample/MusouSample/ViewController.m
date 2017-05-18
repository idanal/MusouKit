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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view showToast:@"message"];    
}

@end
