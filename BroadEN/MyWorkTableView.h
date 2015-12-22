//
//  MyWorkTableView.h
//  BroadEN
//
//  Created by Seven on 15/12/6.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWorkTableView : UIViewController<UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *workTypeArray;
    
    BOOL isLoading;
    BOOL isLoadOver;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
