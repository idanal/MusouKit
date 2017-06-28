//
//  TableViewController.h
//  MusouSample
//
//  Created by DANAL LUO on 27/06/2017.
//  Copyright © 2017 danal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UILabel *fpsLbl;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end


@interface MyView : UIView
{
    __weak id _target;
    SEL _selector;
}
- (void)setRemovedCallback:(SEL)selector target:(id)target;
@end
