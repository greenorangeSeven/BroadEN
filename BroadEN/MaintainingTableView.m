//
//  MaintainingTableView.m
//  BroadEN
//
//  Created by Seven on 15/11/26.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MaintainingTableView.h"
#import "UserSecurity.h"
#import "Maintaining.h"
#import "MaintainingTableCell.h"
#import "MaintainingAddView.h"
#import "MaintauningDetailView.h"

@interface MaintainingTableView ()
{
    UserInfo *userinfo;
    NSArray *maintains;
    
    NSString *jiaose;
}

@end

@implementation MaintainingTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Maintaining";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    jiaose = userinfo.JiaoSe;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMaintainingData) name:@"Notification_MaintainingListReLoad" object:nil];
    
    [self getSecurity];
}

- (void)getSecurity
{
    //%%为转义%
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModuleLike_En '%@','DA03%%'", userinfo.JiaoSe];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSecurity:)];
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

- (void)requestSecurity:(ASIHTTPRequest *)request
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
        NSArray *securityList = [Tool readJsonToObjArray:jsonArray andObjClass:[UserSecurity class]];
        BOOL haveQueryRecord = NO;
        for (UserSecurity *s in securityList) {
            if ([s.ModuleCode isEqualToString:@"DA0301"] && [s.PermissionName isEqualToString:@"新建"]) {
                if([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"])
                {
                    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithTitle: @"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addAction:)];
                    self.navigationItem.rightBarButtonItem = addBtn;
                }
            }
            if ([s.ModuleCode isEqualToString:@"DA0301"] && [s.PermissionName isEqualToString:@"查看"]) {
                haveQueryRecord = YES;
            }
        }
        if (haveQueryRecord) {
            [self getMaintainingData];
        }
        else
        {
            [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getMaintainingData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select row_number() over(order by UploadTime desc ) as rowid, ID,Proj_ID,Exec_Man_En,Exec_Date,UploadTime,OutFact_Num,AirCondUnit_Mode,Type_En,Project_En from TB_CUST_ProjInf_MatnRec where Proj_ID='%@'", self.projId];
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
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if([jsonArray count] > 0)
        {
            maintains = [Tool readJsonToObjArray:jsonArray andObjClass:[Maintaining class]];
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
    return maintains.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 236.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MaintainingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:MaintainingTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MaintainingTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[MaintainingTableCell class]]) {
                cell = (MaintainingTableCell *)o;
                break;
            }
        }
    }
    NSInteger row = [indexPath row];
    Maintaining *m = [maintains objectAtIndex:row];
    cell.ExecutorLb.text = m.Exec_Man_En;
    cell.UploadDateLb.text = m.UploadTime;
    cell.UnitModelLb.text = m.AirCondUnit_Mode;
    cell.SerialNoLb.text = m.OutFact_Num;
    cell.ServicetypeLb.text = m.Type_En;
    cell.ItemLb.text = m.Project_En;
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    Maintaining *m = [maintains objectAtIndex:row];
    MaintauningDetailView *detailView = [[MaintauningDetailView alloc] init];
    detailView.ID = m.ID;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void)addAction:(id )sender
{
    MaintainingAddView *addView = [[MaintainingAddView alloc] init];
    addView.projId = self.projId;
    [self.navigationController pushViewController:addView animated:YES];
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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
