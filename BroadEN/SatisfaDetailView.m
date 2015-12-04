//
//  SatisfaDetailView.m
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SatisfaDetailView.h"
#import "Satisfa.h"
#import "UnitInfo.h"
#import "SatisfaUnitTableCell.h"

@interface SatisfaDetailView ()<UITableViewDelegate,UITableViewDataSource>
{
    Satisfa *satisfa;
    NSArray *units;
}

@end

@implementation SatisfaDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Satisfa Message";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getSatisfaDetailData];
}

- (void)getSatisfaDetailData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select P.PROJ_Name,P.PROJ_Name_En,P.Serv_Dept,P.Serv_Dept_En,P.Duty_Engineer,P.Duty_Engineer_En, dbo.fn_GetEnName(F.Follow_Name) as Follow_Name_En,dbo.fn_GetEnName(F.UserHQ_Sign) as UserHQ_Sign_En,dbo.fn_GetEnName(F.Serv_Dept_Sign) as Serv_Dept_Sign_En, dbo.fn_GetEnName(F.Engineer_Sign) as Engineer_Sign_En,dbo.fn_GetEnName(F.UserHQ_Confirm_Sign) as UserHQ_Confirm_Sign_En, F.* FROM [TB_CUST_ProjInf_UserHQ_TelFollow] as F,TB_CUST_ProjInf as P where F.Proj_ID=P.PROJ_ID and F.ID='%@'; SELECT OutFact_Num,AirCondUnit_Mode  FROM Tb_CUST_ProjInf_AirCondUnit Where PROJ_ID='%@' order by FirstDebug_Date asc;", self.ID, self.projId];
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
    [Tool showHUD:@"加载中..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
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
        [Tool showCustomHUD:@"连接失败" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(@"%@", string);
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonDic) {
            NSArray *tableArray = [jsonDic objectForKey:@"Table"];
            if ([tableArray count] > 0) {
                satisfa = [Tool readJsonDicToObj:tableArray[0] andObjClass:[Satisfa class]];
            }
            NSArray *table1Array = [jsonDic objectForKey:@"Table1"];
            if ([table1Array count] > 0) {
                units = [Tool readJsonToObjArray:table1Array andObjClass:[UnitInfo class]];
                [self.tableView reloadData];
            }
            [self bindData];
            [self getStateData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindData
{
    self.PROJ_Name_EnLB.text = satisfa.PROJ_Name_En;
    self.Engineer_Sign_EnLB.text = satisfa.Engineer_Sign_En;
    self.Follow_Name_EnLB.text = satisfa.Follow_Name_En;
    self.Follow_DateLB.text = [Tool DateTimeRemoveTime:satisfa.Follow_Date andSeparated:@" "];
    
    self.Run_ReliabilityLB.text = [self CNTOEN:satisfa.Run_Reliability];
    self.Handle_easeLB.text = [self CNTOEN:satisfa.Handle_ease];
    self.Run_resultLB.text = [self CNTOEN:satisfa.Run_result];
    self.Prod_OverallMeritLB.text = [self CNTOEN:satisfa.Prod_OverallMerit];
    self.Save_EnergyLB.text = [self CNTOEN:satisfa.Save_Energy];
    
    self.Serv_NormalizationLB.text = [self CNTOEN:satisfa.Serv_Normalization];
    self.Locale_GuideLB.text = [self CNTOEN:satisfa.Locale_Guide];
    self.Serv_AtitudeLB.text = [self CNTOEN:satisfa.Serv_Atitude];
    self.Serv_TimelinesLB.text = [self CNTOEN:satisfa.Serv_Timelines];
    self.Serv_Tech_LevelLB.text = [self CNTOEN:satisfa.Serv_Tech_Level];
    self.Serv_OverallMeritLB.text = [self CNTOEN:satisfa.Serv_OverallMerit];
    
    self.CUST_SugstTV.text = satisfa.CUST_Sugst;
    
    self.UserHQ_SugstTV.text = satisfa.UserHQ_Sugst;
    self.UserHQ_Sign_EnLB.text = satisfa.UserHQ_Sign_En;
    self.UserHQ_SignDateLB.text = satisfa.UserHQ_SignDate;
    
    self.Serv_Dept_SugstTV.text = satisfa.Serv_Dept_Sugst;
    self.Serv_Dept_SignLB.text = satisfa.Serv_Dept_Sign;
    self.Serv_Dept_SignDateLB.text = satisfa.Serv_Dept_SignDate;
    
    self.Engineer_SugstTV.text = satisfa.Engineer_Sugst;
    self.Engineer_SignLB.text = satisfa.Engineer_Sign;
    self.Engineer_SignDateLB.text = satisfa.Engineer_SignDate;
    
    self.UserHQ_ConfirmTV.text = satisfa.UserHQ_Confirm;
    self.UserHQ_Confirm_SignLB.text = satisfa.UserHQ_Confirm_Sign;
    self.UserHQ_Confirm_SignDateLB.text = satisfa.UserHQ_Confirm_SignDate;
}

- (void)getStateData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select AirCondUnit_State  FROM Tb_CUST_ProjInf_AirCondUnit  where PROJ_ID='%@'", self.projId];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestState:)];
    [request startAsynchronous];
}

- (void)requestState:(ASIHTTPRequest *)request
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
        NSString *state = @"";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(@"%@", string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        for (NSDictionary *dic in jsonArray) {
            state = [dic objectForKey:@"AirCondUnit_State"];
        }
        
        NSString *Prod_OverallMeritEN = [self CNTOEN:satisfa.Prod_OverallMerit];
        NSString *Serv_OverallMeritEN = [self CNTOEN:satisfa.Serv_OverallMerit];
        if([state isEqualToString:@"已运行"])
        {
            if ([Prod_OverallMeritEN isEqualToString:@"Poor"] || [Prod_OverallMeritEN isEqualToString:@"Bad"] || [Prod_OverallMeritEN isEqualToString:@"Very Bad"] || [Serv_OverallMeritEN isEqualToString:@"Poor"] || [Serv_OverallMeritEN isEqualToString:@"Bad"] || [Serv_OverallMeritEN isEqualToString:@"Very Bad"]) {
                self.UserHQConfirmOpinionView.hidden = NO;
            }
            else
            {
                self.UserHQConfirmOpinionView.hidden = YES;
                
                CGRect footerFrame = self.footerView.frame;
                footerFrame.size.height = footerFrame.size.height -192;
                self.footerView.frame = footerFrame;
                
                self.tableView.tableFooterView = self.footerView;
            }
        }
        else if ([state isEqualToString:@""])
        {
            if ([Serv_OverallMeritEN isEqualToString:@"Poor"] || [Serv_OverallMeritEN isEqualToString:@"Bad"] || [Serv_OverallMeritEN isEqualToString:@"Very Bad"]) {
                self.UserHQConfirmOpinionView.hidden = NO;
            }
            else
            {
                self.UserHQConfirmOpinionView.hidden = YES;
                CGRect footerFrame = self.footerView.frame;
                footerFrame.size.height = footerFrame.size.height -192;
                self.footerView.frame = footerFrame;
                
                self.tableView.tableFooterView = self.footerView;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return units.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    SatisfaUnitTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SatisfaUnitTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SatisfaUnitTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[SatisfaUnitTableCell class]]) {
                cell = (SatisfaUnitTableCell *)o;
                break;
            }
        }
    }
    
    UnitInfo *u = [units objectAtIndex:row];
    
    cell.AirCondUnit_ModeLB.text = u.AirCondUnit_Mode;
    cell.OutFact_NumLB.text = u.OutFact_Num;
    
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)CNTOEN:(NSString *)CN
{
    NSString *EN = @"";
    if (CN && CN.length > 0) {
        if ([CN isEqualToString:@"好"]) {
            EN = @"Excellent";
        }
        else if ([CN isEqualToString:@"较好"]) {
            EN = @"Good";
        }
        else if ([CN isEqualToString:@"一般"]) {
            EN = @"Poor";
        }
        else if ([CN isEqualToString:@"较差"]) {
            EN = @"Bad";
        }
        else if ([CN isEqualToString:@"差"]) {
            EN = @"Very Bad";
        }
    }
    return EN;
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
