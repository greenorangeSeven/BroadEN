//
//  UserInfoTypeTableView.h
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTypeTableView : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *PROJ_Name;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *projId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
