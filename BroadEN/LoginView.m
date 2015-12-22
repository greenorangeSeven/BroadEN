//
//  LoginView.m
//  Broad
//  登录界面
//  Created by 赵腾欢 on 15/8/30.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "LoginView.h"
#import "AppDelegate.h"
#import "DES.h"
#import "UsersTableView.h"
#import "SiteServTableView.h"
#import "SolnMgtTableView.h"
#import "SatisfaTableView.h"
#import "MoreListView.h"
#import "MyWorkTableView.h"

@interface LoginView ()<NSXMLParserDelegate>
{
    UIWebView *phoneCallWebView;
    MBProgressHUD *hud;
    UserInfo *userinfo;
}
@end

@implementation LoginView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"登录";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    self.navigationController.navigationBarHidden = YES;
    //设置按钮带圆角
    [self.loginBtn.layer setCornerRadius:4.0f];
    [self.contactBtn.layer setCornerRadius:4.0f];
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

- (IBAction)loginAction:(id)sender
{
    NSString *username = self.usernameField.text;
    NSString *pwd = self.pwdField.text;
    if(username.length == 0)
    {
        [Tool showCustomHUD:@"请输入用户名" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if(pwd.length == 0)
    {
        [Tool showCustomHUD:@"请输入密码" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    //隐藏键盘
    [self.view endEditing:YES];
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_SYS_Login_Get_UserInfAll '%@'",username];
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
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
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
    
    NSLog(@"the log:%@",request.responseString);
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    utils.parserFail = ^()
    {
        hud.hidden = YES;
        [Tool showCustomHUD:@"Login Failure" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *userArray = [Tool readJsonToObjArray:jsonArray andObjClass:[UserInfo class]];
        if(userArray && userArray.count > 0)
        {
            userinfo = userArray[0];
            
            //DES算法
            NSString *pwdDes = [self encryptUseDES:self.pwdField.text andKey:@"5AC85052" andIv:@"5AC85052"];
            
            //加密算法算出来是小写，这里转换成小写再比较
            if([pwdDes isEqualToString:[userinfo.UserPwd lowercaseString]])
            {
                NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModuleLike '%@','DA%%'",userinfo.JiaoSe];
                NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
                
                NSURL *url = [NSURL URLWithString: urlStr];
                
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                [request setUseCookiePersistence:NO];
                [request setTimeOutSeconds:30];
                [request setPostValue:sqlStr forKey:@"sqlstr"];
                [request setDelegate:self];
                [request setDefaultResponseEncoding:NSUTF8StringEncoding];
                [request setDidFailSelector:@selector(requestFailed:)];
                [request setDidFinishSelector:@selector(requestPermission:)];
                [request startAsynchronous];
            }
            else
            {
                hud.hidden = YES;
                [Tool showCustomHUD:@"Login Failure" andView:self.view andImage:nil andAfterDelay:1.2f];
            }
        }
        else
        {
            hud.hidden = YES;
            [Tool showCustomHUD:@"Login Succeed" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
    
}

- (NSString *)encryptUseDES:(NSString *)plainText andKey:(NSString *)authKey andIv:(NSString *)authIv{
    const void *iv  = (const void *) [authIv UTF8String];
    NSString *ciphertext = nil;
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [authKey UTF8String],
                                          kCCKeySizeDES,
                                          iv,
                                          [textData bytes],
                                          dataLength,
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        NSString *oriStr = [NSString stringWithFormat:@"%@",data];
        NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
        ciphertext = [[oriStr componentsSeparatedByCharactersInSet:cSet] componentsJoinedByString:@""];
    }
    return ciphertext;
}

- (void)requestPermission:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    
    XMLParserUtils *utils = [[XMLParserUtils alloc] init];
    hud.hidden = YES;
    utils.parserFail = ^()
    {
        [Tool showCustomHUD:@"Login Failure" andView:self.view andImage:nil andAfterDelay:1.2f];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray *perArray = [Tool readJsonToObjArray:jsonArray andObjClass:[Permission class]];
        if(perArray && perArray.count > 0)
        {
            userinfo.permissions = perArray;
            NSUserDefaults *preference = [NSUserDefaults standardUserDefaults];
            [preference setObject:self.usernameField.text forKey:@"username"];
            [preference setObject:self.pwdField.text forKey:@"pwd"];
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            app.userinfo = userinfo;
            [Tool showCustomHUD:@"Login Succeed" andView:self.view andImage:nil andAfterDelay:1.2f];
            [self performSelector:@selector(goNext) withObject:nil afterDelay:1.3f];
        }
        else
        {
            [Tool showCustomHUD:@"Login Failure" andView:self.view andImage:nil andAfterDelay:1.2f];
        }
    };
    
    [utils stringFromparserXML:request.responseString target:@"string"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    NSString *username = [setting objectForKey:@"username"];
    NSString *pwd = [setting objectForKey:@"pwd"];
    if(username)
    {
        self.usernameField.text = username;
    }
    if(pwd)
    {
        self.pwdField.text = pwd;
    }
}

- (void)goNext
{
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UsersTableView *userPage = [[UsersTableView alloc] initWithNibName:@"UsersTableView" bundle:nil];
    userPage.tabBarItem.image = [UIImage imageNamed:@"tab_userinfo"];
    userPage.tabBarItem.title = @"User Info";
    UINavigationController *userPageNav = [[UINavigationController alloc] initWithRootViewController:userPage];
    
    SiteServTableView *siteServPage = [[SiteServTableView alloc] initWithNibName:@"SiteServTableView" bundle:nil];
    siteServPage.tabBarItem.image = [UIImage imageNamed:@"tab_SiteServ"];
    siteServPage.tabBarItem.title = @"Site Serv";
    UINavigationController *siteServPageNav = [[UINavigationController alloc] initWithRootViewController:siteServPage];
    
    SolnMgtTableView *solnMgtPage = [[SolnMgtTableView alloc] initWithNibName:@"SolnMgtTableView" bundle:nil];
    solnMgtPage.tabBarItem.image = [UIImage imageNamed:@"tab_SolnMgt"];
    solnMgtPage.tabBarItem.title = @"Soln Mgt";
    UINavigationController *solnMgtPageNav = [[UINavigationController alloc] initWithRootViewController:solnMgtPage];
    
    SatisfaTableView *satisfaPage = [[SatisfaTableView alloc] initWithNibName:@"SatisfaTableView" bundle:nil];
    satisfaPage.tabBarItem.image = [UIImage imageNamed:@"tab_Satisfa"];
    satisfaPage.tabBarItem.title = @"Satisfaction";
    UINavigationController *satisfaPageNav = [[UINavigationController alloc] initWithRootViewController:satisfaPage];
    
    MyWorkTableView *myWorkPage = [[MyWorkTableView alloc] initWithNibName:@"MyWorkTableView" bundle:nil];
    myWorkPage.tabBarItem.image = [UIImage imageNamed:@"tab_MyWork"];
    myWorkPage.tabBarItem.title = @"My Work";
    UINavigationController *myWorkPageNav = [[UINavigationController alloc] initWithRootViewController:myWorkPage];
    
    MoreListView *morePage = [[MoreListView alloc] initWithNibName:@"MoreListView" bundle:nil];
    morePage.tabBarItem.image = [UIImage imageNamed:@"tab_more"];
    morePage.tabBarItem.title = @"more";
    UINavigationController *morePageNav = [[UINavigationController alloc] initWithRootViewController:morePage];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:
                                        myWorkPageNav,
                                        userPageNav,
                                        siteServPageNav,
//                                        solnMgtPageNav,
                                        satisfaPageNav,
                                        morePageNav,
                                        nil];
    [[tabBarController tabBar] setSelectedImageTintColor:[Tool getColorForMain]];
    [[tabBarController tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
        
    appdele.window.rootViewController = tabBarController;
    [appdele.window makeKeyAndVisible];

}

- (IBAction)contactAction:(id)sender
{
         NSURL *phoneURL = [NSURL URLWithString:@"tel:+86-731-84086265"];
         if ( !phoneCallWebView ) {
             phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
         }
         [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

@end
