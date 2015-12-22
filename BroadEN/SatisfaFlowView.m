//
//  SatisfaFlowView.m
//  BroadEN
//
//  Created by Seven on 15/12/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SatisfaFlowView.h"
#import "Satisfa.h"
#import "UnitInfo.h"
#import "SatisfaUnitTableCell.h"
#import "ImageCollectionCell.h"
#import "NextWorkFlow.h"
#import "SGActionView.h"
#import "FlowRecordView.h"
#import "MWPhotoBrowser.h"
#import "Img.h"

@interface SatisfaFlowView ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,MWPhotoBrowserDelegate>
{
    Satisfa *satisfa;
    NSArray *units;
    UserInfo *userinfo;
    
    NSArray *picArray;
    NSMutableArray *fileArray;
    NSUInteger selectPicIndex;
    
    NSString *allfilename;//photo
    
    BOOL fromCamera;
    
    MBProgressHUD *hud;
    
    NSString *jiaose;
    NSString *UserName;
    NSString *UserNameEN;
    
    NextWorkFlow *nextWorkFlow;
    NSArray *nextWorkArray;
    NSArray *applyWorkArray;
    
    NSString *Operation;
    
    BOOL goToFive;
    
    UIAlertView *reJectDialog;
    BOOL isReject;
    NSString *rejectContent;
    
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation SatisfaFlowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Satisfa";
    
    if(!self.isQuery)
    {
        UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
        self.navigationItem.rightBarButtonItem = submitBtn;
    }
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    UserName = userinfo.UserName;
    UserNameEN = userinfo.EnName;
    jiaose = userinfo.JiaoSe;
    
    goToFive = NO;
    isReject = NO;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = self.footerView;
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    fromCamera = NO;
    //初始化图片区域
    fileArray = [[NSMutableArray alloc] initWithCapacity:9];
    if(!self.isQuery)
    {
        UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
        [fileArray addObject:addPicImage];
    }
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getFlowNextInfo];
    [self getSatisfaDetailData];
}

- (void)rejectAction:(id )sender
{
    reJectDialog = [[UIAlertView alloc] initWithTitle:@"ReJect" message:@"Please Write ReJect Reason" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:@"cancel",nil];
    reJectDialog.tag = 2;
    [reJectDialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [reJectDialog show];
    isReject = YES;
}

- (void)submitAction:(id )sender
{
    NSString *nextSql = @"";
    isReject = NO;
    //流程第2步！ 总部审批      IM角色  AM角色       StepID = 3（下一步流程），
    if(nextWorkFlow.StepID == 3 && ([jiaose isEqualToString:@"IM"] || [jiaose isEqualToString:@"AM"]))
    {
        NSString *UserHQSugstStr = self.UserHQ_SugstTV.text;
        if (UserHQSugstStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write UserHQConfirm Opinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        UserHQSugstStr = [UserHQSugstStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_UserHQ_TelFollow] set UserHQ_Sugst=@UserHQ_Sugst,UserHQ_Sign=@UserHQ_Sign,UserHQ_SignDate=@UserHQ_SignDate where Table_ID=@Table_ID ', 	N' @UserHQ_Sugst varchar(2000),@UserHQ_Sign varchar(32),@UserHQ_SignDate datetime,@Table_ID varchar(50) ', 	@UserHQ_Sugst='%@',@UserHQ_Sign='%@',@UserHQ_SignDate='%@',@Table_ID='%@'", UserHQSugstStr, UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    }
    
    //流程第3步！ 服务部落实    SH角色       StepID = 4（下一步流程），
    if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"SH"])
    {
        NSString *Serv_Dept_SugstStr = self.Serv_Dept_SugstTV.text;
        if (Serv_Dept_SugstStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write ServiceBranchOpinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        Serv_Dept_SugstStr = [Serv_Dept_SugstStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_UserHQ_TelFollow] set Serv_Dept_Sugst=@Serv_Dept_Sugst,Serv_Dept_Sign=@Serv_Dept_Sign,Serv_Dept_SignDate=@Serv_Dept_SignDate where Table_ID=@Table_ID ', N' @Serv_Dept_Sugst varchar(2000),@Serv_Dept_Sign varchar(32),@Serv_Dept_SignDate datetime,@Table_ID varchar(50)', @Serv_Dept_Sugst='%@',@Serv_Dept_Sign='%@',@Serv_Dept_SignDate='%@',@Table_ID='%@'", Serv_Dept_SugstStr, UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    }
    //流程第4步！ 工程师落实（办结归档）    SE 或 FJ 角色       StepID = 5（下一步流程），
    if(nextWorkFlow.StepID == 5 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"]))
    {
        NSString *Engineer_SugstStr = self.Engineer_SugstTV.text;
        if (Engineer_SugstStr.length == 0)
        {
            [Tool showCustomHUD:@"Engineersopiniondisposeresult is Null" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        nextSql = @"step5";
    }
    //流程第5步！ 总部确认      IM角色     StepID = 5（办结），
    if(nextWorkFlow.StepID == 5 && [jiaose isEqualToString:@"IM"])
    {
        NSString *UserHQ_ConfirmStr = self.UserHQ_ConfirmTV.text;
        if (UserHQ_ConfirmStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write UserHQConfirmOpinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        UserHQ_ConfirmStr = [UserHQ_ConfirmStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_UserHQ_TelFollow] set UserHQ_Confirm=@UserHQ_Confirm,UserHQ_Confirm_Sign=@UserHQ_Confirm_Sign,UserHQ_Confirm_SignDate=@UserHQ_Confirm_SignDate where Table_ID=@Table_ID ', N' @UserHQ_Confirm varchar(2000),@UserHQ_Confirm_Sign varchar(32),@UserHQ_Confirm_SignDate datetime,@Table_ID varchar(50)', 	@UserHQ_Confirm='%@',@UserHQ_Confirm_Sign='%@',@UserHQ_Confirm_SignDate='%@',@Table_ID='%@'", UserHQ_ConfirmStr, UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    
    NSString *sql = [NSString stringWithFormat:@"Select OwnerUserName From FlowActionTrace Where SubmitTime is null and InstanceID=(Select ID From FlowInstance Where Mark='%@')", self.Mark];
    
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             if (hud) {
                 [hud hide:YES];
             }
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSDictionary *dic = table[0];
             NSString *OwnerUserName = [dic objectForKey:@"OwnerUserName"];
             if([OwnerUserName isEqualToString:UserName])
             {
                 if([nextSql isEqualToString:@"step5"])
                 {
                     [self updateImg];
                 }
                 else
                 {
                     [self updateMainData:nextSql];
                 }
             }
             else
             {
                 if (hud) {
                     [hud hide:YES];
                 }
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Workflow submitted already!" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:nil];
                 [alertView show];
                 self.navigationItem.rightBarButtonItem.enabled = YES;
                 return;
             }
         };
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (hud) {
             [hud hide:YES];
         }
         self.navigationItem.rightBarButtonItem.enabled = YES;
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)updateImg
{
    UIImage *imgbegin = [[UIImage alloc] init];
    for(int i = 0; i < fileArray.count - 1; ++i)
    {
        imgbegin = nil;
        imgbegin = fileArray[i];
        if(imgbegin)
        {
            int random = (arc4random() % 501) + 500;
            NSString *picFirstName = @"Satisfa";
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%i.jpg",picFirstName,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],random];
            BOOL isOK = [self upload:imgbegin oldName:reName Index:1];
            if(!isOK)
            {
                if (hud) {
                    [hud hide:YES];
                }
                [Tool showCustomHUD:@"图片上传失败..." andView:self.view andImage:nil andAfterDelay:1.2f];
                return;
            }
        }
    }
    
    NSString *Engineer_SugstStr = self.Engineer_SugstTV.text;
    Engineer_SugstStr = [Engineer_SugstStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_UserHQ_TelFollow] set Engineer_Sugst=@Engineer_Sugst,allfilename=@allfilename,Engineer_Sign=@Engineer_Sign,Engineer_SignDate=@Engineer_SignDate where Table_ID=@Table_ID ', N' @Engineer_Sugst varchar(2000),@allfilename varchar(2000),@Engineer_Sign varchar(32),@Engineer_SignDate datetime,@Table_ID varchar(50) ', @Engineer_Sugst='%@',@allfilename='%@',@Engineer_Sign='%@',@Engineer_SignDate='%@',@Table_ID='%@'", Engineer_SugstStr, allfilename, UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    [self updateMainData:nextSql];
}

- (BOOL)upload:(UIImage *)img oldName:(NSString *)reName Index:(NSInteger)index
{
    static BOOL isOK = NO;
    if(img)
    {
        int random = (arc4random() % 501) + 500;
        NSString *fileName = [NSString stringWithFormat:@"%@%i.jpg", [Tool getCurrentTimeStr:@"yyyyMMddHHmmss"], random];
        
        NSString *base64Encoded = [UIImageJPEGRepresentation(img,0.8f) base64EncodedStringWithOptions:0];
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@UploadFile",api_base_url]]];
        
        [request setUseCookiePersistence:NO];
        [request setTimeOutSeconds:30];
        
        [request setPostValue:fileName forKey:@"fileName"];
        [request setPostValue:base64Encoded forKey:@"fileBytes"];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error)
        {
            NSString *response = [request responseString];
            if([response rangeOfString:@"UploadFile"].length > 0)
            {
                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
                img = nil;
                base64Encoded = nil;
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, UserName, UserNameEN, string, @"溶液处理(英文app)"];
                ASIFormDataRequest *tworequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
                [tworequest setUseCookiePersistence:NO];
                [tworequest setTimeOutSeconds:30];
                [tworequest setDelegate:self];
                [tworequest setPostValue:sql forKey:@"sqlstr"];
                [tworequest setDefaultResponseEncoding:NSUTF8StringEncoding];
                [tworequest startSynchronous];
                
                NSError *error = [request error];
                if (!error)
                {
                    NSString *response2 = [tworequest responseString];
                    if([response2 rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        
                        if(allfilename == nil || [allfilename isEqualToString:@"null"])
                        {
                            allfilename = @"";
                        }
                        allfilename = [NSString stringWithFormat:@"%@|%@",allfilename,fileName];
                        allfilename = [allfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                    }
                }
            }
        }
    }
    return isOK;
}

- (void)updateMainData:(NSString *)sql
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        NSLog(response);
        if (hud) {
            [hud hide:YES];
        }
        if([response rangeOfString:@"true"].length > 0)
        {
            //流程第4步！ 工程师落实（办结归档）    SE 或 FJ 角色       StepID = 5（下一步流程），
            if(nextWorkFlow.StepID == 5 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"]))
            {
                if (goToFive) {
                    [self selectNextUser];
                }
                else
                {
                    //不进入第五部就不需要选择下一步人员直接办结
                    NSString *nextStr = @"4/-1";
                    Operation = @"办结归档";
                    [self FlowNextSubmit:nextStr];
                }
            }
            //流程第5步！ 总部确认      IM角色     StepID = 5（流程完结不需要选择下一步人员直接办结）
            else if(nextWorkFlow.StepID == 5 && [jiaose isEqualToString:@"IM"])
            {
                NSString *nextStr = @"5/-1";
                Operation = @"办结";
                [self FlowNextSubmit:nextStr];
            }
            else
            {
                [self selectNextUser];
            }
            
        }
        else
        {
            [Tool showCustomHUD:@"提交失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)selectNextUser
{
    NSMutableArray *StepNames = [[NSMutableArray alloc] init];
    NSMutableArray *NextUserNames = [[NSMutableArray alloc] init];
    NSArray *selectNextFlowArray = [[NSArray alloc] init];
    if (isReject) {
        for(NextWorkFlow *nextWork in applyWorkArray)
        {
            [StepNames addObject:nextWork.StepName];
            [NextUserNames addObject:nextWork.NextUserName];
        }
        selectNextFlowArray = applyWorkArray;
    }
    else
    {
        for(NextWorkFlow *nextWork in nextWorkArray)
        {
            [StepNames addObject:nextWork.StepName];
            [NextUserNames addObject:nextWork.NextUserName];
        }
        selectNextFlowArray = nextWorkArray;
    }
    [SGActionView showSheetWithTitle:@"Please Select" itemTitles:NextUserNames itemSubTitles:StepNames selectedIndex:-1 selectedHandle:^(NSInteger index){
        NextWorkFlow *selectNextWork = selectNextFlowArray[index];
        
        NSString *nextStr = @"";
        //流程第2步！ 总部审批      IM角色  AM角色       StepID = 3，
        if(selectNextWork.StepID == 3 && ([jiaose isEqualToString:@"IM"] || [jiaose isEqualToString:@"AM"]))
        {
            nextStr = [NSString stringWithFormat:@"%d/%d", selectNextWork.StepID, selectNextWork.NextUserNameCode];
            Operation = @"办理";
        }
        //流程第3步！ 服务部落实    SH角色       StepID = 4（下一步流程），
        if(selectNextWork.StepID == 4 && [jiaose isEqualToString:@"SH"])
        {
            nextStr = [NSString stringWithFormat:@"%d/%d", selectNextWork.StepID, selectNextWork.NextUserNameCode];
            Operation = @"办理";
        }
        //流程第4步！ 工程师落实（办结归档）    SE 或 FJ 角色       StepID = 5（下一步流程），
        if(selectNextWork.StepID == 5 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"]))
        {
            nextStr = [NSString stringWithFormat:@"%d/%d", selectNextWork.StepID, selectNextWork.NextUserNameCode];
            Operation = @"工程师落实";
        }
        
        [self FlowNextSubmit:nextStr];
    }];
}

- (void)FlowNextSubmit:(NSString *)nextStr
{
    NSString *sql = @"";
    if(isReject)
    {
        sql = [NSString stringWithFormat:@"exec SP_FlowSubmit_En @UserName='%@',@AcionID=-1,@NextStr='%@',@Mark='%@',@FlowName='总部电话回访审批',@Data=N'IOS app端%@'", userinfo.UserName, nextStr, self.Mark, Operation];
    }
    else
    {
        sql = [NSString stringWithFormat:@"exec SP_FlowSubmit_En @UserName='%@',@AcionID=1,@NextStr='%@',@Mark='%@',@FlowName='总部电话回访审批',@Data=N'IOS app端%@'", userinfo.UserName, nextStr, self.Mark, Operation];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@DoActionInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestStartNext:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestStartNext:(ASIHTTPRequest *)request
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
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,TimeStr,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@TimeStr,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@TimeStr datetime,@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@TimeStr='%@',@Operation='%@',@Plate='总部电话回访',@ProjName='%@',@DoSomething='总部电话回访审批,Mark:%@',@IpStr='%@'", UserName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], Operation, satisfa.PROJ_Name, self.Mark, ip];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        if([response rangeOfString:@"true"].length > 0)
        {
            [Tool showCustomHUD:@"提交成功" andView:self.view andImage:nil andAfterDelay:1.2f];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_MyWorkListReLoad" object:nil];
            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        }
        else
        {
            [Tool showCustomHUD:@"提交失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)getFlowNextInfo
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetFlowNextInfo_En '%@'", self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFlowNextInfo:)];
    [request startAsynchronous];
}

- (void)requestFlowNextInfo:(ASIHTTPRequest *)request
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
        if (jsonArray && [jsonArray count] > 0) {
            nextWorkArray = [Tool readJsonToObjArray:jsonArray andObjClass:[NextWorkFlow class]];
            
            nextWorkFlow = [Tool readJsonDicToObj:jsonArray[0] andObjClass:[NextWorkFlow class]];
            
            //流程第2步！ 总部审批      IM角色  AM角色       StepID = 3，
            if(nextWorkFlow.StepID == 3 && ([jiaose isEqualToString:@"IM"] || [jiaose isEqualToString:@"AM"]))
            {
                if(!self.isQuery)
                {
                    //如果是第二步就会有回退按钮
                    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"|  Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
                    UIBarButtonItem *rollbackBtn = [[UIBarButtonItem alloc] initWithTitle: @"Reject  " style:UIBarButtonItemStyleBordered target:self action:@selector(rejectAction:)];
                    NSArray *buttonArray = [[NSArray alloc] initWithObjects:submitBtn,rollbackBtn , nil];
                    self.navigationItem.rightBarButtonItems = buttonArray;
                    
                    self.UserHQ_SugstTV.editable = YES;
                    self.UserHQ_Sign_EnLB.text = UserName;
                    self.UserHQ_SignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.ServiceBranchView.hidden = YES;
                self.EngineerView.hidden = YES;
                self.UserHQConfirmOpinionView.hidden = YES;
                
                CGRect footerFrame = self.footerView.frame;
                footerFrame.size.height = self.UserHQ_SugstView.frame.origin.y + self.UserHQ_SugstView.frame.size.height;
                self.footerView.frame = footerFrame;
                
                self.tableView.tableFooterView = self.footerView;
            }
            
            //流程第3步！ 服务部落实    SH角色       StepID = 4（下一步流程），
            if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"SH"])
            {
                if(!self.isQuery)
                {
                    self.Serv_Dept_SugstTV.editable = YES;
                    self.Serv_Dept_SignLB.text = UserName;
                    self.Serv_Dept_SignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.EngineerView.hidden = YES;
                self.UserHQConfirmOpinionView.hidden = YES;
                
                CGRect footerFrame = self.footerView.frame;
                footerFrame.size.height = self.ServiceBranchView.frame.origin.y + self.ServiceBranchView.frame.size.height;
                self.footerView.frame = footerFrame;
                
                self.tableView.tableFooterView = self.footerView;
            }
            //流程第4步！ 工程师落实（办结归档）    SE 或 FJ 角色       StepID = 5（下一步流程），
            if(nextWorkFlow.StepID == 5 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"]))
            {
                if(!self.isQuery)
                {
                    self.Engineer_SugstTV.editable = YES;
                    self.Engineer_SignLB.text = UserName;
                    self.Engineer_SignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.UserHQConfirmOpinionView.hidden = YES;
                
                CGRect footerFrame = self.footerView.frame;
                footerFrame.size.height = self.EngineerView.frame.origin.y + self.EngineerView.frame.size.height;
                self.footerView.frame = footerFrame;
                
                self.tableView.tableFooterView = self.footerView;
            }
            
            //流程第5步！ 总部确认      IM角色     StepID = 6（下一步流程），
            if(nextWorkFlow.StepID == 5 && [jiaose isEqualToString:@"IM"])
            {
                if(!self.isQuery)
                {
                    self.UserHQ_ConfirmTV.editable = YES;
                    self.UserHQ_Confirm_SignLB.text = UserName;
                    self.UserHQ_Confirm_SignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.tableView.tableFooterView = self.footerView;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getSatisfaDetailData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select P.PROJ_Name,P.PROJ_Name_En,P.Serv_Dept,P.Serv_Dept_En,P.Duty_Engineer,P.Duty_Engineer_En, dbo.fn_GetEnName(F.Follow_Name) as Follow_Name_En,dbo.fn_GetEnName(F.UserHQ_Sign) as UserHQ_Sign_En,dbo.fn_GetEnName(F.Serv_Dept_Sign) as Serv_Dept_Sign_En, dbo.fn_GetEnName(F.Engineer_Sign) as Engineer_Sign_En,dbo.fn_GetEnName(F.UserHQ_Confirm_Sign) as UserHQ_Confirm_Sign_En, F.* FROM [TB_CUST_ProjInf_UserHQ_TelFollow] as F,TB_CUST_ProjInf as P where F.Proj_ID=P.PROJ_ID and F.Table_ID='%@'; SELECT OutFact_Num,AirCondUnit_Mode  FROM Tb_CUST_ProjInf_AirCondUnit Where PROJ_ID=(select Proj_ID from TB_CUST_ProjInf_UserHQ_TelFollow where Table_ID='%@') order by FirstDebug_Date asc", self.Mark, self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInUserInfo", api_base_url];
    
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
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonDic) {
            NSArray *tableArray = [jsonDic objectForKey:@"Table"];
            if ([tableArray count] > 0) {
                satisfa = [Tool readJsonDicToObj:tableArray[0] andObjClass:[Satisfa class]];
            }
            NSArray *table1Array = [jsonDic objectForKey:@"Table1"];
            if ([table1Array count] > 0) {
                units = [Tool readJsonToObjArray:table1Array andObjClass:[UnitInfo class]];
                [self.tableView reloadData];
            }
            [self bindData];
            [self getStateData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindData
{
    self.PROJ_Name_EnLB.text = satisfa.PROJ_Name_En;
    self.Engineer_Sign_EnLB.text = satisfa.Engineer_Sign_En;
    self.Follow_Name_EnLB.text = satisfa.Follow_Name_En;
    self.Follow_DateLB.text = [Tool DateTimeRemoveTime:satisfa.Follow_Date andSeparated:@" "];
    
    self.Run_ReliabilityLB.text = [self CNTOEN:satisfa.Run_Reliability];
    self.Handle_easeLB.text = [self CNTOEN:satisfa.Handle_ease];
    self.Run_resultLB.text = [self CNTOEN:satisfa.Run_result];
    self.Prod_OverallMeritLB.text = [self CNTOEN:satisfa.Prod_OverallMerit];
    self.Save_EnergyLB.text = [self CNTOEN:satisfa.Save_Energy];
    
    self.Serv_NormalizationLB.text = [self CNTOEN:satisfa.Serv_Normalization];
    self.Locale_GuideLB.text = [self CNTOEN:satisfa.Locale_Guide];
    self.Serv_AtitudeLB.text = [self CNTOEN:satisfa.Serv_Atitude];
    self.Serv_TimelinesLB.text = [self CNTOEN:satisfa.Serv_Timelines];
    self.Serv_Tech_LevelLB.text = [self CNTOEN:satisfa.Serv_Tech_Level];
    self.Serv_OverallMeritLB.text = [self CNTOEN:satisfa.Serv_OverallMerit];
    
    self.CUST_SugstTV.text = satisfa.CUST_Sugst;
    
    self.UserHQ_SugstTV.text = satisfa.UserHQ_Sugst;
    self.UserHQ_Sign_EnLB.text = satisfa.UserHQ_Sign_En;
    self.UserHQ_SignDateLB.text = satisfa.UserHQ_SignDate;
    
    if([Tool isStringExist:satisfa.Serv_Dept_Sugst])
    {
        self.Serv_Dept_SugstTV.text = satisfa.Serv_Dept_Sugst;
    }
    if([Tool isStringExist:satisfa.Serv_Dept_Sign])
    {
        self.Serv_Dept_SignLB.text = satisfa.Serv_Dept_Sign;
    }
    if([Tool isStringExist:satisfa.Serv_Dept_SignDate])
    {
        self.Serv_Dept_SignDateLB.text = satisfa.Serv_Dept_SignDate;
    }
    
    if([Tool isStringExist:satisfa.Engineer_Sugst])
    {
        self.Engineer_SugstTV.text = satisfa.Engineer_Sugst;
    }
    if([Tool isStringExist:satisfa.Engineer_Sign])
    {
        self.Engineer_SignLB.text = satisfa.Engineer_Sign;
    }
    if([Tool isStringExist:satisfa.Engineer_SignDate])
    {
        self.Engineer_SignDateLB.text = satisfa.Engineer_SignDate;
    }
    
    self.UserHQ_ConfirmTV.text = satisfa.UserHQ_Confirm;
    self.UserHQ_Confirm_SignLB.text = satisfa.UserHQ_Confirm_Sign;
    self.UserHQ_Confirm_SignDateLB.text = satisfa.UserHQ_Confirm_SignDate;
    
    if (self.isQuery) {
        if (satisfa.allfilename.length > 0) {
            [self getImg:satisfa.allfilename andImageIndex:3];
        }
    }
}

- (void)getImg:(NSString *)imgurl andImageIndex:(int )imageIndex
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@GetFileUrl",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:imgurl,@"fileName", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParserUtils *utils = [[XMLParserUtils alloc] init];
         utils.parserFail = ^()
         {
             hud.hidden = YES;
             [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
             //             [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
         };
         utils.parserOK = ^(NSString *string)
         {
             NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error;
             
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             picArray = nil;
             picArray = [Tool readJsonToObjArray:table andObjClass:[Img class]];
             hud.hidden = YES;
             if(picArray && picArray.count > 0)
             {
                 switch (imageIndex) {
                     case 3:
                         fileArray = [NSMutableArray arrayWithArray:picArray];
                         [self reloadPhotoHeight:YES andIsInit:YES];
                         [self.photoCollectionView reloadData];
                         break;
                     default:
                         break;
                 }
             }
         };
         
         [utils stringFromparserXML:operation.responseString target:@"string"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         hud.hidden = YES;
         [Tool showCustomHUD:@"网络连接错误" andView:self.view andImage:nil andAfterDelay:1.2f];
     }];
}

- (void)getStateData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select AirCondUnit_State  FROM Tb_CUST_ProjInf_AirCondUnit  where PROJ_ID= (select Proj_ID from TB_CUST_ProjInf_UserHQ_TelFollow where Table_ID='%@')", self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestState:)];
    [request startAsynchronous];
}

- (void)requestState:(ASIHTTPRequest *)request
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
        NSString *state = @"";
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(@"%@", string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        for (NSDictionary *dic in jsonArray) {
            state = [dic objectForKey:@"AirCondUnit_State"];
        }
        
        NSString *Prod_OverallMeritEN = [self CNTOEN:satisfa.Prod_OverallMerit];
        NSString *Serv_OverallMeritEN = [self CNTOEN:satisfa.Serv_OverallMerit];
        if([state isEqualToString:@"已运行"])
        {
            
            if ([Prod_OverallMeritEN isEqualToString:@"Poor"] || [Prod_OverallMeritEN isEqualToString:@"Bad"] || [Prod_OverallMeritEN isEqualToString:@"Very Bad"] || [Serv_OverallMeritEN isEqualToString:@"Poor"] || [Serv_OverallMeritEN isEqualToString:@"Bad"] || [Serv_OverallMeritEN isEqualToString:@"Very Bad"]) {
                //                self.UserHQConfirmOpinionView.hidden = NO;
                goToFive = YES;
            }
            else
            {
                //                self.UserHQConfirmOpinionView.hidden = YES;
                //
                //                CGRect footerFrame = self.footerView.frame;
                //                footerFrame.size.height = footerFrame.size.height -192;
                //                self.footerView.frame = footerFrame;
                //
                //                self.tableView.tableFooterView = self.footerView;
                goToFive = NO;
            }
        }
        else
        {
            if ([Serv_OverallMeritEN isEqualToString:@"Poor"] || [Serv_OverallMeritEN isEqualToString:@"Bad"] || [Serv_OverallMeritEN isEqualToString:@"Very Bad"]) {
                //                self.UserHQConfirmOpinionView.hidden = NO;
                goToFive = YES;
            }
            else
            {
                //                self.UserHQConfirmOpinionView.hidden = YES;
                //                CGRect footerFrame = self.footerView.frame;
                //                footerFrame.size.height = footerFrame.size.height -192;
                //                self.footerView.frame = footerFrame;
                //
                //                self.tableView.tableFooterView = self.footerView;
                goToFive = NO;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return units.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    SatisfaUnitTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SatisfaUnitTableCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SatisfaUnitTableCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[SatisfaUnitTableCell class]]) {
                cell = (SatisfaUnitTableCell *)o;
                break;
            }
        }
    }
    
    UnitInfo *u = [units objectAtIndex:row];
    
    cell.AirCondUnit_ModeLB.text = u.AirCondUnit_Mode;
    cell.OutFact_NumLB.text = u.OutFact_Num;
    
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)CNTOEN:(NSString *)CN
{
    NSString *EN = @"";
    if (CN && CN.length > 0) {
        if ([CN isEqualToString:@"好"]) {
            EN = @"Excellent";
        }
        else if ([CN isEqualToString:@"较好"]) {
            EN = @"Good";
        }
        else if ([CN isEqualToString:@"一般"]) {
            EN = @"Poor";
        }
        else if ([CN isEqualToString:@"较差"]) {
            EN = @"Bad";
        }
        else if ([CN isEqualToString:@"差"]) {
            EN = @"Very Bad";
        }
    }
    return EN;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)reloadPhotoHeight:(BOOL )addORcutRow andIsInit:(BOOL )ISInit
{
    int addRow = 0;
    if(ISInit)
    {
        if ([fileArray count] % 3 > 0) {
            addRow = [fileArray count]/3 + 1 - 1;
        }
        else
        {
            addRow = [fileArray count]/3 - 1;
        }
    }
    else
    {
        if(addORcutRow)
        {
            if ([fileArray count] % 3 == 1) {
                addRow = 1;
            }
        }
        else
        {
            if ([fileArray count] <= 6)
            {
                if ([fileArray count] % 3 == 0) {
                    addRow = -1;
                }
            }
        }
    }
    
    //只允许上传9张图片
    if ([fileArray count] == 10) {
        addRow = 0;
    }
    
    float addHeight = 100.0 * addRow;
    if (addHeight == 0) {
        return;
    }
    
    //计算框架otherCollectionView的高度
    CGRect photoFrame = self.photoCollectionView.frame;
    photoFrame.size.height = photoFrame.size.height + addHeight;
    self.photoCollectionView.frame = photoFrame;
    
    CGRect engineerViewrame = self.EngineerView.frame;
    engineerViewrame.size.height = engineerViewrame.size.height + addHeight;
    self.EngineerView.frame = engineerViewrame;
    
    CGRect footerViewFrame = self.footerView.frame;
    footerViewFrame.size.height = footerViewFrame.size.height + addHeight;
    self.footerView.frame = footerViewFrame;
    
    CGRect engineerBottomViewFrame = self.EngineerBottomView.frame;
    engineerBottomViewFrame.size.height = engineerBottomViewFrame.size.height + addHeight;
    engineerBottomViewFrame.origin.y = engineerBottomViewFrame.origin.y + addHeight;
    self.EngineerBottomView.frame = engineerBottomViewFrame;
    
    CGRect userHQConfirmOpinionViewFrame = self.UserHQConfirmOpinionView.frame;
    userHQConfirmOpinionViewFrame.origin.y = userHQConfirmOpinionViewFrame.origin.y + addHeight;
    self.UserHQConfirmOpinionView.frame = userHQConfirmOpinionViewFrame;
    
    self.tableView.tableFooterView = self.footerView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 1)
        {
            UIImage *picImage = [fileArray objectAtIndex:selectPicIndex];
            [self.photos removeAllObjects];
            if ([self.photos count] == 0) {
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                MWPhoto * photo = [MWPhoto photoWithImage:picImage];
                [photos addObject:photo];
                self.photos = photos;
            }
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
            browser.displayNavArrows = NO;//左右分页切换,默认否
            browser.displaySelectionButtons = NO;//是否显示选择按钮在图片上,默认否
            browser.alwaysShowControls = YES;//控制条件控件 是否显示,默认否
            browser.zoomPhotosToFill = NO;//是否全屏,默认是
            //    browser.wantsFullScreenLayout = YES;//是否全屏
            [browser setCurrentPhotoIndex:0];
            self.navigationController.navigationBar.hidden = NO;
            [self.navigationController pushViewController:browser animated:YES];
        }
        if(alertView.tag == 2)
        {
            [self.view endEditing:YES];
            reJectDialog = nil;
            UITextField *reasonField = [alertView textFieldAtIndex:0];
            if (reasonField.text.length == 0) {
                [self performSelector:@selector(rejectAction:) withObject:nil afterDelay:0.8f];
                [Tool showCustomHUD:@"Please Write ReJect Reason" andView:self.view andImage:nil andAfterDelay:1.2f];
            }
            else
            {
                rejectContent = reasonField.text;
                [self doReject];
            }
        }
    }
    if(buttonIndex == 1)
    {
        if(alertView.tag == 1)
        {
            [fileArray removeObjectAtIndex:selectPicIndex];
            [self reloadPhotoHeight:NO andIsInit:NO];
            [self.photoCollectionView reloadData];
        }
    }
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)doReject
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetApplyInfo_En '%@'", self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestApplyInfo:)];
    [request startAsynchronous];
}

- (void)requestApplyInfo:(ASIHTTPRequest *)request
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
        if (jsonArray && [jsonArray count] > 0) {
            applyWorkArray = [Tool readJsonToObjArray:jsonArray andObjClass:[NextWorkFlow class]];
            NextWorkFlow *applyWorkFlow = applyWorkArray[0];
            NSString *nextStr = @"";
            //流程第2步！ 总部审批（流程驳回）      IM角色  AM角色       StepID = 1，
            if(applyWorkFlow.StepID == 1 && ([jiaose isEqualToString:@"IM"] || [jiaose isEqualToString:@"AM"]))
            {
                nextStr = [NSString stringWithFormat:@"%d/%d", applyWorkFlow.StepID, applyWorkFlow.NextUserNameCode];
                Operation = rejectContent;
            }
            
            [self FlowNextSubmit:nextStr];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [fileArray count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCollectionCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ImageCollectionCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ImageCollectionCell class]]) {
                cell = (ImageCollectionCell *)o;
                break;
            }
        }
    }
    NSUInteger row = [indexPath row];
    id image = [fileArray objectAtIndex:row];
//    UIImage *picImage = [fileArray objectAtIndex:row];
//    cell.picIV.image = picImage;
    if ([image isKindOfClass:[UIImage class]]) {
        cell.picIV.image = (UIImage *)image;
    }
    else
    {
        Img *picImage = (Img *)image;
        [cell.picIV sd_setImageWithURL:[NSURL URLWithString:picImage.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    }
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 90);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isQuery) {
        NSUInteger row = [indexPath row];
        if (row == [fileArray count] -1) {
            UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"拍照", @"从相册中选取", nil];
            cameraSheet.tag = 0;
            [cameraSheet showInView:self.view];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Please choose?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Preview", @"Delete", @"Cancel", nil];
            alert.tag = 1;
            selectPicIndex = row;
            [alert show];
        }
    }
    else
    {
        [self.photos removeAllObjects];
        if ([self.photos count] == 0) {
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            for (Img *image in fileArray) {
                MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:image.Url]];
                [photos addObject:photo];
            }
            self.photos = photos;
        }
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = NO;//左右分页切换,默认否
        browser.displaySelectionButtons = NO;//是否显示选择按钮在图片上,默认否
        browser.alwaysShowControls = YES;//控制条件控件 是否显示,默认否
        browser.zoomPhotosToFill = NO;//是否全屏,默认是
        //    browser.wantsFullScreenLayout = YES;//是否全屏
        [browser setCurrentPhotoIndex:[indexPath row]];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:browser animated:YES];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//照片处理START
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                
                fromCamera = YES;
                
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
        else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                
                fromCamera = NO;
                
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *smallImage = [self imageByScalingToMaxSize:portraitImg];
        
        if (fromCamera) {
            [self saveImageToPhotos:portraitImg];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
        UIImage *tImg = [UIImage imageWithData:imageData];
        
        [fileArray insertObject:smallImage atIndex:[fileArray count] -1];
        [self reloadPhotoHeight:YES andIsInit:NO];
        [self.photoCollectionView reloadData];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
}
//拍照处理END

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)checkFlowRecord:(id)sender {
    FlowRecordView *recordView = [[FlowRecordView alloc] init];
    recordView.Mark = self.Mark;
    [self.navigationController pushViewController:recordView animated:YES];
}
@end
