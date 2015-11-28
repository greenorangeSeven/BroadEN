//
//  UnitInfoDetailView.h
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface UnitInfoDetailView : UIViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate,MWPhotoBrowserDelegate>
{
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *PROJ_ID;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
