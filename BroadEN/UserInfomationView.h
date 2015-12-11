//
//  UserInfomationView.h
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfomationView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *UserNameLB;
@property (weak, nonatomic) IBOutlet UILabel *TrueNameLB;
@property (weak, nonatomic) IBOutlet UILabel *SerilsLB;
@property (weak, nonatomic) IBOutlet UILabel *DepartmentEnLB;
@property (weak, nonatomic) IBOutlet UILabel *RoleNameEnLB;
@property (weak, nonatomic) IBOutlet UILabel *ZhiWeiEnLB;
@property (weak, nonatomic) IBOutlet UILabel *IfLoginLB;
@property (weak, nonatomic) IBOutlet UITextView *BackInfoTV;

@end
