//
//  MoreListView.m
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MoreListView.h"
#import "ItemTableCell.h"
#import "SettingModel.h"
#import "UserSecurity.h"
#import "MoreUnitInfoTableView.h"
#import "MoreAgreementTableView.h"
#import "MoreCorrpdncTableView.h"
#import "MyWorkTableView.h"
#import "SettingView.h"
#import "HelpAndSupportView.h"
#import "LoginView.h"
#import "SolnMgtTableView.h"

@interface MoreListView ()
{
    NSMutableArray *items;
    UserInfo *userinfo;
}

@end

@implementation MoreListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"More";
    self.tabBarItem.title = @"more";
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    items = [[NSMutableArray alloc] initWithObjects:
             [[SettingModel alloc] initWith:@"Unit Info" andImg:@"more_userinfo" andTag:1 andTitle2:nil],
             //             [[SettingModel alloc] initWith:@"My Work" andImg:@"more_mywork" andTag:4 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Soln Mgt" andImg:@"tab_SolnMgt" andTag:4 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Settings" andImg:@"more_setting" andTag:5 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Help and Support" andImg:@"more_help" andTag:6 andTitle2:nil],
             [[SettingModel alloc] initWith:@"Log Out" andImg:nil andTag:7 andTitle2:nil],
             nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getSecurity];
}

- (void)getSecurity
{
    //%%为转义%
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModuleLike_En '%@','%%'", userinfo.JiaoSe];
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
        BOOL haveQueryAgreement = NO;
        BOOL haveQueryCorrpdnc = NO;
        for (UserSecurity *s in securityList) {
            if ([s.ModuleCode isEqualToString:@"DQ10"] && [s.PermissionName isEqualToString:@"查看"]) {
                haveQueryAgreement = YES;
            }
            if ([s.ModuleCode isEqualToString:@"DQ09"] && [s.PermissionName isEqualToString:@"查看"]) {
                haveQueryCorrpdnc = YES;
            }
        }
        
        SettingModel *agreement = [[SettingModel alloc] initWith:@"Agreement Mgt" andImg:@"more_agreement" andTag:2 andTitle2:nil];
        SettingModel *corrpdnc = [[SettingModel alloc] initWith:@"Corrpdnc Mails" andImg:@"more_corrpdnc" andTag:3 andTitle2:nil];
        
        if (haveQueryAgreement) {
            [items insertObject:agreement atIndex:1];
        }
        if (haveQueryAgreement && haveQueryAgreement) {
            [items insertObject:corrpdnc atIndex:2];
        }
        if (!haveQueryAgreement && haveQueryAgreement) {
            [items insertObject:corrpdnc atIndex:1];
        }
        [self.tableView reloadData];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingModel *action = [items objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
        case 1:
        {
            MoreUnitInfoTableView *unitInfoTableView = [[MoreUnitInfoTableView alloc] init];
            unitInfoTableView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:unitInfoTableView animated:YES];
        }
            break;
        case 2:
        {
            MoreAgreementTableView *agreementTableView = [[MoreAgreementTableView alloc] init];
            agreementTableView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:agreementTableView animated:YES];
        }
            break;
        case 3:
        {
            MoreCorrpdncTableView *corrpdncTableView = [[MoreCorrpdncTableView alloc] init];
            corrpdncTableView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:corrpdncTableView animated:YES];
        }
            break;
        case 4:
        {
            //            MyWorkTableView *myWorkView = [[MyWorkTableView alloc] init];
            //            myWorkView.hidesBottomBarWhenPushed = YES;
            //            [self.navigationController pushViewController:myWorkView animated:YES];
            SolnMgtTableView *solnMgtView = [[SolnMgtTableView alloc] init];
            solnMgtView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:solnMgtView animated:YES];
        }
            break;
        case 5:
        {
            SettingView *settingsView = [[SettingView alloc] init];
            settingsView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingsView animated:YES];
        }
            break;
        case 6:
        {
            HelpAndSupportView *helpView = [[HelpAndSupportView alloc] init];
            helpView.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:helpView animated:YES];
        }
            break;
        case 7:
        {
            LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
            AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            appdele.window.rootViewController = loginView;
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ItemTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ItemTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ItemTableCell class]]) {
                cell = (ItemTableCell *)o;
                break;
            }
        }
    }
    
    NSUInteger row = [indexPath row];
    SettingModel *model = [items objectAtIndex:row];
    cell.imgIv.image = [UIImage imageNamed:model.img];
    cell.titleLb.text = model.title;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([model.title isEqualToString:@"Log Out"]) {
        cell.titleLb.textAlignment = UITextAlignmentCenter;
        cell.titleLb.textColor = [UIColor redColor];
    }
    else
    {
        cell.titleLb.textAlignment = UITextAlignmentLeft;
        cell.titleLb.textColor = [Tool getColorForMain];
    }
    
    return cell;
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
