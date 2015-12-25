//
//  CorrespondenceTableView.m
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "CorrespondenceTableView.h"
#import "CorrespondenceCell.h"
#import "Correspondence.h"
#import "UserSecurity.h"
#import "CorrespondenceAddView.h"
#import "CorrespondenceDetailView.h"

@interface CorrespondenceTableView ()<UITableViewDelegate,UITableViewDataSource>
{
    UserInfo *userinfo;
    NSArray *correspondences;
}

@end

@implementation CorrespondenceTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Correspondence List";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCorrData) name:@"Notification_CorrespondenceListReLoad" object:nil];
    
    [self getSecurity];
}

- (void)getSecurity
{
    //%%为转义%
    NSString *sqlStr = [NSString stringWithFormat:@"exec Sp_GetPermissionByRoleNameInModule_En '%@','DA06'", userinfo.JiaoSe];
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
    [Tool showHUD:@"Loading..." andView:self.view andHUD:request.hud];
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
            if ([s.PermissionName isEqualToString:@"新建"]) {
                UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithTitle: @"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addAction:)];
                self.navigationItem.rightBarButtonItem = addBtn;
            }
            if ([s.PermissionName isEqualToString:@"查看"]) {
                haveQueryRecord = YES;
            }
        }
        if (haveQueryRecord) {
            [self getCorrData];
        }
        else
        {
            [Tool showCustomHUD:@"您无查看权限" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}


- (void)getCorrData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select row_number() over(order by A.UploadTime desc ) as rowid,ID,Uploader_En,UploadTime,dbo.fn_GetHanJianTypeEn(FileType) as FileTypeEn from Tb_CUST_ProjInf_ComeGoLetter A  where A.proj_id='%@' ORDER BY A.ID DESC", self.projId];
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
    [Tool showHUD:@"Loading..." andView:self.view andHUD:request.hud];
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
            correspondences = [Tool readJsonToObjArray:jsonArray andObjClass:[Correspondence class]];
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
    return correspondences.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CorrespondenceCell *cell = [tableView dequeueReusableCellWithIdentifier:CorrespondenceCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CorrespondenceCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[CorrespondenceCell class]]) {
                cell = (CorrespondenceCell *)o;
                break;
            }
        }
    }
    NSInteger row = [indexPath row];
    Correspondence *c = [correspondences objectAtIndex:row];
    cell.Uploader_EnLB.text = c.Uploader_En;
    cell.FileTypeEnLB.text = c.FileTypeEn;
    cell.UploadTimeLB.text = c.UploadTime;
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = [indexPath row];
    Correspondence *c = [correspondences objectAtIndex:row];
    CorrespondenceDetailView *detailView = [[CorrespondenceDetailView alloc] init];
    detailView.ID = c.ID;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void)addAction:(id )sender
{
    CorrespondenceAddView *addView = [[CorrespondenceAddView alloc] init];
    addView.projId = self.projId;
    addView.PROJ_Name = self.PROJ_Name;
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
