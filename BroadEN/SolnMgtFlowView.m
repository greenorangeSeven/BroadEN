//
//  SolnMgtFlowView.m
//  BroadEN
//
//  Created by Seven on 15/12/7.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SolnMgtFlowView.h"
#import "ImageCollectionCell.h"
#import "SolnMgt.h"
#import "HSDatePickerViewController.h"
#import "MWPhotoBrowser.h"

@interface SolnMgtFlowView ()<UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HSDatePickerViewControllerDelegate,MWPhotoBrowserDelegate>
{
    UserInfo *userinfo;
    SolnMgt *solnMgt;
    NSMutableArray *fileArray;
    NSUInteger selectPicIndex;
    
    NSString *allfilename;//photo
    
    BOOL fromCamera;
    
    MBProgressHUD *hud;
    
    NSString *jiaose;
    NSString *UserName;
    NSString *UserNameEN;
    
    NSDate *serviceDate;
    
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation SolnMgtFlowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Solution Management";
    
    if(!self.isQuery)
    {
        UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
        self.navigationItem.rightBarButtonItem = submitBtn;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    fromCamera = NO;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    UserName = userinfo.UserName;
    UserNameEN = userinfo.EnName;
    jiaose = userinfo.JiaoSe;
    
    if (![jiaose isEqualToString:@"SE"] && ![jiaose isEqualToString:@"FJ"]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"Only Engineer can submit this workflow!" delegate:self cancelButtonTitle:@"sure" otherButtonTitles:nil];
        alert.tag = -1;
        [alert show];
    }
    
    //初始化图片区域
    fileArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    if(!self.isQuery)
    {
        [fileArray addObject:addPicImage];
    }
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getSolnDetailData];
}

-(void)submitAction:(id )sender
{
    NSString *explainInfo = self.ExplainInfoTV.text;
    if (explainInfo.length == 0)
    {
        [Tool showCustomHUD:@"Please Write Explain Info" andView:self.view andImage:nil andAfterDelay:1.2f];
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
             NSLog(string);
             NSArray *table = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             NSDictionary *dic = table[0];
             NSString *OwnerUserName = [dic objectForKey:@"OwnerUserName"];
             if([OwnerUserName isEqualToString:UserName])
             {
                 [self updateImg];
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
            NSString *picFirstName = @"SolutionReport";
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
    [self insertData];
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

- (void)insertData
{
    NSString *HandingDate = self.HandingDateTF.text;
    NSString *AddLi2Cr04 = self.AddLi2Cr04TF.text;
    NSString *explainInfo = self.ExplainInfoTV.text;
    explainInfo = [explainInfo stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'update [TB_CUST_ProjInf_SolutionMgmt] set HandleTime=@HandleTime,LithiumByEngineer=@LithiumByEngineer,Other=@Other,Uploader=@Uploader,UploadTime=@UploadTime,allfilename=@allfilename where Mark=@Mark ',N'@HandleTime datetime,@LithiumByEngineer varchar(50),@Other varchar(500),@Uploader varchar(50),@UploadTime datetime,@allfilename varchar(500),@Mark varchar(500)', @HandleTime='%@',@LithiumByEngineer='%@',@Other='%@',@Uploader='%@',@UploadTime='%@',@allfilename='%@',@Mark='%@'", HandingDate, AddLi2Cr04, explainInfo, UserName, [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"], allfilename, self.Mark];
    
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
            [self endFlow];
        }
        else
        {
            [Tool showCustomHUD:@"Submit failure" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)endFlow
{
    //流程办结
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"SP_FlowSubmit_En '%@',1,'','%@','溶液管理录入','办结成功'", UserName, self.Mark];
    
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
    {
        NSString *response = [request responseString];
        if([response rangeOfString:@"true"].length > 0)
        {
            [self writeLog];
        }
        else
        {
            [Tool showCustomHUD:@"Submit failure" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)writeLog
{
    //写日志
    NSString *ip = [Tool getIPAddress:YES];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@Operation='办结',@Plate='溶液检测报告(流程)',@ProjName='%@',@DoSomething='工程师办结(英文app);机组编号:%@;溶液处理附件:%@',@IpStr='%@'", UserName, solnMgt.PROJ_Name, solnMgt.OutFact_Num, allfilename, ip];
    
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

- (void)getSolnDetailData
{
    NSString *sqlStr = [NSString stringWithFormat:@"Select dbo.fn_GetOutwardEn(a.SolutionOutward) as OutwardEn,dbo.fn_GetEnName(a.Exec_Man) as Exec_ManEn,c.PROJ_Name_En,c.PROJ_Name,c.Duty_Engineer_En,a.*  	FROM TB_CUST_ProjInf_SolutionMgmt a , TB_CUST_ProjInf c  	where a.Proj_ID=c.PROJ_ID and a.Mark='%@'", self.Mark];
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
        NSLog(@"%@", string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if ([jsonArray count] > 0) {
            solnMgt = [Tool readJsonDicToObj:jsonArray[0] andObjClass:[SolnMgt class]];
            [self bindData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindData
{
    self.PROJ_Name_EnLB.text = solnMgt.PROJ_Name_En;
    self.Exec_DateLB.text = [Tool DateTimeRemoveTime:solnMgt.Exec_Date andSeparated:@" "];
    self.Exec_ManEnLB.text = solnMgt.Exec_ManEn;
    self.TypeSerialLB.text = [NSString stringWithFormat:@"%@/%@", solnMgt.AirCondUnit_Mode, solnMgt.OutFact_Num];
    
    self.LiBrLB.text = [NSString stringWithFormat:@"%@%%", solnMgt.LiBr];
    self.LiBrResultLB.text = [self CNTOEN:solnMgt.LiBrResult];
    
    self.DensityTempLB.text = [NSString stringWithFormat:@"%@g/m³(%@℃)", solnMgt.Density, solnMgt.Temp];
    self.DensityTempResultLB.text = [self CNTOEN:solnMgt.LiBrResult];
    
    self.OutwardEnLB.text = solnMgt.OutwardEn;
    self.OutwardResultLB.text = [self CNTOEN:solnMgt.OutwardResult];
    
    self.PHLB.text = solnMgt.PH;
    self.PHResultLB.text = [self CNTOEN:solnMgt.PHResult];
    
    self.CU2LB.text = [NSString stringWithFormat:@"%@ppm", solnMgt.CU2];
    self.CU2ResultLB.text = [self CNTOEN:solnMgt.CU2Result];
    
    self.FeLB.text = solnMgt.Fe;
    self.FeResultLB.text = [self CNTOEN:solnMgt.FeResult];
    
    self.Licro4LB.text = [NSString stringWithFormat:@"%@%%", solnMgt.Licro4];
    self.Licro4ResultLB.text = [self CNTOEN:solnMgt.Licro4Result];
    
    self.PrecipitationLB.text = [NSString stringWithFormat:@"%@%%", solnMgt.Precipitation];
    self.PrecipitationResultLB.text = [self CNTOEN:solnMgt.PrecipitationResult];
    
    self.ClLB.text = solnMgt.Cl;
    self.ClResultLB.text = [self CNTOEN:solnMgt.ClResult];
    
    self.InspectorSignEnLB.text = solnMgt.InspectorSignEn;
    //    self.InspectorSignDateLB.text = [Tool DateTimeRemoveTime:solnMgt.InspectorSignDate andSeparated:@" "];
}

- (NSString *)CNTOEN:(NSString *)CN
{
    NSString *EN = @"";
    if (CN && CN.length > 0) {
        if ([CN isEqualToString:@"正常"]) {
            EN = @"Normal";
        }
        else if ([CN isEqualToString:@"异常"]) {
            EN = @"Abnormal";
        }
        else if ([CN isEqualToString:@"合格"]) {
            EN = @"Qualified";
        }
        else if ([CN isEqualToString:@"不合格"] || [CN isEqualToString:@"超标"]) {
            EN = @"Unqualified";
        }
    }
    return EN;
}

- (void)reloadPhotoHeight:(BOOL )addORcutRow
{
    int addRow = 0;
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
    
    //只允许上传9张图片
    if ([fileArray count] == 10) {
        addRow = 0;
    }
    
    float addHeight = 100.0 * addRow;
    
    //计算框架otherCollectionView的高度
    CGRect photoFrame = self.photoCollectionView.frame;
    photoFrame.size.height = photoFrame.size.height + addHeight;
    self.photoCollectionView.frame = photoFrame;
    
    CGRect photoViewrame = self.photoView.frame;
    photoViewrame.size.height = photoViewrame.size.height + addHeight;
    self.photoView.frame = photoViewrame;
    
    CGRect explainViewFrame = self.explainView.frame;
    explainViewFrame.origin.y = explainViewFrame.origin.y + addHeight;
    self.explainView.frame = explainViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.explainView.frame.origin.y + self.explainView.frame.size.height);
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
    }
    if(buttonIndex == 1)
    {
        if(alertView.tag == 1)
        {
            [fileArray removeObjectAtIndex:selectPicIndex];
            [self reloadPhotoHeight:NO];
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
    UIImage *picImage = [fileArray objectAtIndex:row];
    cell.picIV.image = picImage;
    
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
    if (row == [fileArray count] -1) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self reloadPhotoHeight:YES];
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

#pragma mark - HSDatePickerViewControllerDelegate
- (void)hsDatePickerPickedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *targetDate = [dateFormatter stringFromDate:date];
    self.HandingDateTF.text = targetDate;
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
        self.HandingDateTF.text = @"";
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectDateAction:(id)sender {
    HSDatePickerViewController *hsdpvc = [HSDatePickerViewController new];
    hsdpvc.delegate = self;
    if (serviceDate) {
        hsdpvc.date = serviceDate;
    }
    [self presentViewController:hsdpvc animated:YES completion:nil];
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
