//
//  UsersTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UsersTableView.h"
#import "UserTableCell.h"
#import "UserInfoTypeTableView.h"
#import "AllInOneSearchView.h"

@interface UsersTableView ()
{
    UserInfo *userinfo;
    NSString *ser_Dept;
    BOOL gNoRefresh;
}

@end

@implementation UsersTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Customer Select";
    self.tabBarItem.title = @"User Info";
    
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
    
    users = [[NSMutableArray alloc] initWithCapacity:50];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
//    self.searchController =[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];;
//    
//    self.searchController.searchResultsDelegate= self;
//    
//    self.searchController.searchResultsDataSource = self;
//    
//    self.searchController.delegate = self;
    
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
    [Tool showHUD:@"加载中..." andView:self.view andHUD:request.hud];
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
        NSLog(string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(jsonArray && jsonArray.count > 0){
            NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
            ser_Dept = jsonDic[@"jc01"];
            if(!ser_Dept)
            {
                ser_Dept = @"";
            }
        }
        NSString *sqlStr = nil;
        
        //计算出页码
        int pageIndex = allCount / 50 + 1;
        
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
        
        sqlStr = [NSString stringWithFormat:@"declare @p12 int set @p12=51 exec SP_GetProjInfoByPage_En @PageIndex='%i',@PageSize=50,@SearchField='All',@searchString='',@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@Country='全部',@Franchiser='%@',@Total=@p12 output select @p12",pageIndex,userinfo.UserName,ser_Dept,Engineer, Franchiser];
        
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
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
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
        
        NSArray *userNewsList = [Tool readJsonToObjArray:table andObjClass:[Depart class]];
        isLoading = NO;
        if (!gNoRefresh) {
            [self clear];
        }
        if (userNewsList.count < 50) {
            isLoadOver = YES;
        }
        [users addObjectsFromArray:userNewsList];
        allCount = [users count];
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        self.title = [NSString stringWithFormat:@"Customer Select(%@)",counts];
        self.tabBarItem.title = @"User Info";
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
    [users removeAllObjects];
    users = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [users removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return users.count == 0 ? 1 : users.count;
        }
        else
            return users.count + 1;
    }
    else
        return users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row < [users count])
    {
        return 62.0;
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
    if ([users count] > 0) {
        if (row < [users count])
        {
            UserTableCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UserTableCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[UserTableCell class]]) {
                        cell = (UserTableCell *)o;
                        break;
                    }
                }
            }
            Depart *d = [users objectAtIndex:row];
            cell.nameENLb.text = d.PROJ_Name_En;
            cell.nameLb.text = d.PROJ_Name;
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
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [users count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Depart *d = [users objectAtIndex:row];
        UserInfoTypeTableView *infoTypeView = [[UserInfoTypeTableView alloc] init];
        infoTypeView.PROJ_Name = d.PROJ_Name;
        infoTypeView.titleStr = d.PROJ_Name_En;
        infoTypeView.userId = d.ID;
        infoTypeView.projId = d.Proj_ID;
        infoTypeView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:infoTypeView animated:YES];
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

- (IBAction)searchAction:(id)sender {
    AllInOneSearchView *searchView = [[AllInOneSearchView alloc] init];
    searchView.searchType = @"UserInfo";
    searchView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchView animated:YES];
}

@end
