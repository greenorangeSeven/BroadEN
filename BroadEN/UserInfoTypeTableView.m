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
#import "UserBasicFoldView.h"
#import "UnitInfoTableView.h"
#import "MaintainingTableView.h"
#import "UserSolnTableView.h"
#import "UserSatisfaTableView.h"
#import "CorrespondenceTableView.h"
#import "AgreementTabelView.h"

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
             [[SettingModel alloc] initWith:@"Basic Information" andImg:@"more_basicinfor" andTag:1 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Unit Information" andImg:@"more_userinfo" andTag:2 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Maintenance" andImg:@"more_maintaining" andTag:3 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Solution Management" andImg:@"more_solution" andTag:4 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Satisfaction Survey" andImg:@"more_satisfaction" andTag:5 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Correspondance" andImg:@"more_corrpdnc" andTag:6 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Agreement List" andImg:@"more_agreement" andTag:7 andTitle2:nil],
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
            UserBasicFoldView *basicInfoView = [[UserBasicFoldView alloc] init];
            basicInfoView.titleStr = self.titleStr;
            basicInfoView.ID = self.userId;
            [self.navigationController pushViewController:basicInfoView animated:YES];
        }
            break;
        case 2:
        {
            UnitInfoTableView *unitInfoView = [[UnitInfoTableView alloc] init];
            unitInfoView.ID = self.userId;
            [self.navigationController pushViewController:unitInfoView animated:YES];
        }
            break;
        case 3:
        {
            MaintainingTableView *maintainingView = [[MaintainingTableView alloc] init];
            maintainingView.projId = self.projId;
            [self.navigationController pushViewController:maintainingView animated:YES];
        }
            break;
        case 4:
        {
            UserSolnTableView *solnTableView = [[UserSolnTableView alloc] init];
            solnTableView.projId = self.projId;
            solnTableView.PROJ_Name_En = self.titleStr;
            [self.navigationController pushViewController:solnTableView animated:YES];
        }
            break;
        case 5:
        {
            UserSatisfaTableView *satisfaTableView = [[UserSatisfaTableView alloc] init];
            satisfaTableView.projId = self.projId;
            [self.navigationController pushViewController:satisfaTableView animated:YES];
        }
            break;
        case 6:
        {
            CorrespondenceTableView *corrTableView = [[CorrespondenceTableView alloc] init];
            corrTableView.projId = self.projId;
            corrTableView.PROJ_Name = self.PROJ_Name;
            [self.navigationController pushViewController:corrTableView animated:YES];
        }
            break;
        case 7:
        {
            AgreementTabelView *agreementTableView = [[AgreementTabelView alloc] init];
            agreementTableView.projId = self.projId;
            agreementTableView.PROJ_Name_En = self.titleStr;
            [self.navigationController pushViewController:agreementTableView animated:YES];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
