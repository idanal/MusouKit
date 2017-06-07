//
//  SegmentViewController.m
//  MusouSample
//
//  Created by DANAL LUO on 2017/6/7.
//  Copyright © 2017年 danal. All rights reserved.
//

#import "SegmentViewController.h"
#import "ViewController.h"
#import "MusouKit.h"

@interface SegmentViewController ()

@end

@implementation SegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.controllers = @[[ViewController create],
                         [ViewController create],
                         [ViewController create],
                         [ViewController create],
                         [ViewController create],
                         [ViewController create],
                         ];
    self.titles = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    self.indicatorWidth = 40;
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
