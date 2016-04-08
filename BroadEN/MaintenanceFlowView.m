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
#import "FlowRecordView.h"

//获取数据
//select M.*,P.PROJ_Name from TB_CUST_ProjInf_MatnRec AS M,TB_CUST_ProjInf as P where P.PROJ_ID = M.Proj_ID and M.Mark='"+intent.getStringExtra("id")+"'

@interface MaintenanceFlowView ()
{
    UserInfo *userinfo;
    
    Maintaining *maintaining;
    NSMutableDictionary *picDic;
    NSArray *picArray;
    NSMutableArray *otherPicArray;
    NSString *allfilename02Url;
    NSString *allfilename03Url;
    NSString *allfilename04Url;
    
    NSString *allfilename02;
    NSString *allfilename03;
    NSString *allfilename04;
    
    NSMutableArray *_photos;
    
    NSString *jiaose;
    NSString *UserName;
    NSString *EnName;
    NSString *UserNameEN;
    
    NextWorkFlow *nextWorkFlow;
    NSArray *nextWorkArray;
    NSArray *applyWorkArray;
    NSArray *nextWorkArrayForWrite;
    
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
    
    BOOL isUpdateBasic;
    
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceItemIndex;
    NSInteger selectedUnitIndex;
    NSInteger selectedPicIndex;
    NSInteger selectOtherPicIndex;
    
    NSString *AirCondUnit_Mode;
    NSString *OutFact_Num;
    NSString *Pro_Num;
    NSString *Type;
    NSString *Type_En;
    NSString *Project;
    NSString *Project_En;
    
    NSDate *serviceDate;
    
    NSString *delFileStr;
    NSString *newsallfilenameStr;
    NSMutableArray *newsPicArray;
    
    NSString *nextSql;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation MaintenanceFlowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Maintenance";
    
    if(!self.isQuery)
    {
        UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
        self.navigationItem.rightBarButtonItem = submitBtn;
    }
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    UserName = userinfo.UserName;
    EnName = userinfo.EnName;
    UserNameEN = userinfo.EnName;
    jiaose = userinfo.JiaoSe;
    
    isReject = NO;
    fromCamera = NO;
    isUpdateBasic = NO;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    //初始化图片区域
    delFileStr = @"";
    picDic = [[NSMutableDictionary alloc] init];
    otherPicArray = [[NSMutableArray alloc] init];
    newsPicArray = [[NSMutableArray alloc] init];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    //由于计算图片高度需要在获取流程所有字段后（reloadOtherHeight）再根据流程执行情况，绘制界面
    //[self getFlowNextInfo];
    [self getMaintenanceData];
    
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
        if (alertView.tag == 0) {
            id img = [otherPicArray objectAtIndex:selectOtherPicIndex];
            if ([img isKindOfClass:[Img class]]) {
                Img *picImage = (Img *)img;
                [self.photos removeAllObjects];
                if ([self.photos count] == 0) {
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:picImage.Url]];
                    [photos addObject:photo];
                    self.photos = photos;
                }
            }
            else if([img isKindOfClass:[UIImage class]])
            {
                UIImage *picImage = (UIImage *)img;
                [self.photos removeAllObjects];
                if ([self.photos count] == 0) {
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    MWPhoto * photo = [MWPhoto photoWithImage:picImage];
                    [photos addObject:photo];
                    self.photos = photos;
                }
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
        
        if(alertView.tag == 1)
        {
            UIImage *picImage = [picDic objectForKey:[NSString stringWithFormat:@"%d", (int)selectedPicIndex]];
            if(picImage)
            {
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
            else
            {
                NSString *imageUrl=nil;
                switch (selectedPicIndex)
                {
                    case 0:
                        imageUrl = allfilename02Url;
                        break;
                    case 1:
                        imageUrl = allfilename04Url;
                        break;
                    case 2:
                        imageUrl = allfilename03Url;
                        break;
                }
                if(imageUrl)
                {
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
            }
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
        if (alertView.tag == 0) {
            id img = [otherPicArray objectAtIndex:selectOtherPicIndex];
            if ([img isKindOfClass:[Img class]]) {
                Img *picImage = (Img *)img;
                NSString *delname = [NSString stringWithFormat:@"|%@", [picImage.Url lastPathComponent]];
                if(newsallfilenameStr.length > 30)
                {
                    newsallfilenameStr = [newsallfilenameStr stringByReplacingOccurrencesOfString:delname withString:@""];
                }
                else
                {
                    newsallfilenameStr = @"";
                }
                delFileStr = [NSString stringWithFormat:@"%@%@", delFileStr, delname];
            }
            else if([img isKindOfClass:[UIImage class]])
            {
                UIImage *picImage = (UIImage *)img;
                [newsPicArray removeObject:picImage];
            }
            
            [otherPicArray removeObjectAtIndex:selectOtherPicIndex];
            [self reloadOtherHeight:NO andIsInit:NO];
            [self.otherCollectionView reloadData];
        }
        
        if(alertView.tag == 1)
        {
            [picDic removeObjectForKey:[NSString stringWithFormat:@"%d", (int)selectedPicIndex]];
            
            switch (selectedPicIndex)
            {
                case 0:
                    self.ServiceFormIV.image = [UIImage imageNamed:@"addPic"];
                    if (allfilename02) {
                        NSString *delname = [NSString stringWithFormat:@"|%@", [allfilename02Url lastPathComponent]];
                        delFileStr = [NSString stringWithFormat:@"%@%@", delFileStr, delname];
                        allfilename02 = nil;
                        allfilename02Url = nil;
                    }
                    break;
                case 1:
                    self.SnecePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    if (allfilename04) {
                        NSString *delname = [NSString stringWithFormat:@"|%@", [allfilename04Url lastPathComponent]];
                        delFileStr = [NSString stringWithFormat:@"%@%@", delFileStr, delname];
                        allfilename04 = nil;
                        allfilename04Url = nil;
                    }
                    break;
                case 2:
                    self.TouchSencePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    if (allfilename03) {
                        NSString *delname = [NSString stringWithFormat:@"|%@", [allfilename03Url lastPathComponent]];
                        delFileStr = [NSString stringWithFormat:@"%@%@", delFileStr, delname];
                        allfilename03 = nil;
                        allfilename03Url = nil;
                    }
                    break;
            }
        }
    }
}

- (void)submitAction:(id )sender
{
    nextSql = @"";
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
    //流程被驳回！ 工程师重新提交   SE   FJ   GJJXS    StepID = 2，
    if(nextWorkFlow.StepID == 2 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
    {
        NSString *serviceType = self.serviceTypeTF.text;
        NSString *serviceItem = self.serviceItemTF.text;
        NSString *serviceTFDate = self.serviceDateTF.text;
        NSString *unitNum = self.unitTF.text;
        NSString *engineerNote = self.EngineerNoteTV.text;
        if (serviceType.length == 0)
        {
            [Tool showCustomHUD:@"please choose Service Type" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if (serviceItem.length == 0)
        {
            [Tool showCustomHUD:@"please choose Service Item" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if (serviceTFDate.length == 0)
        {
            [Tool showCustomHUD:@"please choose Service Date" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if (unitNum.length == 0)
        {
            [Tool showCustomHUD:@"please choose Unit" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if (!allfilename02 && ![picDic objectForKey:@"0"]) {
            [Tool showCustomHUD:@"please upload Service Form" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if (engineerNote.length == 0)
        {
            [Tool showCustomHUD:@"please engineerNote" andView:self.view andImage:nil andAfterDelay:1.2f];
            return;
        }
        if ([self.serviceTypeTF.text isEqualToString:@"Annual 4 times maintenace"])
        {
            if([maintaining.OutFact_Num isEqualToString:OutFact_Num] && [maintaining.Project_En isEqualToString:Project_En])
            {
                nextSql = @"step1";
            }
            else
            {
                NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
                NSInteger year = [datec year];
                NSString *sql = [NSString stringWithFormat:@"Select COUNT(*) From TB_CUST_ProjInf_MatnRec Where Project='%@' and Proj_ID='%@' and OutFact_Num='%@' and YEAR(UploadTime)=%d", Project, maintaining.Proj_ID, OutFact_Num, (int)year];
                
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url]]];
                
                [request setUseCookiePersistence:NO];
                [request setTimeOutSeconds:30];
                
                [request setPostValue:sql forKey:@"sqlstr"];
                [request setDefaultResponseEncoding:NSUTF8StringEncoding];
                [request startSynchronous];
                
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
                    NSLog(string);
                    NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSDictionary *dic = table[0];
                    NSString *count = [dic objectForKey:@"Column1"];
                    if([count intValue] > 0)
                    {
                        if (hud) {
                            [hud hide:YES];
                        }
                        [Tool showCustomHUD:@"This Type record already exists" andView:self.view andImage:nil andAfterDelay:1.2f];
                        nextSql = @"already";
                    }
                    else
                    {
                        nextSql = @"step1";
                    }
                };
                [utils stringFromparserXML:request.responseString target:@"string"];
            }
        }
        else
        {
            nextSql = @"step1";
        }
    }
    
    if ([nextSql isEqualToString:@"already"]) {
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:hud];
    
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
                 if([nextSql isEqualToString:@"step1"])
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
    for(NSString *key in picDic)
    {
        imgbegin = nil;
        imgbegin = picDic[key];
        if(imgbegin)
        {
            int random = (arc4random() % 501) + 500;
            NSString *picFirstName = @"ServiceForm";
            switch ([key intValue])
            {
                case 0:
                    picFirstName = @"ServiceForm";
                    break;
                case 1:
                    picFirstName = @"ScenePhoto";
                    break;
                case 2:
                    picFirstName = @"TouchSencePhoto";
                    break;
            }
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%i.jpg",picFirstName,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],random];
            
            BOOL isOK = [self upload:imgbegin oldName:reName Index:[key intValue]];
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
    for(int i = 0; i < newsPicArray.count; ++i)
    {
        imgbegin = nil;
        imgbegin = newsPicArray[i];
        if(imgbegin)
        {
            int random = (arc4random() % 501) + 500;
            NSString *picFirstName = @"Other";
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%i.jpg",picFirstName,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],random];
            BOOL isOK = [self upload:imgbegin oldName:reName Index:4];
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
    
    if(delFileStr.length > 0)
    {
        [self deleteImg];
    }
    [self jointSQLForReWrite];
}

- (void)deleteImg
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DeleteMultFile",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:delFileStr forKey:@"fileNames"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        
        if([response rangeOfString:@"true"].length > 0)
        {
        }
    }
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
                NSRange range = [response rangeOfString:@"/UploadFile"];//匹配得到的下标
                range.length = range.length + 10;
                NSString *string = [response substringWithRange:range];//截取范围类的字符串
                NSLog(@"截取的值为：%@",response);
                
                //                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
                img = nil;
                base64Encoded = nil;
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, userinfo.UserName, userinfo.EnName, string, @"维护保养(IOS app)"];
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
                        switch (index)
                        {
                            case 0:
                                allfilename02 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 1:
                                allfilename04 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 2:
                                allfilename03 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 4:
                                if(newsallfilenameStr == nil || [newsallfilenameStr isEqualToString:@"null"])
                                {
                                    newsallfilenameStr = @"";
                                }
                                newsallfilenameStr = [NSString stringWithFormat:@"%@|%@",newsallfilenameStr,fileName];
                                newsallfilenameStr = [newsallfilenameStr stringByReplacingOccurrencesOfString:@"null" withString:@""];
                                break;
                        }
                    }
                }
            }
        }
    }
    return isOK;
}

- (void)jointSQLForReWrite
{
    if(![Tool isStringExist:allfilename02])
    {
        allfilename02 = @"null";
    }
    else
    {
        allfilename02 = [NSString stringWithFormat:@"'%@'", allfilename02];
    }
    
    if(![Tool isStringExist:allfilename04])
    {
        allfilename04 = @"null";
    }
    else
    {
        allfilename04 = [NSString stringWithFormat:@"'%@'", allfilename04];
    }
    
    if(![Tool isStringExist:allfilename03])
    {
        allfilename03 = @"null";
    }
    else
    {
        allfilename03 = [NSString stringWithFormat:@"'%@'", allfilename03];
    }
    
    if(![Tool isStringExist:newsallfilenameStr])
    {
        newsallfilenameStr = @"null";
    }
    else
    {
        newsallfilenameStr = [NSString stringWithFormat:@"'%@'", newsallfilenameStr];
    }
    
    NSString *EngineerNote = [self.EngineerNoteTV.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_MatnRec] set Exec_Man=@Exec_Man,Exec_Man_En=@Exec_Man_En,Exec_Date=@Exec_Date,AirCondUnit_Mode=@AirCondUnit_Mode,OutFact_Num=@OutFact_Num,Pro_Num=@Pro_Num,Type=@Type,Type_En=@Type_En,Project=@Project,Project_En=@Project_En,Uploader=@Uploader,Uploader_En=@Uploader_En,UploadTime=@UploadTime,allfilename=@allfilename,allfilename02=@allfilename02,allfilename03=@allfilename03,allfilename04=@allfilename04,EngineerNote=@EngineerNote,EngineerSign=@EngineerSign,EngineerSignDate=@EngineerSignDate where Mark=@Mark ',N'@Exec_Man varchar(50),@Exec_Man_En varchar(100),@Exec_Date datetime,@AirCondUnit_Mode varchar(200),@OutFact_Num varchar(50),@Pro_Num varchar(50),@Type varchar(50),@Type_En varchar(50),@Project varchar(50),@Project_En varchar(400),@Uploader varchar(50),@Uploader_En varchar(100),@UploadTime datetime,@allfilename varchar(8000),@allfilename02 varchar(8000),@allfilename03 varchar(8000),@allfilename04 varchar(8000),@EngineerNote varchar(5000),@EngineerSign varchar(50),@EngineerSignDate datetime,@Mark varchar(50)',@Exec_Man='%@',@Exec_Man_En='%@',@Exec_Date='%@',@AirCondUnit_Mode='%@',@OutFact_Num='%@',@Pro_Num='%@',@Type='%@',@Type_En='%@',@Project='%@',@Project_En='%@',@Uploader='%@',@Uploader_En='%@',@UploadTime='%@',@allfilename=%@,@allfilename02=%@,@allfilename03=%@,@allfilename04=%@,@EngineerNote='%@',@EngineerSign='%@',@EngineerSignDate='%@',@Mark='%@'", userinfo.UserName, userinfo.EnName, self.serviceDateTF.text, AirCondUnit_Mode, OutFact_Num, Pro_Num, Type, Type_En, Project, Project_En, userinfo.UserName, userinfo.EnName, self.UploadDateTF.text, newsallfilenameStr, allfilename02, allfilename03, allfilename04, EngineerNote, userinfo.EnName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], self.Mark];
    
    [self updateMainData:sql];
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
            [Tool showCustomHUD:@"Submit failure" andView:self.view andImage:nil andAfterDelay:1.2f];
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
    else if (isUpdateBasic)
    {
        for(NextWorkFlow *nextWork in nextWorkArrayForWrite)
        {
            [StepNames addObject:nextWork.StepName];
            [NextUserNames addObject:nextWork.NextUserName];
        }
        selectNextFlowArray = nextWorkArrayForWrite;
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
        //流程第2步！ 主管审核   SH       StepID = 3，
        if(selectNextWork.StepID == 3 && [jiaose isEqualToString:@"SH"])
        {
            Operation = @"IOS app transact";
        }
        //流程第3步！ 总部审核   IM        StepID = 4，
        if(selectNextWork.StepID == 4 && [jiaose isEqualToString:@"IM"])
        {
            Operation = @"IOS app HQ check";
        }
        //流程第4步！ 工程师反馈 SE   FJ   GJJXS        StepID = 4， NextUserNameCode=-1
        if(selectNextWork.StepID == 4 && selectNextWork.NextUserNameCode == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
        {
            Operation = @"IOS app engineer feedback";
        }
        //流程被驳回！ 工程师重新提交   SE   FJ   GJJXS    StepID = 2，
        if(selectNextWork.StepID == 2 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
        {
            Operation = @"IOS app ParentAudit";
        }
        //流程被驳回！ 工程师结束办理   SE   FJ   GJJXS    StepID = 2，
        if(selectNextWork.StepID == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
        {
            Operation = @"IOS app Over";
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
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:request.hud];
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

-(void)getFlowNextInfoForReWrite
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetFlowInfoInSomeStep_En '%@'", self.Mark];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestFlowNextInfoForReWrite:)];
    [request startAsynchronous];
}

- (void)requestFlowNextInfoForReWrite:(ASIHTTPRequest *)request
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
            nextWorkArrayForWrite = [Tool readJsonToObjArray:jsonArray andObjClass:[NextWorkFlow class]];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
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
                if(!self.isQuery)
                {
                    //如果是第二步就会有回退按钮
                    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"|  Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
                    UIBarButtonItem *rollbackBtn = [[UIBarButtonItem alloc] initWithTitle: @"Reject  " style:UIBarButtonItemStyleBordered target:self action:@selector(rejectAction:)];
                    NSArray *buttonArray = [[NSArray alloc] initWithObjects:submitBtn,rollbackBtn , nil];
                    self.navigationItem.rightBarButtonItems = buttonArray;
                    
                    
                    
                    //                self.RatingTF.enabled = YES;
                    self.selectRatingBtn.enabled = YES;
                    self.ManagerNoteTV.editable = YES;
                    self.ManagerSignLB.text = UserName;
                    self.ManagerSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.UserHQView.hidden = YES;
                self.EngineerFeedbackView.hidden = YES;
                
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.ManagerView.frame.origin.y + self.ManagerView.frame.size.height);
            }
            //流程第3步！ 总部审核   IM        StepID = 4，
            if(nextWorkFlow.StepID == 4 && [jiaose isEqualToString:@"IM"])
            {
                if(!self.isQuery)
                {
                    //                self.RatingTF.enabled = YES;
                    self.selectRatingBtn.enabled = YES;
                    self.UserHQNoteTV.editable = YES;
                    self.UserHQSignLB.text = UserName;
                    self.UserHQSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                }
                
                self.EngineerFeedbackView.hidden = YES;
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserHQView.frame.origin.y + self.UserHQView.frame.size.height);
            }
            //流程第4步！ 工程师反馈 SE   FJ   GJJXS        StepID = 5，
            if(nextWorkFlow.StepID == 4 && nextWorkFlow.NextUserNameCode == -1 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
            {
                if(!self.isQuery)
                {
                    self.EngineerFeedbackTV.editable = YES;
                    self.EngineerFeedbackSignLB.text = UserName;
                    self.EngineerFeedbackSignDateLB.text = [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"];
                    
                    self.selectRatingBtn.enabled = NO;
                }
                
                self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.EngineerFeedbackView.frame.origin.y + self.EngineerFeedbackView.frame.size.height);
            }
            //流程被驳回！ 工程师重新提交   SE   FJ   GJJXS    StepID = 2，
            if(nextWorkFlow.StepID == 2 && ([jiaose isEqualToString:@"SE"] || [jiaose isEqualToString:@"FJ"] || [jiaose isEqualToString:@"GJJXS"]))
            {
                self.ManagerView.hidden = YES;
                self.UserHQView.hidden = YES;
                self.EngineerFeedbackView.hidden = YES;
                
                if(!self.isQuery)
                {
                    isUpdateBasic = YES;
                    //流程特殊，特殊处理
                    [self getFlowNextInfoForReWrite];
                    
                    
                    
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
                    
                    if (![Tool isStringExist: maintaining.allfilename02]) {
                        self.ServiceFormIV.image = [UIImage imageNamed:@"addPic"];
                    }
                    if (![Tool isStringExist: maintaining.allfilename04]) {
                        self.SnecePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    }
                    if (![Tool isStringExist: maintaining.allfilename03]) {
                        self.TouchSencePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    }
                    
                    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
                    [otherPicArray addObject:addPicImage];
                    [self reloadOtherHeight:YES andIsInit:YES];
                    [self.otherCollectionView reloadData];
                }
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)picCheckAction:(UITapGestureRecognizer *)recognizer
{
    NSUInteger tag = recognizer.view.tag;
    selectedPicIndex = tag;
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
    if(isUpdateBasic)
    {
        if(imageUrl || [picDic objectForKey:[NSString stringWithFormat:@"%d", (int)selectedPicIndex]])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Please choose?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Preview", @"Delete", @"Cancel", nil];
            alert.tag = 1;
            [alert show];
        }
        else
        {
            UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Take Photo", @"Choose from Photos", nil];
            cameraSheet.tag = 0;
            [cameraSheet showInView:self.view];
        }
    }
    else
    {
        if(imageUrl)
        {
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
        
        AirCondUnit_Mode = maintaining.AirCondUnit_Mode;
        OutFact_Num = maintaining.OutFact_Num;
        Pro_Num = maintaining.Pro_Num;
        Type = maintaining.Type;
        Type_En = maintaining.Type_En;
        Project = maintaining.Project;
        Project_En = maintaining.Project_En;
        
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
            allfilename02 = maintaining.allfilename02;
            [self getImg:maintaining.allfilename02 andImageIndex:0];
        }
        if (maintaining.allfilename04.length > 0) {
            allfilename04 = maintaining.allfilename04;
            [self getImg:maintaining.allfilename04 andImageIndex:1];
        }
        if (maintaining.allfilename03.length > 0) {
            allfilename03 = maintaining.allfilename03;
            [self getImg:maintaining.allfilename03 andImageIndex:2];
        }
        newsallfilenameStr = @"";
        if (maintaining.allfilename.length > 0) {
            newsallfilenameStr = maintaining.allfilename;
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
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:hud];
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
    
    if (isUpdateBasic) {
        self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.mainView.frame.size.height);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.EngineerFeedbackView.frame.origin.y + self.EngineerFeedbackView.frame.size.height);
    }
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
    //    Img *picImage = [otherPicArray objectAtIndex:row];
    //    [cell.picIV sd_setImageWithURL:[NSURL URLWithString:picImage.Url] placeholderImage:[UIImage imageNamed:@"loadingpic"]];
    
    id image = [otherPicArray objectAtIndex:row];
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
    if (isUpdateBasic) {
        selectedPicIndex = 100;
        NSUInteger row = [indexPath row];
        if (row == [otherPicArray count] -1) {
            UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Take Photo", @"Choose from Photos", nil];
            cameraSheet.tag = 0;
            [cameraSheet showInView:self.view];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Please choose?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Preview", @"Delete", @"Cancel", nil];
            alert.tag = 0;
            selectOtherPicIndex = row;
            [alert show];
        }
    }
    else{
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
        if(selectedPicIndex != 100)
        {
            switch (selectedPicIndex)
            {
                case 0:
                    [self.ServiceFormIV setImage:tImg];
                    break;
                case 1:
                    [self.SnecePhotoIV setImage:tImg];
                    break;
                case 2:
                    [self.TouchSencePhotoIV setImage:tImg];
                    break;
            }
            [picDic setObject:tImg forKey:[NSString stringWithFormat:@"%d",(int)selectedPicIndex]];
        }
        else
        {
            [newsPicArray addObject:smallImage];
            [otherPicArray insertObject:smallImage atIndex:[otherPicArray count] -1];
            [self reloadOtherHeight:YES andIsInit:NO];
            [self.otherCollectionView reloadData];
        }
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
                                  Type = [selectServiceTypeDic objectForKey:@"typeCN"];
                                  Type_En = [selectServiceTypeDic objectForKey:@"typeEN"];
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
                                  Project = [selectServiceItemDic objectForKey:@"itemCN"];
                                  Project_En = [selectServiceItemDic objectForKey:@"itemEN"];
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
                              OutFact_Num = selectedUnit.OutFact_Num;
                              Pro_Num = selectedUnit.Prod_Num;
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

- (IBAction)selectRatingAction:(id)sender {
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

- (IBAction)checkFlowRecord:(id)sender {
    FlowRecordView *recordView = [[FlowRecordView alloc] init];
    recordView.Mark = self.Mark;
    [self.navigationController pushViewController:recordView animated:YES];
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

@end
