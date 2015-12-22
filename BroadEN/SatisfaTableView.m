//
//  SatisfaTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SatisfaTableView.h"
#import "SatisfaTableCell.h"
#import "SatisfaDetailView.h"
#import "Satisfa.h"
#import "AllInOneSearchView.h"

@interface SatisfaTableView ()
{
    UserInfo *userinfo;
    BOOL gNoRefresh;
}

@end

@implementation SatisfaTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Satisfa List";
    self.tabBarItem.title = @"Satisfaction";
    
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
    
    satisfas = [[NSMutableArray alloc] initWithCapacity:25];
    
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
    
    sqlStr = [NSString stringWithFormat:@"declare @p12 int set @p12=0 exec SP_GetUserHQTelFollowByPage_En  @PageIndex='%i',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@searchField='全部',@searchString='',@StartTime='',@EndTime='',@Franchiser='%@',@Total=@p12 output select @p12",pageIndex,userinfo.UserName,ser_Dept,Engineer, Franchiser];
    
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
        
        NSArray *mgtsNewsList = [Tool readJsonToObjArray:table andObjClass:[Satisfa class]];
        isLoading = NO;
        if (!gNoRefresh) {
            [self clear];
        }
        if (mgtsNewsList.count < 25) {
            isLoadOver = YES;
        }
        [satisfas addObjectsFromArray:mgtsNewsList];
        allCount = [satisfas count];
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        self.title = [NSString stringWithFormat:@"Satisfa List(%@)",counts];
        self.tabBarItem.title = @"Satisfa";
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
    [satisfas removeAllObjects];
    satisfas = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [satisfas removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return satisfas.count == 0 ? 1 : satisfas.count;
        }
        else
            return satisfas.count + 1;
    }
    else
        return satisfas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [satisfas count])
    {
        return 85.0;
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
    if ([satisfas count] > 0) {
        if (row < [satisfas count])
        {
            SatisfaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SatisfaTableCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SatisfaTableCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[SatisfaTableCell class]]) {
                        cell = (SatisfaTableCell *)o;
                        break;
                    }
                }
            }
            
            Satisfa *s = [satisfas objectAtIndex:row];
            
            if (s.Prod_OverallMerit_EN == nil || s.Prod_OverallMerit_EN.length == 0) {
                if ([s.Prod_OverallMerit isEqualToString:@"好"]) {
                    s.Prod_OverallMerit_EN = @"Excellent";
                }
                else if ([s.Prod_OverallMerit isEqualToString:@"较好"])
                {
                    s.Prod_OverallMerit_EN = @"Good";
                }
                else if ([s.Prod_OverallMerit isEqualToString:@"一般"])
                {
                    s.Prod_OverallMerit_EN = @"Poor";
                }
                else if ([s.Prod_OverallMerit isEqualToString:@"较差"])
                {
                    s.Prod_OverallMerit_EN = @"Bad";
                }
                else if ([s.Prod_OverallMerit isEqualToString:@"差"])
                {
                    s.Prod_OverallMerit_EN = @"Very Bad";
                }
            }
            
            if (s.Serv_OverallMerit_EN == nil || s.Serv_OverallMerit_EN.length == 0) {
                if ([s.Serv_OverallMerit isEqualToString:@"好"]) {
                    s.Serv_OverallMerit_EN = @"Excellent";
                }
                else if ([s.Serv_OverallMerit isEqualToString:@"较好"])
                {
                    s.Serv_OverallMerit_EN = @"Good";
                }
                else if ([s.Serv_OverallMerit isEqualToString:@"一般"])
                {
                    s.Serv_OverallMerit_EN = @"Poor";
                }
                else if ([s.Serv_OverallMerit isEqualToString:@"较差"])
                {
                    s.Serv_OverallMerit_EN = @"Bad";
                }
                else if ([s.Serv_OverallMerit isEqualToString:@"差"])
                {
                    s.Serv_OverallMerit_EN = @"Very Bad";
                }
            }

            cell.nameEnLb.text = s.PROJ_Name_En;
            cell.prodLb.text = s.Prod_OverallMerit_EN;
            cell.servLb.text = s.Serv_OverallMerit_EN;
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
    if (row >= [satisfas count]) {
        //启动刷新
        if (!isLoading) {
            gNoRefresh = YES;
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Satisfa *s = [satisfas objectAtIndex:row];
        SatisfaDetailView *detailView = [[SatisfaDetailView alloc] init];
        detailView.ID = s.ID;
        detailView.projId = s.PROJ_ID;
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

- (IBAction)searchAction:(id)sender {
    AllInOneSearchView *searchView = [[AllInOneSearchView alloc] init];
    searchView.searchType = @"Satisfa";
    searchView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchView animated:YES];
}

@end
