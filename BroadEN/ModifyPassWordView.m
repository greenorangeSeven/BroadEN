//
//  ModifyPassWordView.m
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "ModifyPassWordView.h"

@interface ModifyPassWordView ()
{
    UserInfo *userinfo;
}

@end

@implementation ModifyPassWordView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Modify password";
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    self.userNameLb.text = userinfo.EnName;
}

- (void)saveAction:(id )sender
{
    NSString *oldPassWordStr = self.CurrentpasswordTF.text;
    NSString *newsPassWordStr = self.NewpasswordTF.text;
    NSString *newsPassWordAginStr = self.ConfirmNewpasswordTF.text;
    
    if ([oldPassWordStr length] > 0)
    {
        if ([newsPassWordStr length] == 0) {
            [Tool showCustomHUD:@"请输入新密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
            return;
        }
    }
    if ([newsPassWordStr length] > 0)
    {
        if ([oldPassWordStr length] == 0) {
            [Tool showCustomHUD:@"请输入旧密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
            return;
        }
    }
    if ([newsPassWordStr isEqualToString:newsPassWordAginStr] == NO) {
        [Tool showCustomHUD:@"密码确认不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    //DES算法
    NSString *pwdDes = [self encryptUseDES:oldPassWordStr andKey:@"5AC85052" andIv:@"5AC85052"];
    
    //加密算法算出来是小写，这里转换成小写再比较
    if([pwdDes isEqualToString:[userinfo.UserPwd lowercaseString]])
    {
        [self modifyUserPassWord];
    }
    else
    {
        [Tool showCustomHUD:@"密码错误" andView:self.view andImage:nil andAfterDelay:1.2f];
    }
}

- (void)modifyUserPassWord
{
    NSString *newpwdDes = [self encryptUseDES:self.NewpasswordTF.text andKey:@"5AC85052" andIv:@"5AC85052"];
    NSString *sqlStr = [NSString stringWithFormat:@"exec sp_executesql N'update ERPUser set UserPwd=@UserPwd where ID=@ID ',N'@ID int,@UserPwd varchar(200)',@ID='%@',@UserPwd='%@'", userinfo.ID, newpwdDes];
    NSString *urlStr = [NSString stringWithFormat:@"%@DoActionInDZDA", api_base_url];
    
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
        if ([string isEqualToString:@"true"]) {
            [self writeLog];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)writeLog
{
    //写日志
    NSString *ip = [Tool getIPAddress:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,TimeStr,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@TimeStr,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@TimeStr datetime,@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@TimeStr='%@',@Operation='修改密码',@Plate='系统',@ProjName=NULL,@DoSomething='IOSApp修改密码',@IpStr='%@'", userinfo.UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], ip];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        if([response rangeOfString:@"true"].length > 0)
        {
            [Tool showCustomHUD:@"Submit success" andView:self.view andImage:nil andAfterDelay:1.2f];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_MyWorkListReLoad" object:nil];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        }
        else
        {
            [Tool showCustomHUD:@"Submit failure" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
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

@end
