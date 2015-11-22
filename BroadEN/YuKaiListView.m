//
//  WeiXiuView.m
//  Broad
//
//  Created by 赵腾欢 on 15/9/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "YuKaiListView.h"
#import "Invoice.h"
#import "WeiXiuCell.h"
#import "YuKaiAddView.h"
#import "YuKaiDetailView.h"

@interface YuKaiListView ()
{
    NSArray *weixiuArray;
}

@end

@implementation YuKaiListView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.text = @"预开发票列表";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForTitle];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 58, 44);
    [addBtn setTitle:@"新增" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableReload) name:@"Notification_YuKaiListReLoad" object:nil];
}

- (void)tableReload
{
    [self getData];
}

- (void)add
{
    YuKaiAddView *addView = [[YuKaiAddView alloc] init];
    [self.navigationController pushViewController:addView animated:YES];
}

- (void)getData
{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSString *sqlStr = [NSString stringWithFormat:@"select * From TB_CUST_ProjInf_Invoice Where PROJ_ID='%@' order by App_Date desc",app.depart.PROJ_ID];
    
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
        
        NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        weixiuArray = [Tool readJsonToObjArray:table andObjClass:[Invoice class]];
        
        [self.tableView reloadData];
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - tableView代理事件
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return weixiuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([weixiuArray count] > 0)
    {
        WeiXiuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiXiuCell"];
        if (!cell)
        {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WeiXiuCell" owner:self options:nil];
            for (NSObject *o in objects)
            {
                if ([o isKindOfClass:[WeiXiuCell class]])
                {
                    cell = (WeiXiuCell *)o;
                    break;
                }
            }
        }
        
        Invoice *invoice = weixiuArray[indexPath.row];
        
        cell.name_label.text = [NSString stringWithFormat:@"申请人:%@",invoice.App_Name];
        cell.type_label.text = [NSString stringWithFormat:@"协议编号:%@",invoice.CONTR_No];
        cell.no_label.text = [NSString stringWithFormat:@"开票金额:%f",invoice.App_InvoiceAMT];
        
        if(invoice.App_Date.length > 0)
        {
            NSString *timeStr = [invoice.App_Date substringToIndex:[invoice.App_Date rangeOfString:@" "].location];
            
            if(timeStr)
            {
                cell.time_label.text = [NSString stringWithFormat:@"申请日期:%@",timeStr];
            }
            else
            {
                cell.time_label.text = @"申请日期:未知";
            }
        }
        else
        {
            cell.time_label.text = @"申请日期:未知";
        }
        return cell;
    }
    else
    {
        return [[EndCellUtils Instance] getLoadEndCell:tableView andLoadOverString:@"暂无数据"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    //点击“下面20条”
    if (row >= [weixiuArray count])
    {
    }
    else
    {
        YuKaiDetailView *detailsView = [[YuKaiDetailView alloc] init];
        detailsView.invoice = weixiuArray[row];
        [self.navigationController pushViewController:detailsView animated:YES];
    }
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
