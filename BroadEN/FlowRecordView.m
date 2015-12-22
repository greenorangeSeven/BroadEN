//
//  FlowRecordView.m
//  BroadEN
//
//  Created by Seven on 15/12/18.
//  Copyright © 2015年 greenorange. All rights reserved.
//

#import "FlowRecordView.h"
#import "FlowRecordItem.h"
#import "FlowRecordCell.h"

@interface FlowRecordView ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *recordArray;
}

@end

@implementation FlowRecordView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Flow Record";
    
    recordArray = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getFlowRecord];
}

- (void)getFlowRecord
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetFlowProcessingRecords_En '%@'", self.Mark];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFlowRecord:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestFlowRecord:(ASIHTTPRequest *)request
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
            recordArray = [Tool readJsonToObjArray:jsonArray andObjClass:[FlowRecordItem class]];
            [self.tableView reloadData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return recordArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    FlowRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:FlowRecordCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"FlowRecordCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[FlowRecordCell class]]) {
                cell = (FlowRecordCell *)o;
                break;
            }
        }
    }
    cell.numLb.text = [NSString stringWithFormat:@"%d" ,(int)row + 1];
    cell.numLb.layer.masksToBounds=YES;
    cell.numLb.layer.cornerRadius = cell.numLb.frame.size.width/2;
    if (row == 0) {
        cell.topLineLb.hidden = YES;
    }
    if (row == recordArray.count - 1) {
        cell.bottomLineLb.hidden = YES;
    }
    FlowRecordItem *f = [recordArray objectAtIndex:row];
    cell.StepNameLb.text = f.StepName;
    cell.OwnerUserNameLb.text = f.OwnerUserName;
    cell.ActionNameLb.text = f.ActionName;
    cell.DataLb.text = f.Data;
    return cell;
    
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
