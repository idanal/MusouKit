//
//  TableViewController.m
//  MusouSample
//
//  Created by DANAL LUO on 27/06/2017.
//  Copyright © 2017 danal. All rights reserved.
//

#import "TableViewController.h"
#import "MusouKit.h"


@interface TableViewController ()
@end

@implementation TableViewController

- (void)dealloc{
    NSLog(@"~~~~~~");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imgv = (UIImageView *)[cell.contentView viewWithTag:1];
    imgv.backgroundColor = [UIColor whiteColor];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"2.jpg" ofType:nil];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
    
//    imgv.layer.cornerRadius = imgv.bounds.size.width/2;
//    imgv.clipsToBounds = YES;
//    imgv.image = image;
    
    imgv.image = [image roundedImage:imgv.bounds.size.width];
    
    UILabel *lbl = (UILabel *)[cell.contentView viewWithTag:2];
    lbl.text = @(indexPath.row).stringValue;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


@implementation MyView

- (void)removeFromSuperview{
    [super removeFromSuperview];
    NSLog(@"removeFromSuperview:%@", self);
    [_target invokeMethod:_selector object:nil];
}

- (void)setRemovedCallback:(SEL)selector target:(id)target{
    _selector = selector;
    _target = target;
}

@end
