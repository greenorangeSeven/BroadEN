//
//  SettingView.h
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingView : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
