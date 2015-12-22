//
//  UnitInfoDetailView.m
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UnitInfoDetailView.h"
#import "UnitInfoBasicOne.h"
#import "UnitInfoBasicTwo.h"
#import "UnitInfoShipping.h"
#import "UnitInfoCommiss.h"
#import "UnitInfoBasicOneCell.h"
#import "UnitInfoBasicTwoCell.h"
#import "UnitInfoShippingCell.h"
#import "UnitInfoCommissCell.h"
#import "ImageCollectionCell.h"
#import "ZeroHeightTableCell.h"
#import "SGActionView.h"
#import "Img.h"

@interface UnitInfoDetailView ()
{
    MBProgressHUD *hud;
    
    UnitInfoBasicOne *u1;
    
    UserInfo *userinfo;
    
    UnitInfoBasicOne *basicOne;
    UnitInfoBasicTwo *basicTwo;
    NSArray *shippings;
    NSArray *commisses;
    NSMutableArray *unitInforItems;
    
    BOOL isModify;
    BOOL fromCamera;
    BOOL doChange;
    
    NSUInteger delIndex;
    NSMutableArray *delArray;
    
    NSMutableArray *filePicArray;
    NSUInteger selectPicIndex;
    NSString *allfilename;
    NSString *delFileNameStr;
    
    NSArray *fileTypeDicArray;//类型字典数组
    NSMutableArray *fileTypeENArray;//类型英文名称数组
    NSDictionary *selectFileTypeDic;
    NSUInteger selectedFileTypeIndex;
    Img *currentImg;
}

@end

@implementation UnitInfoDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Unit Info Detail";
    
    UIBarButtonItem *modifyBtn = [[UIBarButtonItem alloc] initWithTitle: @"Modify" style:UIBarButtonItemStyleBordered target:self action:@selector(modifyAction:)];
    self.navigationItem.rightBarButtonItem = modifyBtn;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.footerView.hidden = YES;
    fromCamera = NO;
    isModify = NO;
    doChange = NO;
    delFileNameStr = @"";
    filePicArray = [[NSMutableArray alloc] init];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    unitInforItems = [[NSMutableArray alloc] init];
    delArray = [[NSMutableArray alloc] init];
    filePicArray = [[NSMutableArray alloc] init];
    
    selectedFileTypeIndex = 100;
    fileTypeDicArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UnitFileType.plist" ofType:nil]];
    fileTypeENArray = [[NSMutableArray alloc] init];
    for (NSDictionary *typeDic in fileTypeDicArray) {
        [fileTypeENArray addObject:[typeDic objectForKey:@"typeEN"]];
    }
    
    [self getBasicInfoData];
}

- (void)modifyAction:(id )sender
{
    self.title = @"Unit Info Update";
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    isModify = YES;
    
    self.footerView.hidden = NO;
    self.tableView.tableFooterView = self.footerView;
    
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    [filePicArray addObject:addPicImage];
    [self reloadPhotoHeight:YES];
    [self.photoCollectionView reloadData];
}

- (void)saveAction:(id )sender
{
    if (!doChange) {
        [Tool showCustomHUD:@"您没做任何修改" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }

    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //异步请求启动文件上传及后续写库操作！SQL无意义，只为启动提示稍后
    //    [self updateImg];
    NSString *sql = @"select getdate() ";
    
    [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self updateImg];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self updateImg];
     }];
}

- (void)updateImg
{
    UIImage *imgbegin = [[UIImage alloc] init];
    for(int i = 0; i < filePicArray.count - 1; ++i)
    {
        Img *fileImgObject = [filePicArray objectAtIndex:i];
        imgbegin = nil;
        imgbegin = fileImgObject.img;
        if(imgbegin)
        {
            int random = (arc4random() % 501) + 500;
            NSString *picFirstName = @"hand_over";
            NSString *reName = [[NSString alloc] init];
            reName = nil;
            reName = [NSString stringWithFormat:@"%@%@%i.jpg",picFirstName,[Tool getCurrentTimeStr:@"yyyy-MM-dd-HHmmss"],random];
            BOOL isOK = [self upload:imgbegin oldName:reName Index:1 andType:fileImgObject.fileType];
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
    if(delFileNameStr.length > 0)
    {
        [self deleteImg];
    }
    [self writeLog];
}

- (void)deleteImg
{
    NSMutableString *sqlMStr = [[NSMutableString alloc] init];
    for (int i = 0; i < [delArray count]; i++) {
        UnitInfoCommiss *uc = (UnitInfoCommiss *)[delArray objectAtIndex:i];
        NSString *delname = [uc.allfileView lastPathComponent];
        if(i != [delArray count] -1)
        {
            [sqlMStr appendString:[NSString stringWithFormat:@"exec Sp_eFiles_DelFileInDebugTakeOver '1','%@';", delname]];
        }
        else
        {
            [sqlMStr appendString:[NSString stringWithFormat:@"exec Sp_eFiles_DelFileInDebugTakeOver '1','%@'", delname]];
        }
    }
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:[NSString stringWithString:sqlMStr] forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        XMLParserUtils *utils = [[XMLParserUtils alloc] init];
        utils.parserFail = ^()
        {
        };
        utils.parserOK = ^(NSString *string)
        {
            ASIFormDataRequest *request2 = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DeleteMultFile",api_base_url]]];
            
            [request2 setUseCookiePersistence:NO];
            [request2 setTimeOutSeconds:30];
            
            [request2 setPostValue:delFileNameStr forKey:@"fileNames"];
            [request2 setDefaultResponseEncoding:NSUTF8StringEncoding];
            [request2 startSynchronous];
            
            NSError *error2 = [request2 error];
            if (!error2)
            {
                NSString *response2 = [request2 responseString];
                if([response2 rangeOfString:@"true"].length > 0)
                {
                    NSLog(@"删除成功！");
                }
            }
        };
        
        [utils stringFromparserXML:response target:@"string"];
    }
}

- (BOOL)upload:(UIImage *)img oldName:(NSString *)reName Index:(NSInteger)index andType:(NSDictionary *)typeDic
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
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, userinfo.TrueName, userinfo.EnName, string, @"调试交接"];
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
//                        isOK = YES;
//                        
//                        if(allfilename == nil || [allfilename isEqualToString:@"null"])
//                        {
//                            allfilename = @"";
//                        }
//                        allfilename = [NSString stringWithFormat:@"%@|%@",allfilename,fileName];
//                        allfilename = [allfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                        NSString *sql2 = [NSString stringWithFormat:@"Insert into TB_CUST_ProjInf_DebugTakeOver(Proj_ID,Exec_Man,Exec_Date,Type,Project,Project_En,AirCondUnit_Mode,OutFact_Num,allfilename) values ('%@','%@','%@','调试交接','%@','%@','%@','%@','%@')", self.PROJ_ID, userinfo.TrueName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], [typeDic objectForKey:@"typeCN"], [typeDic objectForKey:@"typeEN"],u1.AirCondUnit_Mode,u1.OutFact_Num, fileName];
                        ASIFormDataRequest *tworequest2 = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
                        [tworequest2 setUseCookiePersistence:NO];
                        [tworequest2 setTimeOutSeconds:30];
                        [tworequest2 setDelegate:self];
                        [tworequest2 setPostValue:sql2 forKey:@"sqlstr"];
                        [tworequest2 setDefaultResponseEncoding:NSUTF8StringEncoding];
                        [tworequest2 startSynchronous];
                        
                        NSError *error2 = [tworequest2 error];
                        if (!error2)
                        {
                            NSString *response22 = [tworequest2 responseString];
                            if([response22 rangeOfString:@"true"].length > 0)
                            {
                                isOK = YES;
                                
//                                if(allfilename == nil || [allfilename isEqualToString:@"null"])
//                                {
//                                    allfilename = @"";
//                                }
//                                allfilename = [NSString stringWithFormat:@"%@|%@",allfilename,fileName];
//                                allfilename = [allfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                            }
                        }
                    }
                }
            }
        }
    }
    return isOK;
}

- (void)writeLog
{
    //写日志
    NSString *ip = [Tool getIPAddress:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *DoSomething = [NSString stringWithFormat:@"修改机组信息,出厂编号:%@上传调试附件", u1.OutFact_Num];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,TimeStr,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@TimeStr,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@TimeStr datetime,@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@TimeStr='%@',@Operation='修改',@Plate='机组信息(英文)',@ProjName='%@',@DoSomething='%@',@IpStr='%@'", userinfo.TrueName, [Tool getCurrentTimeStr:@"yyyy-MM-dd HH:mm"], u1.PROJ_Name, DoSomething, ip];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        if (hud) {
            [hud hide:YES];
        }
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

- (void)reloadPhotoHeight:(BOOL )addORcutRow
{
    int addRow = 0;
    if(addORcutRow)
    {
        if ([filePicArray count] % 3 == 1) {
            addRow = 1;
        }
    }
    else
    {
        if ([filePicArray count] <= 6)
        {
            if ([filePicArray count] % 3 == 0) {
                addRow = -1;
            }
        }
    }
    
    //只允许上传9张图片
    if ([filePicArray count] == 10) {
        addRow = 0;
    }
    
    float addHeight = 100.0 * addRow;
    
    //计算框架otherCollectionView的高度
    CGRect photoFrame = self.photoCollectionView.frame;
    photoFrame.size.height = photoFrame.size.height + addHeight;
    self.photoCollectionView.frame = photoFrame;
    
    CGRect footerViewrame = self.footerView.frame;
    footerViewrame.size.height = footerViewrame.size.height + addHeight;
    self.footerView.frame = footerViewrame;
}

- (void)getBasicInfoData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select P.Serv_Dept_En,P.Duty_Engineer_En,A.*  from Tb_CUST_ProjInf_AirCondUnit as A,TB_CUST_ProjInf as P where A.PROJ_ID=P.PROJ_ID and A.ID='%@'",self.ID];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestBasic:)];
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

- (void)requestBasic:(ASIHTTPRequest *)request
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
        if ( jsonArray != nil && jsonArray.count > 0) {
            NSDictionary *jsonDic = jsonArray[jsonArray.count - 1];
            basicOne = [Tool readJsonDicToObj:jsonDic andObjClass:[UnitInfoBasicOne class]];
            
            if (basicOne.KeepFix_Sign) {
                if ([basicOne.KeepFix_Sign isEqualToString:@"报修"]) {
                    basicOne.KeepFix_Sign = @"YES";
                }
                else
                {
                    basicOne.KeepFix_Sign = @"NO";
                }
            }
            
            if (basicOne.bzbx) {
                if ([basicOne.bzbx isEqualToString:@"非标"]) {
                    basicOne.bzbx_EN = @"Not-standard";
                }
                else
                {
                    basicOne.bzbx_EN = @"standard";
                }
            }
            basicTwo = [Tool readJsonDicToObj:jsonDic andObjClass:[UnitInfoBasicTwo class]];
            
            [unitInforItems addObject:basicOne];
            [self getShippingInfoData];
        }
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getShippingInfoData
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_eFiles_Get_SendGoods_List_En_ForApp '%@','6688'",basicOne.OutFact_Num];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestShipping:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestShipping:(ASIHTTPRequest *)request
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
        [self.tableView reloadData];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if([jsonArray count] > 0)
        {
            shippings = [Tool readJsonToObjArray:jsonArray andObjClass:[UnitInfoShipping class]];
            [unitInforItems addObjectsFromArray:shippings];
            [unitInforItems addObject:basicTwo];
            [self getCommissInfoData];
        }
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getCommissInfoData
{
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_eFiles_Get_DebugTakeOver_List_En_ForApp '%@','6688'",basicOne.OutFact_Num];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCommiss:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestCommiss:(ASIHTTPRequest *)request
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
        [self.tableView reloadData];
    };
    utils.parserOK = ^(NSString *string)
    {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if([jsonArray count] > 0)
        {
            commisses = [Tool readJsonToObjArray:jsonArray andObjClass:[UnitInfoCommiss class]];
            [unitInforItems addObjectsFromArray:commisses];
        }
        [self.tableView reloadData];
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return unitInforItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSObject *item = [unitInforItems objectAtIndex:row];
    if ([item isKindOfClass:[UnitInfoBasicOne class]])
    {
        return 393.0;
    }
    else if ([item isKindOfClass:[UnitInfoShipping class]])
    {
        return 122.0;
    }
    else if ([item isKindOfClass:[UnitInfoBasicTwo class]])
    {
        return 277.0;
    }
    else if ([item isKindOfClass:[UnitInfoCommiss class]])
    {
        return 160.0;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSObject *item = [unitInforItems objectAtIndex:row];
    if ([item isKindOfClass:[UnitInfoBasicOne class]])
    {
        UnitInfoBasicOneCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitInfoBasicOneCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UnitInfoBasicOneCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[UnitInfoBasicOneCell class]]) {
                    cell = (UnitInfoBasicOneCell *)o;
                    break;
                }
            }
        }
        u1 = (UnitInfoBasicOne *)item;
        cell.Prod_NumLB.text = u1.Prod_Num;
        cell.OutFact_NumLB.text = u1.OutFact_Num;
        cell.AirCondUnit_ModeLB.text = u1.AirCondUnit_Mode;
        cell.AirCondUnit_ConfigLB.text = u1.AirCondUnit_Config;
        cell.AirCondUnit_State_EnLB.text = u1.AirCondUnit_State_En;
        cell.KeepFix_SignENLB.text = u1.KeepFix_Sign_EN;
        cell.KeepFix_DateLB.text = u1.KeepFix_Date;
        cell.bzbxLB.text = u1.bzbx_EN;
        return cell;
    }
    else if ([item isKindOfClass:[UnitInfoShipping class]])
    {
        UnitInfoShippingCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitInfoShippingCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UnitInfoShippingCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[UnitInfoShippingCell class]]) {
                    cell = (UnitInfoShippingCell *)o;
                    break;
                }
            }
        }
        UnitInfoShipping *us = (UnitInfoShipping *)item;
        cell.ProjectLB.text = us.Project;
        cell.OutFact_NumLB.text = us.OutFact_Num;
        [cell.fileBTN setTitle:us.OldName forState:UIControlStateNormal];
        [cell.fileBTN setTag:row];
        [cell.fileBTN addTarget:self action:@selector(openFileAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if ([item isKindOfClass:[UnitInfoBasicTwo class]])
    {
        UnitInfoBasicTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitInfoBasicTwoCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UnitInfoBasicTwoCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[UnitInfoBasicTwoCell class]]) {
                    cell = (UnitInfoBasicTwoCell *)o;
                    break;
                }
            }
        }
        UnitInfoBasicTwo *u2 = (UnitInfoBasicTwo *)item;
        cell.Duty_Engineer_EnLB.text = u2.Duty_Engineer_En;
        cell.Tsxx_btrqLB.text = u2.Tsxx_btrq;
        cell.FirstDebug_DateLB.text = u2.FirstDebug_Date;
        cell.FirstDebug_EngineerLB.text = u2.FirstDebug_Engineer;
        cell.SecondDebug_DateLB.text = u2.SecondDebug_Date;
        cell.SecondDebug_EngineerLB.text = u2.SecondDebug_Engineer;
        return cell;
    }
    else if ([item isKindOfClass:[UnitInfoCommiss class]])
    {
        UnitInfoCommissCell *cell = [tableView dequeueReusableCellWithIdentifier:UnitInfoCommissCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"UnitInfoCommissCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[UnitInfoCommissCell class]]) {
                    cell = (UnitInfoCommissCell *)o;
                    break;
                }
            }
        }
        UnitInfoCommiss *uc = (UnitInfoCommiss *)item;
        cell.Exec_ManLB.text = uc.Exec_Man;
        cell.Exec_DateLB.text = uc.Exec_Date;
        cell.ProjectLB.text = uc.Project;
        [cell.fileBTN setTitle:uc.OldName forState:UIControlStateNormal];
        [cell.fileBTN setTag:row];
        [cell.fileBTN addTarget:self action:@selector(openFileAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        ZeroHeightTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ZeroHeightTableCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ZeroHeightTableCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[ZeroHeightTableCell class]]) {
                    cell = (ZeroHeightTableCell *)o;
                    break;
                }
            }
        }
        return cell;
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isModify) {
        NSInteger row = [indexPath row];
        NSObject *item = [unitInforItems objectAtIndex:row];
        if ([item isKindOfClass:[UnitInfoCommiss class]])
        {
//            UnitInfoCommiss *uc = (UnitInfoCommiss *)item;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"delete the file?" delegate:self cancelButtonTitle:@"Sure" otherButtonTitles:@"Cannel", nil];
            alert.tag = 0;
            delIndex = row;
            [alert show];
        }
    }
}

- (void)openFileAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        NSString *fileUrl = nil;
//        NSObject *topic = [unitInforItems objectAtIndex:tap.tag];
        NSObject *item = [unitInforItems objectAtIndex:tap.tag];
        if ([item isKindOfClass:[UnitInfoShipping class]])
        {
            UnitInfoShipping *us = (UnitInfoShipping *)item;
            fileUrl = us.allfileView;
        }
        else if ([item isKindOfClass:[UnitInfoCommiss class]])
        {
            UnitInfoCommiss *uc = (UnitInfoCommiss *)item;
            fileUrl = uc.allfileView;
        }
        
        if (fileUrl) {
            [self.photos removeAllObjects];
            if ([self.photos count] == 0) {
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:fileUrl]];
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

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [filePicArray count];
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
    
    id image = [filePicArray objectAtIndex:row];
    if ([image isKindOfClass:[UIImage class]]) {
        cell.picIV.image = (UIImage *)image;
    }
    else
    {
        Img *img = (Img *)image;
        cell.picIV.image = img.img;
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
    NSUInteger row = [indexPath row];
    if (row == [filePicArray count] -1) {
        [SGActionView showSheetWithTitle:@"Choose file type:"
                              itemTitles:fileTypeENArray
                           itemSubTitles:nil
                           selectedIndex:selectedFileTypeIndex
                          selectedHandle:^(NSInteger index){
                              if (selectedFileTypeIndex != index) {
                                  selectedFileTypeIndex = index;
                                  selectFileTypeDic = [fileTypeDicArray objectAtIndex:index];
//                                  self.TypeEnLB.text = [fileTypeENArray objectAtIndex:index];
                                  currentImg = [[Img alloc] init];
                                  currentImg.fileType = selectFileTypeDic;
                                  UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"取消"
                                                                             destructiveButtonTitle:nil
                                                                                  otherButtonTitles:@"拍照", @"从相册中选取", nil];
                                  cameraSheet.tag = 0;
                                  [cameraSheet showInView:self.view];
                              }
                          }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Please choose?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Preview", @"Delete", @"Cancel", nil];
        alert.tag = 1;
        selectPicIndex = row;
        [alert show];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 0)
        {
            UnitInfoCommiss *uc = (UnitInfoCommiss *)[unitInforItems objectAtIndex:delIndex];
            [unitInforItems removeObjectAtIndex:delIndex];
            [delArray addObject:uc];
            doChange = YES;
            [self.tableView reloadData];
            NSString *delname = [NSString stringWithFormat:@"|%@", [uc.allfileView lastPathComponent]];
            delFileNameStr = [NSString stringWithFormat:@"%@%@", delFileNameStr, delname];
        }
        if(alertView.tag == 1)
        {
            Img *image = (Img *)[filePicArray objectAtIndex:selectPicIndex];
            if(image)
            {
                [self.photos removeAllObjects];
                if ([self.photos count] == 0) {
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    MWPhoto * photo = [MWPhoto photoWithImage:image.img];
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
        }
    }
    if(buttonIndex == 1)
    {
        if(alertView.tag == 1)
        {
            [filePicArray removeObjectAtIndex:selectPicIndex];
            [self reloadPhotoHeight:NO];
            [self.photoCollectionView reloadData];
        }
    }
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
        
        currentImg.img = tImg;
        
        [filePicArray insertObject:currentImg atIndex:[filePicArray count] -1];
        [self reloadPhotoHeight:YES];
        doChange = YES;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
