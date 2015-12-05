//
//  SolnMgtTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SolnMgtTableView.h"
#import "SolnMgtTableCell.h"
#import "SolnMgtDetailView.h"
#import "SolnMgt.h"

@interface SolnMgtTableView ()
{
    UserInfo *userinfo;
    BOOL gNoRefresh;
}

@end

@implementation SolnMgtTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Soln Mgt List";
    self.tabBarItem.title = @"Soln Mgt";
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    mgts = [[NSMutableArray alloc] initWithCapacity:25];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    [self reload:YES];
}

- (void)reload:(BOOL)noRefresh
{
    gNoRefresh = noRefresh;
    if (isLoading || isLoadOver) {
        return;
    }
    if (!noRefresh) {
        allCount = 0;
    }
    
    NSString *sqlStr = nil;
    
    //计算出页码
    int pageIndex = allCount / 25 + 1;
    
    NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
    NSString *ser_Dept = [preference objectForKey:@"ser_Dept"];
    NSString *Franchiser = [preference objectForKey:@"Franchiser"];
    NSString *Engineer = [preference objectForKey:@"Engineer"];
    
    sqlStr = [NSString stringWithFormat:@"declare @p16 int set @p16=0 exec SP_GetSolutionMgmtByPage_En @PageIndex='%i',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@searchField='All',@searchString='',@StartTime='',@EndTime='',@TimeType='取样时间',@ConfigType1='',@ConfigType2='',@Franchiser='%@',@Total=@p16 output select @p16",pageIndex,userinfo.UserName,ser_Dept,Engineer, Franchiser];
    
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
        
        NSArray *mgtsNewsList = [Tool readJsonToObjArray:table andObjClass:[SolnMgt class]];
        isLoading = NO;
        if (!gNoRefresh) {
            [self clear];
        }
        if (mgtsNewsList.count < 25) {
            isLoadOver = YES;
        }
        [mgts addObjectsFromArray:mgtsNewsList];
        allCount = [mgts count];
                NSDictionary *dic1 = table1[0];
                NSString *counts = dic1[@"Column1"];
                self.title = [NSString stringWithFormat:@"Soln Mgt List(%@)",counts];
                self.tabBarItem.title = @"Soln Mgt";
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
    [mgts removeAllObjects];
    mgts = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [mgts removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return mgts.count == 0 ? 1 : mgts.count;
        }
        else
            return mgts.count + 1;
    }
    else
        return mgts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [mgts count])
    {
        return 128.0;
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
    if ([mgts count] > 0) {
        if (row < [mgts count])
        {
            SolnMgtTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SolnMgtTableCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SolnMgtTableCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[SolnMgtTableCell class]]) {
                        cell = (SolnMgtTableCell *)o;
                        break;
                    }
                }
            }
            SolnMgt *s = [mgts objectAtIndex:row];
            cell.PROJ_Name_EnLb.text = s.PROJ_Name_En;
            cell.ececManLb.text = s.Exec_Man;
            cell.execDateLb.text = s.Exec_Date;
            cell.unitModeLb.text = s.AirCondUnit_Mode;
            cell.serialNumLb.text = s.OutFact_Num;
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
    NSUInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [mgts count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        SolnMgt *s = [mgts objectAtIndex:row];
        SolnMgtDetailView *detailView = [[SolnMgtDetailView alloc] init];
        detailView.ID = s.ID;
        detailView.hidesBottomBarWhenPushed  = YES;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
