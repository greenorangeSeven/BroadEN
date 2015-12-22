//
//  MoreUnitInfoTableView.m
//  BroadEN
//
//  Created by Seven on 15/12/5.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MoreUnitInfoTableView.h"
#import "MoreUnitInfoTableCell.h"
#import "UnitInfo.h"
#import "UnitInfoDetailView.h"
#import "AllInOneSearchView.h"

@interface MoreUnitInfoTableView ()
{
    UserInfo *userinfo;
    BOOL gNoRefresh;
}

@end

@implementation MoreUnitInfoTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Unit Info";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    units = [[NSMutableArray alloc] initWithCapacity:25];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    gNoRefresh = YES;
    [self reload:YES];
}

- (void)reload:(BOOL)noRefresh
{
//    gNoRefresh = noRefresh;
    if (isLoading || isLoadOver) {
        return;
    }
    if (!gNoRefresh) {
        allCount = 0;
    }
    
    NSString *sqlStr = nil;
    
    //计算出页码
    int pageIndex = allCount / 25 + 1;
    
    NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
    NSString *ser_Dept = [preference objectForKey:@"ser_Dept"];
    NSString *Franchiser = [preference objectForKey:@"Franchiser"];
    NSString *Engineer = [preference objectForKey:@"Engineer"];
    
    sqlStr = [NSString stringWithFormat:@"declare @p13 int set @p13=0 exec SP_GetUnitStatusByPage_En @PageIndex='%D',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@Country='全部',@SearchField='All',@SearchString='',@UnitStatus='全部',@Franchiser='%@',@Total=@p13 output select @p13",pageIndex,userinfo.UserName,ser_Dept,Engineer, Franchiser];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInUserInfo", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestOK:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
    isLoading = YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    isLoading = NO;
    [self doneLoadingTableViewData];
}

- (void)requestOK:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        isLoading = NO;
        [self doneLoadingTableViewData];
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(string);
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *table = [jsonDic objectForKey:@"Table"];
        NSArray *table1 = [jsonDic objectForKey:@"Table1"];
        
        NSArray *unitNewsList = [Tool readJsonToObjArray:table andObjClass:[UnitInfo class]];
        isLoading = NO;
        if (!gNoRefresh) {
            [self clear];
        }
        if (unitNewsList.count < 25) {
            isLoadOver = YES;
        }
        [units addObjectsFromArray:unitNewsList];
        allCount = [units count];
        
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        self.title = [NSString stringWithFormat:@"Unit Info(%@)",counts];
        
        [self.tableView reloadData];
        [self doneLoadingTableViewData];
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [units removeAllObjects];
    units = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [units removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return units.count == 0 ? 1 : units.count;
        }
        else
            return units.count + 1;
    }
    else
        return units.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [units count])
    {
        return 151.0;
    }
    else
    {
        return 40.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if ([units count] > 0) {
        if (row < [units count])
        {
            MoreUnitInfoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:MoreUnitInfoTableCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MoreUnitInfoTableCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[MoreUnitInfoTableCell class]]) {
                        cell = (MoreUnitInfoTableCell *)o;
                        break;
                    }
                }
            }
            UnitInfo *u = [units objectAtIndex:row];
            cell.PROJ_Name_EnLb.text = u.PROJ_Name_En;
            cell.PROJ_NameLb.text = u.PROJ_Name;
            cell.UnitModelLb.text = u.AirCondUnit_Mode;
            cell.ProductionLb.text = u.Prod_Num;
            cell.SerialLb.text = u.OutFact_Num;
            cell.DeliveryLb.text = [Tool DateTimeRemoveTime:u.Send_Date andSeparated:@" "];
            return cell;
            
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [units count]) {
        //启动刷新
        if (!isLoading) {
            gNoRefresh = YES;
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        UnitInfo *u = [units objectAtIndex:row];
        UnitInfoDetailView *detailView = [[UnitInfoDetailView alloc] init];
        detailView.ID = u.ID;
        detailView.PROJ_ID = u.PROJ_ID;
        [self.navigationController pushViewController:detailView animated:YES];
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
        gNoRefresh = YES;
        [self performSelector:@selector(reload:)];
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
        gNoRefresh = NO;
        [self reload:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

- (IBAction)searchAction:(id)sender {
    AllInOneSearchView *searchView = [[AllInOneSearchView alloc] init];
    searchView.searchType = @"UnitInfo";
    searchView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchView animated:YES];
}

@end