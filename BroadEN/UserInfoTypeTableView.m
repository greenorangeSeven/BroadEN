//
//  UserInfoTypeTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserInfoTypeTableView.h"
#import "ItemTableCell.h"
#import "SettingModel.h"
#import "UserBasicInfoView.h"

@interface UserInfoTypeTableView ()
{
    NSArray *items;
}

@end

@implementation UserInfoTypeTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    
    items = [[NSArray alloc] initWithObjects:
             [[SettingModel alloc] initWith:@"Basic Info" andImg:@"user_bi" andTag:1 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Unit Info" andImg:@"user_ui" andTag:2 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Maintaining" andImg:@"user_mt" andTag:3 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Soln Mgt" andImg:@"user_sm" andTag:4 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Satisfaction Suery" andImg:@"user_ss" andTag:5 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Correspondace" andImg:@"user_cd" andTag:6 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Agreement List" andImg:@"user_al" andTag:7 andTitle2:nil],
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
            UserBasicInfoView *basicInfoView = [[UserBasicInfoView alloc] init];
            basicInfoView.titleStr = self.titleStr;
            basicInfoView.ID = self.userId;
            [self.navigationController pushViewController:basicInfoView animated:YES];
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
        case 7:
        {
            
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
    cell.imgIv.image = [UIImage imageNamed:model.img];
    cell.titleLb.text = model.title;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

@end
