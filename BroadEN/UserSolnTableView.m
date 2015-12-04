//
//  UserSolnTableView.m
//  BroadEN
//
//  Created by Seven on 15/12/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserSolnTableView.h"
#import "SolnMgtTableCell.h"
#import "SolnMgt.h"
#import "SolnMgtDetailView.h"

@interface UserSolnTableView ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *mgts;
}

@end

@implementation UserSolnTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Soln Mgt List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getSolnData];
}

- (void)getSolnData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select row_number() over(order by Exec_Date desc ) as rowid,*,allfileView=dbo.fn_GetFileView(allfilename) from TB_CUST_ProjInf_SolutionMgmt where proj_id='%@'", self.projId];
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
            mgts = [Tool readJsonToObjArray:jsonArray andObjClass:[SolnMgt class]];
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
    return mgts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 107.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
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
//    cell.ececManLb.text = s.Exec_ManEn;
    cell.ececManLb.text = s.Exec_Man;
    cell.execDateLb.text = s.Exec_Date;
    cell.unitModeLb.text = s.AirCondUnit_Mode;
    cell.serialNumLb.text = s.OutFact_Num;
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger row = [indexPath row];
    SolnMgt *s = [mgts objectAtIndex:row];
    SolnMgtDetailView *detailView = [[SolnMgtDetailView alloc] init];
    detailView.ID = s.ID;
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
