//
//  AgreementTabelView.h
//  BroadEN
//
//  Created by Seven on 15/12/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgreementTabelView : UIViewController

@property (strong, nonatomic) NSString *PROJ_Name_En;
@property (strong, nonatomic) NSString *projId;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
