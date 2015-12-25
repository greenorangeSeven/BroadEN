//
//  MyWorkTableView.m
//  BroadEN
//
//  Created by Seven on 15/12/6.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MyWorkTableView.h"
#import "MyWorkType.h"
#import "MyWorkItem.h"
#import "MyWorkTableCell.h"
#import "SolnMgtFlowView.h"
#import "SatisfaFlowView.h"
#import "MaintenanceFlowView.h"
#import "ZeroHeightTableCell.h"

@interface MyWorkTableView ()
{
    UserInfo *userinfo;
}

@end

@implementation MyWorkTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Work";
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    workTypeArray = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getToDoWork) name:@"Notification_MyWorkListReLoad" object:nil];
    
    [self getServerDept];
    [self getToDoWork];
}

- (void)getServerDept
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * From [dbo].[V_GJServerDept] Where jc='%@'",userinfo.Department];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSer:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Loading..." andView:self.view andHUD:request.hud];
}

- (void)requestSer:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSString * ser_Dept = @"";
        if(jsonArray && jsonArray.count > 0){
            NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
            ser_Dept = jsonDic[@"jc01"];
            if(!ser_Dept)
            {
                ser_Dept = @"";
            }
        }
        
        NSString *Engineer = @"All";
        if (userinfo.xzjb == 0) {
            Engineer = userinfo.UserName;
        }
        
        NSString *Franchiser = @"All";
        if ([userinfo.js isEqualToString:@"GJJXS"]) {
            Franchiser = userinfo.UserName;
        }
        
        if (userinfo.xzjb != 0 && userinfo.xzjb != 1) {
            ser_Dept = @"All";
        }
        
        NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
        [preference removeObjectForKey:@"ser_Dept"];
        [preference removeObjectForKey:@"Franchiser"];
        [preference removeObjectForKey:@"Engineer"];
        [preference setObject:ser_Dept forKey:@"ser_Dept"];
        [preference setObject:Franchiser forKey:@"Franchiser"];
        [preference setObject:Engineer forKey:@"Engineer"];
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getToDoWork
{
    [workTypeArray removeAllObjects];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_Search_GetFlowToDo_En '10','%@'", userinfo.UserName];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestToDoWork:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestToDoWork:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if([jsonArray count] > 0)
        {
            NSArray *todoWorks = [Tool readJsonToObjArray:jsonArray andObjClass:[MyWorkItem class]];
            MyWorkType *workType = [[MyWorkType alloc] init];
            workType.typeTitle = @"To-do work";
            workType.workArray = todoWorks;
            [workTypeArray addObject:workType];
        }
        [self getUncompletedWork];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getUncompletedWork
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_Search_GetFlowZaiBan_En '10','%@'", userinfo.UserName];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestUncompletedWork:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:request.hud];
}

- (void)requestUncompletedWork:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if([jsonArray count] > 0)
        {
            NSArray *uncompletedWorks = [Tool readJsonToObjArray:jsonArray andObjClass:[MyWorkItem class]];
            MyWorkType *workType = [[MyWorkType alloc] init];
            workType.typeTitle = @"Uncompleted work";
            workType.workArray = uncompletedWorks;
            [workTypeArray addObject:workType];
        }
        [self getToCheckWork];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getToCheckWork
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_Search_GetFlowBanJie_En '10','%@'", userinfo.UserName];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestToCheckWork:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:request.hud];
}

- (void)requestToCheckWork:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if([jsonArray count] > 0)
        {
            NSArray *tocheckWorks = [Tool readJsonToObjArray:jsonArray andObjClass:[MyWorkItem class]];
            MyWorkType *workType = [[MyWorkType alloc] init];
            workType.typeTitle = @"To-check work";
            workType.workArray = tocheckWorks;
            [workTypeArray addObject:workType];
        }
        [self.tableView reloadData];
        [self doneLoadingTableViewData];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [workTypeArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MyWorkType *type = [workTypeArray objectAtIndex:section];
    return type.workArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MyWorkType *type = [workTypeArray objectAtIndex:section];

    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
    headerView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:236.0/255.0 blue:255.0/255.0 alpha:1.0];
    headerView.font = [UIFont systemFontOfSize:16.0];
    headerView.textAlignment = UITextAlignmentCenter;
    headerView.textColor = [UIColor colorWithRed:23.0/255.0 green:143.0/255.0 blue:230.0/255.0 alpha:1.0];
    headerView.text = type.typeTitle;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];//创建一个视图
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (workTypeArray.count > 0) {
        MyWorkTableCell *cell = [tableView dequeueReusableCellWithIdentifier:MyWorkTableCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyWorkTableCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[MyWorkTableCell class]]) {
                    cell = (MyWorkTableCell *)o;
                    break;
                }
            }
        }
        
        MyWorkType *workType = [workTypeArray objectAtIndex:indexPath.section];
        MyWorkItem *workItem = [workType.workArray objectAtIndex:indexPath.row];
        if(workItem.FlowNameEN == nil || workItem.FlowNameEN.length == 0)
        {
            workItem.FlowNameEN = [self CNTOEN:workItem.FlowName];
        }
        cell.FlowNameTv.text = workItem.FlowNameEN;
        cell.ApplyDateTimeLb.text = workItem.ApplyDateTime;
        cell.PROJ_NameLb.text = workItem.PROJ_Name;
        return cell;
    }
    else
    {
        ZeroHeightTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ZeroHeightTableCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ZeroHeightTableCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[ZeroHeightTableCell class]]) {
                    cell = (ZeroHeightTableCell *)o;
                    break;
                }
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyWorkType *workType = [workTypeArray objectAtIndex:indexPath.section];
    MyWorkItem *workItem = [workType.workArray objectAtIndex:indexPath.row];
    if([workType.typeTitle isEqualToString:@"To-do work"])
    {
        if([workItem.FlowName isEqualToString:@"维护保养审批(英文版)"])
        {
            MaintenanceFlowView *maintenanceFlow = [[MaintenanceFlowView alloc] init];
            maintenanceFlow.Mark = workItem.Mark;
            maintenanceFlow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:maintenanceFlow animated:YES];
        }
        else if([workItem.FlowName isEqualToString:@"总部电话回访审批"])
        {
            SatisfaFlowView *satisfaFlow = [[SatisfaFlowView alloc] init];
            satisfaFlow.Mark = workItem.Mark;
            satisfaFlow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:satisfaFlow animated:YES];
        }
        else if([workItem.FlowName isEqualToString:@"溶液管理录入"])
        {
            SolnMgtFlowView *solnMgtFlow = [[SolnMgtFlowView alloc] init];
            solnMgtFlow.Mark = workItem.Mark;
            solnMgtFlow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:solnMgtFlow animated:YES];
        }
    }
    else
    {
        if([workItem.FlowName isEqualToString:@"维护保养审批(英文版)"])
        {
            MaintenanceFlowView *maintenanceFlow = [[MaintenanceFlowView alloc] init];
            maintenanceFlow.Mark = workItem.Mark;
            maintenanceFlow.isQuery = YES;
            maintenanceFlow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:maintenanceFlow animated:YES];
        }
        else if([workItem.FlowName isEqualToString:@"总部电话回访审批"])
        {
            SatisfaFlowView *satisfaFlow = [[SatisfaFlowView alloc] init];
            satisfaFlow.Mark = workItem.Mark;
            satisfaFlow.isQuery = YES;
            satisfaFlow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:satisfaFlow animated:YES];
        }
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
        
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self getToDoWork];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)CNTOEN:(NSString *)CN
{
    NSString *EN = @"";
    if (CN && CN.length > 0) {
        if ([CN isEqualToString:@"维护保养审批(英文版)"]) {
            EN = @"Maintenance";
        }
        else if ([CN isEqualToString:@"总部电话回访审批"]) {
            EN = @"Satisfaction Survey";
        }
        else if ([CN isEqualToString:@"停用机组状况追踪"]) {
            EN = @"Inactive Unit Tracking";
        }
        else if ([CN isEqualToString:@"机组停用审批"]) {
            EN = @"Inactive Unit Application";
        }
        else if ([CN isEqualToString:@"机组注销申报"]) {
            EN = @"Log Off Unit Application";
        }
        else if ([CN isEqualToString:@"溶液管理录入"]) {
            EN = @"Solution Management Filling";
        }
        else if ([CN isEqualToString:@"服务部月调试保养汇总(英文版)"]) {
            EN = @"Maintenace Collect";
        }
        else if ([CN isEqualToString:@"服务部月未满保修期明细(英文版)"]) {
            EN = @"Under Guarantee";
        }
    }
    return EN;
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
