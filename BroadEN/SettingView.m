//
//  SettingView.m
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SettingView.h"
#import "ItemTableCell.h"
#import "SettingModel.h"
#import "LoginView.h"
#import "ModifyPassWordView.h"
#import "UserInfomationView.h"

@interface SettingView ()
{
    NSMutableArray *items;
    UserInfo *userinfo;
}

@end

@implementation SettingView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    items = [[NSMutableArray alloc] initWithObjects:
             [[SettingModel alloc] initWith:@"modify password" andImg:nil andTag:1 andTitle2:nil],
             [[SettingModel alloc] initWith:@"personal information" andImg:nil andTag:2 andTitle2:nil],
             [[SettingModel alloc] initWith:@"logout" andImg:nil andTag:3 andTitle2:nil],
             nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingModel *action = [items objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
        case 1:
        {
            ModifyPassWordView *modifyPassWordView = [[ModifyPassWordView alloc] init];
            [self.navigationController pushViewController:modifyPassWordView animated:YES];
        }
            break;
        case 2:
        {
            UserInfomationView *userInfomationView = [[UserInfomationView alloc] init];
            [self.navigationController pushViewController:userInfomationView animated:YES];
        }
            break;
        case 3:
        {
            LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
            AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            appdele.window.rootViewController = loginView;
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ItemTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ItemTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ItemTableCell class]]) {
                cell = (ItemTableCell *)o;
                break;
            }
        }
    }
    
    NSUInteger row = [indexPath row];
    SettingModel *model = [items objectAtIndex:row];
    if(model.img)
    {
        cell.imgIv.image = [UIImage imageNamed:model.img];
    }
    cell.titleLb.text = model.title;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"Back";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
