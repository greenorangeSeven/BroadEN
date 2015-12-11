//
//  MaintenanceFlowView.m
//  BroadEN
//
//  Created by Seven on 15/12/11.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MaintenanceFlowView.h"
#import "ImageCollectionCell.h"
#import "Maintaining.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "NextWorkFlow.h"
#import "SGActionView.h"
#import "UnitInfo.h"

//获取数据
//select M.*,P.PROJ_Name from TB_CUST_ProjInf_MatnRec AS M,TB_CUST_ProjInf as P where P.PROJ_ID = M.Proj_ID and M.Mark='"+intent.getStringExtra("id")+"'

@interface MaintenanceFlowView ()
{
    UserInfo *userinfo;
    
    Maintaining *maintaining;
    NSArray *picArray;
    NSMutableArray *otherPicArray;
    NSString *allfilename02Url;
    NSString *allfilename03Url;
    NSString *allfilename04Url;
    
    NSMutableArray *_photos;
    
    NSString *jiaose;
    NSString *UserName;
    NSString *EnName;
    NSString *UserNameEN;
    
    NextWorkFlow *nextWorkFlow;
    NSArray *nextWorkArray;
    NSArray *applyWorkArray;
    
    UIAlertView *reJectDialog;
    BOOL isReject;
    NSString *rejectContent;
    
    NSUInteger selectedRaingIndex;
    
    NSString *Operation;
    
    MBProgressHUD *hud;
    
    NSArray *serviceTypeDicArray;//服务类型字典数组
    NSMutableArray *serviceTypeENArray;//服务类型英文名称数组
    NSDictionary *selectServiceTypeDic;
    NSArray *serviceItemDicArray;//服务项目字典数组
    NSMutableArray *serviceItemENArray;//服务项目英文数组
    NSDictionary *selectServiceItemDic;
    NSArray *units;
    UnitInfo *selectedUnit;
    NSMutableArray *outFactNumArray;
    
    BOOL fromCamera;
    
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceItemIndex;
    NSInteger selectedUnitIndex;
    NSInteger selectedPicIndex;
    
    NSString *AirCondUnit_Mode;
    NSDate *serviceDate;
    NSString *serviceItemCN;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation MaintenanceFlowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Maintenance";
    
    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = submitBtn;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    UserName = userinfo.UserName;
    EnName = userinfo.EnName;
    UserNameEN = userinfo.EnName;
    jiaose = userinfo.JiaoSe;
    
    isReject = NO;
    fromCamera = NO;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    otherPicArray = [[NSMutableArray alloc] init];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    //由于计算图片高度需要在获取流程所有字段后（reloadOtherHeight）再根据流程执行情况，绘制界面
    //[self getFlowNextInfo];
    [self getMaintenanceData];
    
    self.RatingTF.delegate = self;
    self.RatingTF.tag = 5;
    selectedRaingIndex = 100;
    
    UITapGestureRecognizer *serviceFormTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picCheckAction:)];
    self.ServiceFormIV.tag = 0;
    [self.ServiceFormIV addGestureRecognizer:serviceFormTap];
    
    UITapGestureRecognizer *snecePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picCheckAction:)];
    self.SnecePhotoIV.tag = 1;
    [self.SnecePhotoIV addGestureRecognizer:snecePhotoTap];
    
    UITapGestureRecognizer *touchSencePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picCheckAction:)];
    self.TouchSencePhotoIV.tag = 2;
    [self.TouchSencePhotoIV addGestureRecognizer:touchSencePhotoTap];
}

- (void)rejectAction:(id )sender
{
    reJectDialog = [[UIAlertView alloc] initWithTitle:@"ReJect" message:@"Please Write ReJect Reason" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:@"cancel",nil];
    reJectDialog.tag = 2;
    [reJectDialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [reJectDialog show];
    isReject = YES;
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
            //流程第2步！ 主管审核   SH（可驳回）       StepID = 3，
            if(nextWorkFlow.StepID == 3 && [jiaose isEqualToString:@"SH"])
            {
                nextStr = [NSString stringWithFormat:@"%d/%d", applyWorkFlow.StepID, applyWorkFlow.NextUserNameCode];
                Operation = rejectContent;
            }
            
            [self FlowNextSubmit:nextStr];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
//        if(alertView.tag == 1)
//        {
//            [fileArray removeObjectAtIndex:selectPicIndex];
//            [self reloadPhotoHeight:NO];
//            [self.photoCollectionView reloadData];
//        }
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
}

- (void)submitAction:(id )sender
{
    NSString *nextSql = @"";
    isReject = NO;
    //流程第2步！ 主管审核   SH       StepID = 3，
    if(nextWorkFlow.StepID == 3 && [jiaose isEqualToString:@"SH"])
    {
        NSString *RatingStr = self.RatingTF.text;
        NSString *ManagerNoteStr = self.ManagerNoteTV.text;
        if (ManagerNoteStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write Manager Opinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        ManagerNoteStr = [ManagerNoteStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_MatnRec] set Rating=@Rating,ManagerNote=@ManagerNote,ManagerSign=@ManagerSign,ManagerSignDate=@ManagerSignDate where Mark=@Mark ',N'@Rating varchar(10),@ManagerNote varchar(5000),@ManagerSign varchar(50),@ManagerSignDate datetime,@Mark varchar(50) ',@Rating='%@',@ManagerNote='%@',@ManagerSign='%@',@ManagerSignDate='%@',@Mark='%@'", RatingStr, ManagerNoteStr, EnName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    }
    //流程第3步！ 总部审核   IM        StepID = 4，
    if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"IM"])
    {
        NSString *RatingStr = self.RatingTF.text;
        NSString *UserHQNoteStr = self.UserHQNoteTV.text;
        if (UserHQNoteStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write UserHQConfirm Opinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        UserHQNoteStr = [UserHQNoteStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_MatnRec] set Rating=@Rating,UserHQNote=@UserHQNote,UserHQSign=@UserHQSign,UserHQSignDate=@UserHQSignDate where Mark=@Mark ',N'@Rating varchar(10),@UserHQNote varchar(5000),@UserHQSign varchar(50),@UserHQSignDate datetime,@Mark varchar(50) ',@Rating='%@',@UserHQNote='%@',@UserHQSign='%@',@UserHQSignDate='%@',@Mark='%@'", RatingStr, UserHQNoteStr, EnName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    }
    //流程第4步！ 工程师反馈 SE   FJ   GJJXS        StepID = 4， NextUserNameCode=-1
    if(nextWorkFlow.StepID == 4 && nextWorkFlow.NextUserNameCode == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
    {
        NSString *EngineerFeedbackStr = self.EngineerFeedbackTV.text;
        if (EngineerFeedbackStr.length == 0)
        {
            [Tool showCustomHUD:@"Please Write EngineerFeedback Opinion" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        
        EngineerFeedbackStr = [EngineerFeedbackStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        nextSql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_MatnRec] set EngineerFeedback=@EngineerFeedback,EngineerFeedbackSign=@EngineerFeedbackSign,EngineerFeedbackSignDate=@EngineerFeedbackSignDate where Mark=@Mark ',N'@EngineerFeedback varchar(5000),@EngineerFeedbackSign varchar(50),@EngineerFeedbackSignDate datetime,@Mark varchar(50) ',@EngineerFeedback='%@',@EngineerFeedbackSign='%@',@EngineerFeedbackSignDate='%@',@Mark='%@'", EngineerFeedbackStr, EnName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
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
//                 if([nextSql isEqualToString:@"step5"])
//                 {
//                     [self updateImg];
//                 }
//                 else
//                 {
                     [self updateMainData:nextSql];
//                 }
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
        if (hud) {
            [hud hide:YES];
        }
        if([response rangeOfString:@"true"].length > 0)
        {
            [self selectNextUser];
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
    if (isReject) {
        for(NextWorkFlow *nextWork in applyWorkArray)
        {
            [StepNames addObject:nextWork.StepName];
            [NextUserNames addObject:nextWork.NextUserName];
        }
    }
    else
    {
        for(NextWorkFlow *nextWork in nextWorkArray)
        {
            [StepNames addObject:nextWork.StepName];
            [NextUserNames addObject:nextWork.NextUserName];
        }
    }
    [SGActionView showSheetWithTitle:@"Please Select" itemTitles:NextUserNames itemSubTitles:StepNames selectedIndex:0 selectedHandle:^(NSInteger index){
        NextWorkFlow *selectNextWork = nextWorkArray[index];
        
        NSString *nextStr = @"";
        //流程第2步！ 主管审核   SH       StepID = 3，
        if(nextWorkFlow.StepID == 3 && [jiaose isEqualToString:@"SH"])
        {
            Operation = @"IOS app transact";
        }
        //流程第3步！ 总部审核   IM        StepID = 4，
        if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"IM"])
        {
            Operation = @"IOS app HQ check";
        }
        //流程第4步！ 工程师反馈 SE   FJ   GJJXS        StepID = 4， NextUserNameCode=-1
        if(nextWorkFlow.StepID == 4 && nextWorkFlow.NextUserNameCode == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
        {
            Operation = @"IOS app engineer feedback";
        }
        nextStr = [NSString stringWithFormat:@"%d/%d", selectNextWork.StepID, selectNextWork.NextUserNameCode];
        [self FlowNextSubmit:nextStr];
    }];
}

- (void)FlowNextSubmit:(NSString *)nextStr
{
    NSString *sql = @"";
    if(isReject)
    {
        sql = [NSString stringWithFormat:@"SP_FlowSubmit_En @UserName='%@',@AcionID=-1,@NextStr='%@',@Mark='%@',@FlowName='维护保养审批(英文版)',@Data=N'%@'", UserName, nextStr, self.Mark, Operation];
    }
    else
    {
        sql = [NSString stringWithFormat:@"SP_FlowSubmit_En @UserName='%@',@AcionID=1,@NextStr='%@',@Mark='%@',@FlowName='维护保养审批(英文版)',@Data=N'%@'", UserName, nextStr, self.Mark, Operation];
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
    NSString *sql = [NSString stringWithFormat:@"sp_executesql N'insert into [ERPRiZhi] (UserName,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@Operation='%@',@Plate='维护保养审批(英文app)',@ProjName='%@',@DoSomething='维护保养信息审批(英文版),Mark:%@',@IpStr='%@'", UserName, Operation, maintaining.PROJ_Name, self.Mark, ip];
    
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
            
            //流程第2步！ 主管审核   SH       StepID = 3，
            if(nextWorkFlow.StepID == 3 && [jiaose isEqualToString:@"SH"])
            {
                //如果是第二步就会有回退按钮
                UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"|  Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
                UIBarButtonItem *rollbackBtn = [[UIBarButtonItem alloc] initWithTitle: @"Reject  " style:UIBarButtonItemStyleBordered target:self action:@selector(rejectAction:)];
                NSArray *buttonArray = [[NSArray alloc] initWithObjects:submitBtn,rollbackBtn , nil];
                self.navigationItem.rightBarButtonItems = buttonArray;
                
                self.UserHQView.hidden = YES;
                self.EngineerFeedbackView.hidden = YES;

                self.RatingTF.enabled = YES;
                self.ManagerNoteTV.editable = YES;
                self.ManagerSignLB.text = UserName;
                self.ManagerSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];

                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.ManagerView.frame.origin.y + self.ManagerView.frame.size.height);
            }
            //流程第3步！ 总部审核   IM        StepID = 4，
            if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"IM"])
            {
                self.EngineerFeedbackView.hidden = YES;
                
                self.RatingTF.enabled = YES;
                self.UserHQNoteTV.editable = YES;
                self.UserHQSignLB.text = UserName;
                self.UserHQSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserHQView.frame.origin.y + self.UserHQView.frame.size.height);
            }
            //流程第4步！ 工程师反馈 SE   FJ   GJJXS        StepID = 5，
            if(nextWorkFlow.StepID == 4 && nextWorkFlow.NextUserNameCode == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
            {
                self.EngineerFeedbackTV.editable = YES;
                self.EngineerFeedbackSignLB.text = UserName;
                self.EngineerFeedbackSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.EngineerFeedbackView.frame.origin.y + self.EngineerFeedbackView.frame.size.height);
            }
            //流程被驳回！ 工程师重新提交   SE   FJ   GJJXS    StepID = 2，
            if(nextWorkFlow.StepID == 2 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
            {
                self.ManagerView.hidden = YES;
                self.UserHQView.hidden = YES;
                self.EngineerFeedbackView.hidden = YES;
                
                self.serviceTypeTF.enabled = YES;
                self.serviceItemTF.enabled = YES;
                self.serviceDateTF.enabled = YES;
                self.unitTF.enabled = YES;
                self.EngineerNoteTV.editable = YES;
                
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.mainView.frame.size.height);
                
                [self getUnits];
                
                serviceTypeDicArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceType.plist" ofType:nil]];
                serviceTypeENArray = [[NSMutableArray alloc] init];
                for (NSDictionary *typeDic in serviceTypeDicArray) {
                    [serviceTypeENArray addObject:[typeDic objectForKey:@"typeEN"]];
                }
                serviceItemENArray = [[NSMutableArray alloc] init];
                
                self.serviceTypeTF.delegate = self;
                self.serviceTypeTF.tag = 1;
                selectedServiceTypeIndex = 100;
                
                self.serviceItemTF.delegate = self;
                self.serviceItemTF.tag = 2;
                selectedServiceItemIndex = 100;
                
                self.serviceDateTF.delegate = self;
                self.serviceDateTF.tag = 3;
                
                self.unitTF.delegate = self;
                self.unitTF.tag = 4;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)picCheckAction:(UITapGestureRecognizer *)recognizer
{
    NSUInteger tag = recognizer.view.tag;
    NSString *imageUrl=nil;
    switch (tag) {
        case 0:
            imageUrl = allfilename02Url;
            break;
        case 1:
            imageUrl = allfilename04Url;
            break;
        case 2:
            imageUrl = allfilename03Url;
            break;
        default:
            break;
    }
    self.photos = [[NSMutableArray alloc] init];
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]];
    [photos addObject:photo];
    self.photos = photos;
    
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

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)getMaintenanceData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select M.*,P.PROJ_Name from TB_CUST_ProjInf_MatnRec AS M,TB_CUST_ProjInf as P where P.PROJ_ID = M.Proj_ID and M.Mark='%@'", self.Mark];
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
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if ([jsonArray count] > 0) {
            maintaining = [Tool readJsonDicToObj:jsonArray[0] andObjClass:[Maintaining class]];
            [self bindDetailData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindDetailData
{
    if(maintaining)
    {
        self.EngineerTF.text = maintaining.Exec_Man_En;
        self.UploadManTF.text = maintaining.Uploader_En;
        self.UploadDateTF.text = maintaining.UploadTime;
        
        self.serviceTypeTF.text = maintaining.Type_En;
        self.serviceItemTF.text = maintaining.Project_En;
        self.serviceDateTF.text = [Tool DateTimeRemoveTime:maintaining.UploadTime andSeparated:@" "];
        self.unitTF.text = maintaining.OutFact_Num;
        self.EngineerNoteTV.text = maintaining.EngineerNote;
        
        if ([Tool isStringExist:maintaining.Rating]) {
            self.RatingTF.text = maintaining.Rating;
        }
        if ([Tool isStringExist:maintaining.ManagerNote]) {
            self.ManagerNoteTV.text = maintaining.ManagerNote;
        }
        if ([Tool isStringExist:maintaining.ManagerSign]) {
            self.ManagerSignLB.text = maintaining.ManagerSign;
        }
        if ([Tool isStringExist:maintaining.ManagerSignDate]) {
            self.ManagerSignDateLB.text = maintaining.ManagerSignDate;
        }
        
        if ([Tool isStringExist:maintaining.UserHQNote]) {
            self.UserHQNoteTV.text = maintaining.UserHQNote;
        }
        if ([Tool isStringExist:maintaining.UserHQSign]) {
            self.UserHQSignLB.text = maintaining.UserHQSign;
        }
        if ([Tool isStringExist:maintaining.UserHQSignDate]) {
            self.UserHQSignDateLB.text = maintaining.UserHQSignDate;
        }
        
        if ([Tool isStringExist:maintaining.EngineerFeedback]) {
            self.EngineerFeedbackTV.text = maintaining.EngineerFeedback;
        }
        if ([Tool isStringExist:maintaining.EngineerFeedbackSign]) {
            self.EngineerFeedbackSignLB.text = maintaining.EngineerFeedbackSign;
        }
        if ([Tool isStringExist:maintaining.EngineerFeedbackSignDate]) {
            self.EngineerFeedbackSignDateLB.text = maintaining.EngineerFeedbackSignDate;
        }
        
        if (maintaining.allfilename02.length > 0) {
            [self getImg:maintaining.allfilename02 andImageIndex:0];
        }
        if (maintaining.allfilename04.length > 0) {
            [self getImg:maintaining.allfilename04 andImageIndex:1];
        }
        if (maintaining.allfilename03.length > 0) {
            [self getImg:maintaining.allfilename03 andImageIndex:2];
        }
        if (maintaining.allfilename.length > 0) {
            [self getImg:maintaining.allfilename andImageIndex:3];
        }
        else
        {
            //由于计算图片高度需要在获取流程所有字段后（reloadOtherHeight）再根据流程执行情况，绘制界面
            [self getFlowNextInfo];
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
             Img *img = picArray[0];
             if(picArray && picArray.count > 0)
             {
                 switch (imageIndex) {
                     case 0:
                         allfilename02Url = img.Url;
                         [self.ServiceFormIV sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
                         break;
                     case 1:
                         allfilename04Url = img.Url;
                         [self.SnecePhotoIV sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
                         break;
                     case 2:
                         allfilename03Url = img.Url;
                         [self.TouchSencePhotoIV sd_setImageWithURL:[NSURL URLWithString:img.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
                         break;
                     case 3:
                         otherPicArray = [NSMutableArray arrayWithArray:picArray];
                         [self reloadOtherHeight:YES andIsInit:YES];
                         //由于计算图片高度需要在获取流程所有字段后（reloadOtherHeight）再根据流程执行情况，绘制界面
                         [self getFlowNextInfo];
                         [self.otherCollectionView reloadData];
                         break;
                     default:
                         break;
                 }
                 
             }
             else
             {
                 if (imageIndex == 4) {
                     [otherPicArray removeAllObjects];
                     [self.otherCollectionView reloadData];
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

- (void)reloadOtherHeight:(BOOL )addORcutRow andIsInit:(BOOL )ISInit
{
    int addRow = 0;
    if(ISInit)
    {
        if ([otherPicArray count] % 3 > 0) {
            addRow = [otherPicArray count]/3 + 1 - 1;
        }
        else
        {
            addRow = [otherPicArray count]/3 - 1;
        }
    }
    else
    {
        if(addORcutRow)
        {
            if ([otherPicArray count] % 3 == 1) {
                addRow = 1;
            }
        }
        else
        {
            if ([otherPicArray count] % 3 == 0) {
                addRow = -1;
            }
        }
    }
    
    
    //只允许上传9张图片
    if ([otherPicArray count] == 10) {
        addRow = 0;
    }
    
    float addHeight = 100.0 * addRow;
    
    //计算框架otherCollectionView的高度
    CGRect otherFrame = self.otherCollectionView.frame;
    otherFrame.size.height = otherFrame.size.height + addHeight;
    self.otherCollectionView.frame = otherFrame;
    
    //设置attachmentView下移
    CGRect attachmentFrame = self.attachmentView.frame;
    attachmentFrame.origin.y =attachmentFrame.origin.y + addHeight;
    self.attachmentView.frame = attachmentFrame;
    
    //工程师新增信息区域View
    CGRect main2ViewFrame = self.mainView.frame;
    main2ViewFrame.size.height = main2ViewFrame.size.height + addHeight;
    self.mainView.frame = main2ViewFrame;
    
    //设置ManagerView下移
    CGRect ManagerViewFrame = self.ManagerView.frame;
    ManagerViewFrame.origin.y =ManagerViewFrame.origin.y + addHeight;
    self.ManagerView.frame = ManagerViewFrame;
    
    //设置UserHQView下移
    CGRect UserHQViewFrame = self.UserHQView.frame;
    UserHQViewFrame.origin.y =UserHQViewFrame.origin.y + addHeight;
    self.UserHQView.frame = UserHQViewFrame;
    
    //设置ManagerView下移
    CGRect EngineerFeedbackViewFrame = self.EngineerFeedbackView.frame;
    EngineerFeedbackViewFrame.origin.y =EngineerFeedbackViewFrame.origin.y + addHeight;
    self.EngineerFeedbackView.frame = EngineerFeedbackViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.EngineerFeedbackView.frame.origin.y + self.EngineerFeedbackView.frame.size.height);
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [otherPicArray count];
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
    Img *picImage = [otherPicArray objectAtIndex:row];
    [cell.picIV sd_setImageWithURL:[NSURL URLWithString:picImage.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    
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
    [self.photos removeAllObjects];
    if ([self.photos count] == 0) {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (Img *image in otherPicArray) {
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

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

- (void)getUnits
{
    NSString *sqlStr = [NSString stringWithFormat:@"select A.AirCondUnit_Mode,A.OutFact_Num,A.Prod_Num from Tb_CUST_ProjInf_AirCondUnit as A, TB_CUST_ProjInf as P where A.PROJ_ID=P.PROJ_ID and P.PROJ_ID='%@'",maintaining.Proj_ID];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestUnits:)];
    [request startAsynchronous];
}

- (void)requestUnits:(ASIHTTPRequest *)request
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
        units = [Tool readJsonToObjArray:jsonArray andObjClass:[UnitInfo class]];
        outFactNumArray = [[NSMutableArray alloc] init];
        for (UnitInfo *unit in units) {
            [outFactNumArray addObject:unit.OutFact_Num];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}


//服务类型、项目、时间等输入框不允许弹出输入法界面
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //选择服务类型
    if(textField.tag == 1)
    {
        [SGActionView showSheetWithTitle:@"Choose service type:"
                              itemTitles:serviceTypeENArray
                           itemSubTitles:nil
                           selectedIndex:selectedServiceTypeIndex
                          selectedHandle:^(NSInteger index){
                              if (selectedServiceTypeIndex != index) {
                                  selectedServiceTypeIndex = index;
                                  selectedServiceItemIndex = 100;
                                  selectServiceTypeDic = [serviceTypeDicArray objectAtIndex:index];
                                  self.serviceTypeTF.text = [serviceTypeENArray objectAtIndex:index];
                                  self.serviceItemTF.text = @"";
                                  serviceItemDicArray = [selectServiceTypeDic objectForKey:@"items"];
                                  
                                  [serviceItemENArray removeAllObjects];
                                  for (NSDictionary *itemDic in serviceItemDicArray) {
                                      [serviceItemENArray addObject:[itemDic objectForKey:@"itemEN"]];
                                  }
                              }
                          }];
    }
    //选择服务项目
    if(textField.tag == 2)
    {
        if(self.serviceTypeTF.text.length == 0)
        {
            [Tool showCustomHUD:@"Please choose service type" andView:self.view andImage:nil andAfterDelay:1.2f];
            return NO;
        }
        [SGActionView showSheetWithTitle:@"Choose service items:"
                              itemTitles:serviceItemENArray
                           itemSubTitles:nil
                           selectedIndex:selectedServiceItemIndex
                          selectedHandle:^(NSInteger index){
                              if (selectedServiceItemIndex != index) {
                                  selectedServiceItemIndex = index;
                                  selectServiceItemDic = [serviceItemDicArray objectAtIndex:index];
                                  self.serviceItemTF.text = [serviceItemENArray objectAtIndex:index];
                                  serviceItemCN = [selectServiceItemDic objectForKey:@"itemCN"];
                              }
                          }];
    }
    //选择服务时间
    else if(textField.tag == 3)
    {
        HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
        hsdpvc.delegate = self;
        if (serviceDate) {
            hsdpvc.date = serviceDate;
        }
        [self presentViewController:hsdpvc animated:YES completion:nil];
    }
    //选择机组
    if(textField.tag == 4)
    {
        [SGActionView showSheetWithTitle:@"Please choose a model:"
                              itemTitles:outFactNumArray
                           itemSubTitles:nil
                           selectedIndex:selectedUnitIndex
                          selectedHandle:^(NSInteger index){
                              selectedUnitIndex = index;
                              selectedUnit = [units objectAtIndex:index];
                              self.unitTF.text = selectedUnit.OutFact_Num;
                              AirCondUnit_Mode = selectedUnit.AirCondUnit_Mode;
                          }];
    }
    //选择评分
    if(textField.tag == 5)
    {
        NSArray *ratingArray = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", nil];
        [SGActionView showSheetWithTitle:@"Choose service type:"
                              itemTitles:ratingArray
                           itemSubTitles:nil
                           selectedIndex:selectedRaingIndex
                          selectedHandle:^(NSInteger index){
                              selectedRaingIndex = index;
                              self.RatingTF.text = [ratingArray objectAtIndex:index];
                          }];
    }
    return NO;
}

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *targetDate = [dateFormatter stringFromDate:date];
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    
    NSString *uploadDateStr = [Tool DateTimeRemoveTime:self.UploadDateTF.text andSeparated:@" "];
    
    int tag = [Tool compareOneDay:targetDate withAnotherDay:uploadDateStr];
    //如果为0则两个日期相等,如果为-1则服务时间小于于起始时间
    if(tag == 0 || tag == -1)
    {
        self.serviceDateTF.text = targetDate;
    }
    else
    {
        [Tool showCustomHUD:@"Service Date <= Upload Date" andView:self.view andImage:nil andAfterDelay:1.8f];
        return;
    }
    
    serviceDate = date;
}
//optional
- (void)hsDatePickerDidDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker did dismiss with %lu", method);
}

//optional
- (void)hsDatePickerWillDismissWithQuitMethod:(HSDatePickerQuitMethod)method {
    NSLog(@"Picker will dismiss with %lu", method);
    if(method == 1)
    {
        self.serviceDateTF.text = @"";
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
