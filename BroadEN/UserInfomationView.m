//
//  UserInfomationView.m
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserInfomationView.h"

@interface UserInfomationView ()
{
    UserInfo *userinfo;
}

@end

@implementation UserInfomationView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Personal information";
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    [self getUserInfomation];
}

- (void)getUserInfomation
{
    NSString *sqlStr = [NSString stringWithFormat:@"select dbo.fn_GetEnRoleName(R.RoleName) as RoleNameEn,dbo.fn_GetEnDepartmentName(U.TrueName) as DepartmentEn,dbo.fn_GetEnZhiWeiName(U.ZhiWei) as ZhiWeiEn, U.* from ERPUser as U ,Roles_En as R where U.JiaoSe=R.RoleCode and U.ID=%@", userinfo.ID];
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
        NSLog(@"%@", string);
        NSArray *jsonArray =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonArray && [jsonArray count] > 0) {
            UserInfo *userinfomation = [Tool readJsonDicToObj:jsonArray[0] andObjClass:[UserInfo class]];
            self.UserNameLB.text = userinfomation.UserName;
            self.TrueNameLB.text = userinfomation.TrueName;
            self.SerilsLB.text = userinfomation.Serils;
            self.DepartmentEnLB.text = userinfomation.DepartmentEn;
            self.RoleNameEnLB.text = userinfomation.RoleNameEn;
            self.ZhiWeiEnLB.text = userinfomation.ZhiWeiEn;
            self.IfLoginLB.text = [self CNTOEN:userinfomation.IfLogin];
            self.BackInfoTV.text = userinfomation.BackInfo;
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (NSString *)CNTOEN:(NSString *)CN
{
    NSString *EN = @"";
    if (CN && CN.length > 0) {
        if ([CN isEqualToString:@"是"]) {
            EN = @"YES";
        }
        else if ([CN isEqualToString:@"否"]) {
            EN = @"NO";
        }
    }
    return EN;
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
