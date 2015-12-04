//
//  UserSatisfaTableView.m
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserSatisfaTableView.h"
#import "SatisfaTableCell.h"
#import "Satisfa.h"
#import "SatisfaDetailView.h"

@interface UserSatisfaTableView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *satisfas;
}

@end

@implementation UserSatisfaTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Satisfa List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getSatisfaData];
}

- (void)getSatisfaData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select  row_number() over(order by Follow_Date desc ) as rowid,T.ID,T.proj_id,T.Prod_OverallMerit,T.Serv_OverallMerit,P.Duty_Engineer_En,dbo.fn_GetEnName(T.Follow_Name) as Follow_NameEn from TB_CUST_ProjInf_UserHQ_TelFollow as T,TB_CUST_ProjInf as P where T.proj_id = P.PROJ_ID and P.PROJ_ID='%@'", self.projId];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
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
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if([jsonArray count] > 0)
        {
            satisfas = [Tool readJsonToObjArray:jsonArray andObjClass:[Satisfa class]];
            [self.tableView reloadData];
            
        }
        else
        {
            [Tool showCustomHUD:@"NO DATA" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return satisfas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
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
    
    cell.nameEnLb.text = s.Follow_NameEn;
    cell.prodLb.text = s.Prod_OverallMerit_EN;
    cell.servLb.text = s.Serv_OverallMerit_EN;
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = [indexPath row];
    Satisfa *s = [satisfas objectAtIndex:row];
    SatisfaDetailView *detailView = [[SatisfaDetailView alloc] init];
    detailView.ID = s.ID;
    detailView.projId = self.projId;
    [self.navigationController pushViewController:detailView animated:YES];
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
