//
//  UnitInfoTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UnitInfoTableView.h"
#import "UnitInfoTableCell.h"
#import "UnitInfo.h"
#import "UnitInfoDetailView.h"

@interface UnitInfoTableView ()

@end

@implementation UnitInfoTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Unit Info";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getData];
}

- (void)getData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select row_number() over(order by (select 0) desc) as rowid,a.*,b.Duty_Engineer,b.Duty_Engineer_En,StopUse='申请停用',Cancel='申请注销'  from Tb_CUST_ProjInf_AirCondUnit as a left Outer Join TB_CUST_ProjInf as b on a.proj_id=b.PROJ_ID  where b.ID='%@'",self.ID];
    
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
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
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
        
        if([jsonArray count] > 0)
        {
            units = [Tool readJsonToObjArray:jsonArray andObjClass:[UnitInfo class]];
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
    return units.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 174.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UnitInfoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitInfoTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UnitInfoTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[UnitInfoTableCell class]]) {
                cell = (UnitInfoTableCell *)o;
                break;
            }
        }
    }
    NSInteger row = [indexPath row];
    UnitInfo *u = [units objectAtIndex:row];
    cell.UnitModelLb.text = u.AirCondUnit_Mode;
    cell.ProductionLb.text = u.Prod_Num;
    cell.SerialLb.text = u.OutFact_Num;
    cell.DeliveryLb.text = [Tool DateTimeRemoveTime:u.Send_Date andSeparated:@" "];
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    UnitInfo *u = [units objectAtIndex:row];
    UnitInfoDetailView *detailView = [[UnitInfoDetailView alloc] init];
    detailView.ID = u.ID;
    detailView.PROJ_ID = u.PROJ_ID;
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
