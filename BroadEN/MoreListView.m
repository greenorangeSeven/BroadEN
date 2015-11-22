//
//  MoreListView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MoreListView.h"
#import "ItemTableCell.h"
#import "SettingModel.h"

@interface MoreListView ()
{
    NSArray *items;
}

@end

@implementation MoreListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"More";
    self.tabBarItem.title = @"more";
    
    items = [[NSArray alloc] initWithObjects:
                [[SettingModel alloc] initWith:@"Unit Info" andImg:@"more_userinfo" andTag:1 andTitle2:nil],
                [[SettingModel alloc] initWith:@"Agreement Mgt" andImg:@"more_agreemenemgt" andTag:2 andTitle2:nil],
                [[SettingModel alloc] initWith:@"Corrpdnc Mails" andImg:@"more_agreemenemgt" andTag:3 andTitle2:nil],
                [[SettingModel alloc] initWith:@"My Work" andImg:@"more_mywork" andTag:4 andTitle2:nil],
                [[SettingModel alloc] initWith:@"Settings" andImg:@"more_setting" andTag:5 andTitle2:nil],
                [[SettingModel alloc] initWith:@"Help and Support" andImg:@"more_help" andTag:6 andTitle2:nil],
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
