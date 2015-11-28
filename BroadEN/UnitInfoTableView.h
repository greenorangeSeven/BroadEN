//
//  UnitInfoTableView.h
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitInfoTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>
{
    NSArray *units;
}

@property (strong, nonatomic) NSString *ID;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
