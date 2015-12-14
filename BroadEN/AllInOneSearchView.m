//
//  AllInOneSearchView.m
//  BroadEN
//
//  Created by Seven on 15/12/13.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "AllInOneSearchView.h"
#import "KxMenu.h"
#import "SGActionView.h"
#import "UserTableCell.h"
#import "UserInfoTypeTableView.h"
#import "ZeroHeightTableCell.h"

#import "SiteServTableCell.h"
#import "MaintauningDetailView.h"
#import "SiteServ.h"

#import "SolnMgtTableCell.h"
#import "SolnMgtDetailView.h"
#import "SolnMgt.h"

#import "SatisfaTableCell.h"
#import "SatisfaDetailView.h"
#import "Satisfa.h"

#import "MoreUnitInfoTableCell.h"
#import "UnitInfoDetailView.h"
#import "UnitInfo.h"

#import "AgreementTableCell.h"
#import "AgreementDetailView.h"
#import "Agreement.h"

#import "MoreCorrpdncTableCell.h"
#import "Correspondence.h"
#import "CorrespondenceDetailView.h"

@interface AllInOneSearchView ()<UISearchBarDelegate>
{
    NSArray *refineArray;
    UserInfo *userinfo;
    
    BOOL gNoRefresh;
    
    NSString *SearchField;
    NSString *searchString;
    
    NSString *selectServiceBranch;
    NSString *selectEngineer;
    NSString *selectCountry;
    NSString *inputSerialNo;
    NSString *selectUnitStatus;
    
    UIAlertView *serialNoDialog;
}

@end

@implementation AllInOneSearchView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    SearchField = @"All";
    searchString = @"";
    selectCountry = @"全部";
    selectUnitStatus = @"全部";
    
    self.searchBar.delegate = self;
    
    if([self.searchType isEqualToString:@"UserInfo"] || [self.searchType isEqualToString:@"SiteServ"] || [self.searchType isEqualToString:@"SolnMgt"] || [self.searchType isEqualToString:@"Agreement"])
    {
        refineArray = [[NSArray alloc] initWithObjects:@"Service Branch", @"Engineer", @"Country", @"Serial No", nil];
    }
    else if([self.searchType isEqualToString:@"Satisfa"] || [self.searchType isEqualToString:@"CorrpdncMails"])
    {
        refineArray = [[NSArray alloc] initWithObjects:@"Service Branch", @"Engineer", @"Country", nil];
    }
    else if([self.searchType isEqualToString:@"UnitInfo"])
    {
        refineArray = [[NSArray alloc] initWithObjects:@"Service Branch", @"Engineer", @"Country", @"Units Status", @"Serial No", nil];
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
    
    datas = [[NSMutableArray alloc] initWithCapacity:25];
    
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
    
    if ([Tool isStringExist:selectServiceBranch]) {
        ser_Dept = selectServiceBranch;
    }
    
    if ([Tool isStringExist:selectEngineer]) {
        Engineer = selectEngineer;
    }
    
    if([self.searchType isEqualToString:@"UserInfo"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p12 int set @p12=51 exec SP_GetProjInfoByPage_En @PageIndex='%i',@PageSize=25,@SearchField='%@',@searchString='%@',@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@Country='%@',@Franchiser='%@',@Total=@p12 output select @p12",pageIndex, SearchField, searchString,userinfo.UserName,ser_Dept,Engineer, selectCountry, Franchiser];
    }
    else if([self.searchType isEqualToString:@"SiteServ"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p17 int set @p17=0 exec SP_GetMathAirCondUnitByPage_En @PageIndex='%d',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@TimeType='服务时间',@StartTime='',@EndTime='',@Type='All',@Project='All',@Rating='All',@SearchField='%@',@SearchString='%@',@Franchiser='%@',@Total=@p17 output select @p17",pageIndex,userinfo.UserName,ser_Dept,Engineer,SearchField, searchString, Franchiser];
    }
    else if([self.searchType isEqualToString:@"SolnMgt"])
    {
         sqlStr = [NSString stringWithFormat:@"declare @p16 int set @p16=0 exec SP_GetSolutionMgmtByPage_En @PageIndex='%i',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@searchField='%@',@searchString='%@',@StartTime='',@EndTime='',@TimeType='取样时间',@ConfigType1='',@ConfigType2='',@Franchiser='%@',@Total=@p16 output select @p16",pageIndex,userinfo.UserName,ser_Dept,Engineer,SearchField, searchString, Franchiser];
    }
    else if([self.searchType isEqualToString:@"Satisfa"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p12 int set @p12=0 exec SP_GetUserHQTelFollowByPage_En  @PageIndex='%i',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@searchField='%@',@searchString='%@',@StartTime='',@EndTime='',@Franchiser='%@',@Total=@p12 output select @p12",pageIndex,userinfo.UserName,ser_Dept,Engineer,SearchField, searchString, Franchiser];
    }
    else if([self.searchType isEqualToString:@"UnitInfo"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p13 int set @p13=0 exec SP_GetUnitStatusByPage_En @PageIndex='%D',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@Country='%@',@SearchField='%@',@SearchString='%@',@UnitStatus='%@',@Franchiser='%@',@Total=@p13 output select @p13",pageIndex,userinfo.UserName,ser_Dept,Engineer,selectCountry,SearchField, searchString, selectUnitStatus, Franchiser];
    }
    else if([self.searchType isEqualToString:@"Agreement"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p15 int set @p15=1140 exec SP_GetServAgtByPage_En @PageIndex='%d',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@TimeType='签订日期',@StartTime='',@EndTime='',@AgtType='All',@Franchiser='All',@searchField='%@',@searchString='%@',@Total=@p15 output select @p15",pageIndex,userinfo.UserName,ser_Dept,Engineer,SearchField, searchString];
    }
    else if([self.searchType isEqualToString:@"CorrpdncMails"])
    {
        sqlStr = [NSString stringWithFormat:@"declare @p11 int set @p11=0 exec SP_GetComeGoLetterByPage_En @PageIndex='%d',@PageSize=25,@OrderBy=N'ID',@Sort='desc',@UserName='%@',@Ser_Dept='%@',@Engineer='%@',@StartTime='',@EndTime='',@LetterType='All',@Franchiser='All',@SearchField='%@',@SearchString='%@',@Total=@p11 output select @p11",pageIndex,userinfo.UserName,ser_Dept,Engineer,SearchField, searchString];
    }
    
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
        
        NSArray *dataNewsList = [[NSArray alloc] init];
        
        if([self.searchType isEqualToString:@"UserInfo"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[Depart class]];
        }
        else if([self.searchType isEqualToString:@"SiteServ"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[SiteServ class]];
        }
        else if([self.searchType isEqualToString:@"SolnMgt"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[SolnMgt class]];
        }
        else if([self.searchType isEqualToString:@"Satisfa"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[Satisfa class]];
        }
        else if([self.searchType isEqualToString:@"UnitInfo"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[UnitInfo class]];
        }
        else if([self.searchType isEqualToString:@"Agreement"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[Agreement class]];
        }
        else if([self.searchType isEqualToString:@"CorrpdncMails"])
        {
            dataNewsList = [Tool readJsonToObjArray:table andObjClass:[Correspondence class]];
        }
        
        isLoading = NO;
        if (!gNoRefresh) {
            [self clear];
        }
        if (dataNewsList.count < 25) {
            isLoadOver = YES;
        }
        [datas addObjectsFromArray:dataNewsList];
        allCount = [datas count];
        
        NSDictionary *dic1 = table1[0];
        NSString *counts = dic1[@"Column1"];
        self.title = [NSString stringWithFormat:@"Search(%@)",counts];
        
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
    [datas removeAllObjects];
    datas = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [datas removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return datas.count == 0 ? 1 : datas.count;
        }
        else
            return datas.count + 1;
    }
    else
        return datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    CGFloat rowHeight = 0.0;
    
    if([self.searchType isEqualToString:@"UserInfo"])
    {
        rowHeight = 62.0;
    }
    else if([self.searchType isEqualToString:@"SiteServ"])
    {
        rowHeight = 131.0;
    }
    else if([self.searchType isEqualToString:@"SolnMgt"])
    {
        rowHeight = 128.0;
    }
    else if([self.searchType isEqualToString:@"Satisfa"])
    {
        rowHeight = 85.0;
    }
    else if([self.searchType isEqualToString:@"UnitInfo"])
    {
        rowHeight = 131.0;
    }
    else if([self.searchType isEqualToString:@"Agreement"])
    {
        rowHeight = 107.0;
    }
    else if([self.searchType isEqualToString:@"CorrpdncMails"])
    {
        rowHeight = 126.0;
    }
    
    if (row < [datas count])
    {
        return rowHeight;
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
    if ([datas count] > 0) {
        if (row < [datas count])
        {
            if([self.searchType isEqualToString:@"UserInfo"])
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
                Depart *d = [datas objectAtIndex:row];
                cell.nameENLb.text = d.PROJ_Name_En;
                cell.nameLb.text = d.PROJ_Name;
                return cell;
            }
            else if([self.searchType isEqualToString:@"SiteServ"])
            {
                SiteServTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SiteServTableCellIdentifier];
                if (!cell) {
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SiteServTableCell" owner:self options:nil];
                    for (NSObject *o in objects) {
                        if ([o isKindOfClass:[SiteServTableCell class]]) {
                            cell = (SiteServTableCell *)o;
                            break;
                        }
                    }
                }
                SiteServ *s = [datas objectAtIndex:row];
                cell.nameEnLb.text = s.PROJ_Name_En;
                cell.nameLb.text = s.PROJ_Name;
                cell.outfaceNumLb.text = s.OutFact_Num;
                cell.typeLb.text = s.Type_En;
                cell.projectLb.text = s.Project_En;
                return cell;
            }
            else if([self.searchType isEqualToString:@"SolnMgt"])
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
                SolnMgt *s = [datas objectAtIndex:row];
                cell.PROJ_Name_EnLb.text = s.PROJ_Name_En;
                cell.ececManLb.text = s.Exec_Man;
                cell.execDateLb.text = s.Exec_Date;
                cell.unitModeLb.text = s.AirCondUnit_Mode;
                cell.serialNumLb.text = s.OutFact_Num;
                return cell;
            }
            else if([self.searchType isEqualToString:@"Satisfa"])
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
                
                Satisfa *s = [datas objectAtIndex:row];
                
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
            else if([self.searchType isEqualToString:@"UnitInfo"])
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
                UnitInfo *u = [datas objectAtIndex:row];
                cell.PROJ_Name_EnLb.text = u.PROJ_Name_En;
                cell.UnitModelLb.text = u.AirCondUnit_Mode;
                cell.ProductionLb.text = u.Prod_Num;
                cell.SerialLb.text = u.OutFact_Num;
                cell.DeliveryLb.text = [Tool DateTimeRemoveTime:u.Send_Date andSeparated:@" "];
                return cell;
            }
            else if([self.searchType isEqualToString:@"Agreement"])
            {
                AgreementTableCell *cell = [tableView dequeueReusableCellWithIdentifier:AgreementTableCellIdentifier];
                if (!cell) {
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"AgreementTableCell" owner:self options:nil];
                    for (NSObject *o in objects) {
                        if ([o isKindOfClass:[AgreementTableCell class]]) {
                            cell = (AgreementTableCell *)o;
                            break;
                        }
                    }
                }
                Agreement *a = [datas objectAtIndex:row];
                cell.PROJ_Name_EnLb.text = a.PROJ_Name_En;
                cell.Agt_NoLb.text = a.Agt_No;
                cell.OutFact_NumLb.text = a.OutFact_Num;
                cell.Agt_Std_AmtLb.text = [NSString stringWithFormat:@"%@万元", a.Agt_Amt];
                return cell;
            }
            else if([self.searchType isEqualToString:@"CorrpdncMails"])
            {
                MoreCorrpdncTableCell *cell = [tableView dequeueReusableCellWithIdentifier:MoreCorrpdncTableCellIdentifier];
                if (!cell) {
                    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MoreCorrpdncTableCell" owner:self options:nil];
                    for (NSObject *o in objects) {
                        if ([o isKindOfClass:[MoreCorrpdncTableCell class]]) {
                            cell = (MoreCorrpdncTableCell *)o;
                            break;
                        }
                    }
                }
                Correspondence *c = [datas objectAtIndex:row];
                cell.PROJ_Name_EnLB.text = c.PROJ_Name_En;
                cell.Uploader_EnLB.text = c.Uploader_En;
                cell.FileTypeEnLB.text = c.FileTypeEn;
                cell.UploadTimeLB.text = c.Exec_Date;
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
    if (row >= [datas count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        if([self.searchType isEqualToString:@"UserInfo"])
        {
            Depart *d = [datas objectAtIndex:row];
            UserInfoTypeTableView *infoTypeView = [[UserInfoTypeTableView alloc] init];
            infoTypeView.PROJ_Name = d.PROJ_Name;
            infoTypeView.titleStr = d.PROJ_Name_En;
            infoTypeView.userId = d.ID;
            infoTypeView.projId = d.Proj_ID;
            infoTypeView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:infoTypeView animated:YES];
        }
        else if([self.searchType isEqualToString:@"SiteServ"])
        {
            SiteServ *s = [datas objectAtIndex:row];
            MaintauningDetailView *detailView = [[MaintauningDetailView alloc] init];
            detailView.ID = s.ID;
            detailView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if([self.searchType isEqualToString:@"SolnMgt"])
        {
            SolnMgt *s = [datas objectAtIndex:row];
            SolnMgtDetailView *detailView = [[SolnMgtDetailView alloc] init];
            detailView.ID = s.ID;
            detailView.hidesBottomBarWhenPushed  = YES;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if([self.searchType isEqualToString:@"Satisfa"])
        {
            Satisfa *s = [datas objectAtIndex:row];
            SatisfaDetailView *detailView = [[SatisfaDetailView alloc] init];
            detailView.ID = s.ID;
            detailView.projId = s.PROJ_ID;
            detailView.hidesBottomBarWhenPushed  = YES;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if([self.searchType isEqualToString:@"UnitInfo"])
        {
            UnitInfo *u = [datas objectAtIndex:row];
            UnitInfoDetailView *detailView = [[UnitInfoDetailView alloc] init];
            detailView.ID = u.ID;
            detailView.PROJ_ID = u.PROJ_ID;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if([self.searchType isEqualToString:@"Agreement"])
        {
            Agreement *a = [datas objectAtIndex:row];
            AgreementDetailView *detailView = [[AgreementDetailView alloc] init];
            detailView.agreement = a;
            [self.navigationController pushViewController:detailView animated:YES];
        }
        else if([self.searchType isEqualToString:@"CorrpdncMails"])
        {
            Correspondence *c = [datas objectAtIndex:row];
            CorrespondenceDetailView *detailView = [[CorrespondenceDetailView alloc] init];
            detailView.ID = c.ID;
            [self.navigationController pushViewController:detailView animated:YES];
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

#pragma UIsearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"ShouldBeginEditing");
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"TextDidBeginEditing");
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"ShouldEndEditing");
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"TextDidEndEditing");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    SearchField = @"All";
    searchString = @"";
    selectServiceBranch = @"";
    selectEngineer = @"";
    selectCountry = @"全部";
    selectUnitStatus = @"全部";
    
    NSLog(@"SearchButtonClicked");
    SearchField = @"CustomerName";
    searchString = searchBar.text;
    isLoadOver = NO;
    [self reload:NO];
    [searchBar resignFirstResponder];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)refineSearchAction:(UIButton *)sender {
    SearchField = @"All";
    searchString = @"";
    selectServiceBranch = @"";
    selectEngineer = @"";
    selectCountry = @"全部";
    selectUnitStatus = @"全部";
    
    self.searchBar.text = @"";
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    KxMenuItem *first = [KxMenuItem menuItem:@"Refine:"
                                       image:nil
                                      target:nil
                                         tag:nil
                                      action:NULL];
    [menuItems addObject:first];
    for (int i = 0; i < [refineArray count]; i++) {
        NSString *itemStr = [refineArray objectAtIndex:i];
        KxMenuItem *item = [KxMenuItem menuItem:itemStr
                                          image:nil
                                         target:self
                                            tag:[NSString stringWithFormat:@"%d", i]
                                         action:@selector(clickRefineMenuItem:)];
        [menuItems addObject:item];
    }
    
    KxMenuItem *first1 = menuItems[0];
    first1.foreColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0];
    first1.alignment = NSTextAlignmentCenter;
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (void)clickRefineMenuItem:(id)sender
{
    KxMenuItem *item = sender;
    int tag = [item.tag intValue];
    NSString *menuValueStr = [refineArray objectAtIndex:tag];
    if ([menuValueStr isEqualToString:@"Service Branch"]) {
        [self selectServiceBranch];
    }
    else if([menuValueStr isEqualToString:@"Engineer"])
    {
        [self selectEngineer];
    }
    else if([menuValueStr isEqualToString:@"Country"])
    {
        [self selectCountry];
    }
    else if([menuValueStr isEqualToString:@"Serial No"])
    {
        [self inputSerialNo];
    }
    else if([menuValueStr isEqualToString:@"Units Status"])
    {
        [self selectUnitStatus];
    }
}

- (void)selectServiceBranch
{
    NSString *sql = [NSString stringWithFormat:@"exec sp_eFiles_Init_Parameter_Get_Serv_Dept_En '%@','查询服务部'", userinfo.UserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestServiceBranch:)];
    [request startAsynchronous];
}

- (void)requestServiceBranch:(ASIHTTPRequest *)request
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
        NSMutableArray *BranchENs = [[NSMutableArray alloc] init];
        NSMutableArray *BranchCNs = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [BranchENs addObject:jsonDic[@"mc"]];
            [BranchCNs addObject:jsonDic[@"CNName"]];
        }
        [SGActionView showSheetWithTitle:@"Please Select" itemTitles:BranchENs itemSubTitles:nil selectedIndex:-1 selectedHandle:^(NSInteger index){
            NSDictionary *dic = jsonArray[index];
            selectServiceBranch = dic[@"CNName"];
            isLoadOver = NO;
            [self reload:NO];
        }];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)selectEngineer
{
    NSString *sql = [NSString stringWithFormat:@"exec sp_eFiles_Init_Parameter_Get_Duty_Engineer_En '%@','查询服务部'", userinfo.UserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestEngineer:)];
    [request startAsynchronous];
}

- (void)requestEngineer:(ASIHTTPRequest *)request
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
        NSMutableArray *EngineerENs = [[NSMutableArray alloc] init];
        NSMutableArray *EngineerCNs = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [EngineerENs addObject:jsonDic[@"mc_En"]];
            [EngineerCNs addObject:jsonDic[@"mc"]];
        }
        [SGActionView showSheetWithTitle:@"Please Select" itemTitles:EngineerENs itemSubTitles:nil selectedIndex:-1 selectedHandle:^(NSInteger index){
            NSDictionary *dic = jsonArray[index];
            selectEngineer = dic[@"mc"];
            isLoadOver = NO;
            [self reload:NO];
        }];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)selectCountry
{
    NSString *sql = [NSString stringWithFormat:@"exec GetCountryNameList_EN '%@'", userinfo.UserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCountry:)];
    [request startAsynchronous];
}

- (void)requestCountry:(ASIHTTPRequest *)request
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
        NSMutableArray *CountryENs = [[NSMutableArray alloc] init];
        NSMutableArray *CountryCNs = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [CountryENs addObject:jsonDic[@"CountryNameEn"]];
            [CountryCNs addObject:jsonDic[@"CountryName"]];
        }
        [SGActionView showSheetWithTitle:@"Please Select" itemTitles:CountryENs itemSubTitles:nil selectedIndex:-1 selectedHandle:^(NSInteger index){
            NSDictionary *dic = jsonArray[index];
            selectCountry = dic[@"CountryName"];
            
            if([self.searchType isEqualToString:@"SiteServ"] || [self.searchType isEqualToString:@"SolnMgt"] || [self.searchType isEqualToString:@"Satisfa"] || [self.searchType isEqualToString:@"Agreement"] || [self.searchType isEqualToString:@"CorrpdncMails"])
            {
                SearchField = @"Country";
                searchString = dic[@"CountryName"];
            }
            isLoadOver = NO;
            [self reload:NO];
        }];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)selectUnitStatus
{
    NSString *sql = @"select distinct  AirCondUnit_State ,AirCondUnit_State_En   from Tb_CUST_ProjInf_AirCondUnit";
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestUnitStatus:)];
    [request startAsynchronous];
}

- (void)requestUnitStatus:(ASIHTTPRequest *)request
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
        NSMutableArray *StateENs = [[NSMutableArray alloc] init];
        NSMutableArray *StateCNs = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [StateENs addObject:jsonDic[@"AirCondUnit_State_En"]];
            [StateCNs addObject:jsonDic[@"AirCondUnit_State"]];
        }
        [SGActionView showSheetWithTitle:@"Please Select" itemTitles:StateENs itemSubTitles:nil selectedIndex:-1 selectedHandle:^(NSInteger index){
            NSDictionary *dic = jsonArray[index];
            selectUnitStatus = dic[@"AirCondUnit_State"];
            isLoadOver = NO;
            [self reload:NO];
        }];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)inputSerialNo
{
    serialNoDialog = [[UIAlertView alloc] initWithTitle:@"Serial No" message:@"Please Write Serial No" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:@"cancel",nil];
    serialNoDialog.tag = 2;
    [serialNoDialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[serialNoDialog textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [serialNoDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 2)
        {
            serialNoDialog = nil;
            [self.view endEditing:YES];
            UITextField *serialNoField = [alertView textFieldAtIndex:0];
            if (serialNoField.text.length == 0) {
                [self performSelector:@selector(inputSerialNo) withObject:nil afterDelay:0.8f];
                [Tool showCustomHUD:@"Please Write Serial No" andView:self.view andImage:nil andAfterDelay:1.2f];
            }
            else
            {
                inputSerialNo = serialNoField.text;
                SearchField = @"OutFact_Num";
                searchString = serialNoField.text;
                isLoadOver = NO;
                [self reload:NO];
            }
        }
    }
}

@end
