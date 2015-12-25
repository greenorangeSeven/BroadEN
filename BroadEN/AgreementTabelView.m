//
//  AgreementTabelView.m
//  BroadEN
//
//  Created by Seven on 15/12/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "AgreementTabelView.h"
#import "AgreementTableCell.h"
#import "Agreement.h"
#import "AgreementDetailView.h"

@interface AgreementTabelView ()<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>
{
    NSArray *agreements;
}

@end

@implementation AgreementTabelView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Agreement Mgt List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getAgreementData];
}

- (void)getAgreementData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select row_number() over(order by A.Agt_Judm_Date desc ) as rowid,* from TB_CUST_ProjInf_ServAgt A where A.proj_id='%@'",self.projId];
    
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
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:request.hud];
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
        NSLog(string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        agreements = [Tool readJsonToObjArray:jsonArray andObjClass:[Agreement class]];
        if ([agreements count] > 0) {
            [self.tableView reloadData];
        }
        else
        {
            [Tool showCustomHUD:@"NO DATA" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return agreements.count;
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
    NSInteger row = [indexPath row];
    Agreement *a = [agreements objectAtIndex:row];
    cell.PROJ_Name_EnLb.text = self.PROJ_Name_En;
    cell.Agt_NoLb.text = a.Agt_No;
    cell.OutFact_NumLb.text = a.OutFact_Num;
    cell.Agt_Std_AmtLb.text = [NSString stringWithFormat:@"%@万元", a.Agt_Amt];
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    Agreement *a = [agreements objectAtIndex:row];
    AgreementDetailView *detailView = [[AgreementDetailView alloc] init];
    detailView.agreement = a;
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
