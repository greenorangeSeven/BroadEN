//
//  MaintainingTableView.h
//  BroadEN
//
//  Created by Seven on 15/11/26.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintainingTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>

@property (strong, nonatomic) NSString *projId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
