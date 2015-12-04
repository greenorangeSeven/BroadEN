//
//  CorrespondenceTableView.h
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CorrespondenceTableView : UIViewController

@property (strong, nonatomic) NSString *projId;
@property (strong, nonatomic) NSString *PROJ_Name;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
