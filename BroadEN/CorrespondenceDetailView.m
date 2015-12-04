//
//  CorrespondenceDetailView.m
//  BroadEN
//
//  Created by Seven on 15/12/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "CorrespondenceDetailView.h"
#import "ImageCollectionCell.h"
#import "UserSecurity.h"
#import "Correspondence.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "MWPhotoBrowser.h"

@interface CorrespondenceDetailView ()<UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate,MWPhotoBrowserDelegate>
{
    MBProgressHUD *hud;
    
    UserInfo *userinfo;
    Correspondence *correspondence;
    
    NSArray *picArray;
    NSMutableArray *filePicArray;
    NSMutableArray *newsPicArray;
    
    NSMutableArray *_photos;
    
    NSUInteger selectPicIndex;
    
    NSString *newsallfilenameStr;
    NSString *delFileNameStr;
    
    BOOL isModify;
    BOOL fromCamera;
    BOOL doChange;
    
    NSString *DoSomething;
}

@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation CorrespondenceDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Correspondence Detail";
    
    isModify = NO;
    doChange = NO;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    fromCamera = NO;
    DoSomething = @"";
    
    filePicArray = [[NSMutableArray alloc] init];
    newsPicArray = [[NSMutableArray alloc] init];
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getSecurity];
    [self getDetailData];
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
        for (UserSecurity *s in securityList) {
            if ([s.PermissionName isEqualToString:@"修改"]) {
                UIBarButtonItem *modifyBtn = [[UIBarButtonItem alloc] initWithTitle: @"Modify" style:UIBarButtonItemStyleBordered target:self action:@selector(modifyAction:)];
                self.navigationItem.rightBarButtonItem = modifyBtn;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getDetailData
{
    //%%为转义%
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT L.ID,P.PROJ_ID,P.PROJ_Name,P.PROJ_Name_En, Exec_Man_En = case when L.Exec_Man_En is null then dbo.fn_GetEnName(L.Exec_Man) else Exec_Man_En end,L.Exec_Date,L.CUST_Name_CN,L.FileType,L.allfilename, Uploader_En = case when L.Uploader_En is null then dbo.fn_GetEnName(L.Uploader) else Uploader_En end,L.UploadTime,dbo.fn_GetHanJianTypeEn(L.FileType) as TypeEn  FROM [dbo].[Tb_CUST_ProjInf_ComeGoLetter] as L,TB_CUST_ProjInf as P where L.Proj_ID=P.PROJ_ID and L.ID='%@'", self.ID];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestDetail:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"加载中..." andView:self.view andHUD:request.hud];
}

- (void)requestDetail:(ASIHTTPRequest *)request
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
        NSLog(string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (jsonArray && [jsonArray count] > 0) {
            correspondence = [Tool readJsonDicToObj:jsonArray[0] andObjClass:[Correspondence class]];
            [self bindData];
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindData
{
    self.PROJ_Name_EnLB.text = correspondence.PROJ_Name_En;
    self.Uploader_EnLB.text = correspondence.Uploader_En;
    self.UploadTimeLB.text = correspondence.UploadTime;
    self.TypeEnLB.text = correspondence.TypeEn;
    
    if (correspondence.allfilename.length > 0) {
        newsallfilenameStr = correspondence.allfilename;
        delFileNameStr = @"";
        [self getImg:correspondence.allfilename andImageIndex:1];
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
                 filePicArray = [NSMutableArray arrayWithArray:picArray];
                 [self reloadPhotoHeight:YES];
                 [self.photoCollectionView reloadData];
                 
             }
             else
             {
                 if (imageIndex == 4) {
                     [filePicArray removeAllObjects];
                     [self.photoCollectionView reloadData];
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
            if ([picArray count] % 3 == 0) {
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
    
    //多加了个View暂时先这么办吧
    CGRect mainViewrame = self.mainView.frame;
    mainViewrame.size.height = mainViewrame.size.height + addHeight;
    self.mainView.frame = mainViewrame;
    
    //    //设置view高度跟随增加
    //        CGRect mainViewFrame = self.view.frame;
    //        mainViewFrame.size.height = mainViewFrame.size.height + addHeight;
    //        self.view.frame = mainViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.mainView.frame.size.height);
}

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
    if(isModify)
    {
        NSUInteger row = [indexPath row];
        if (row == [filePicArray count] -1) {
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
            alert.tag = 1;
            selectPicIndex = row;
            [alert show];
        }
    }
    else
    {
        if ([self.photos count] == 0) {
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            for (Img *image in filePicArray) {
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

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modifyAction:(id )sender
{
    self.title = @"Correspondence Update";
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    isModify = YES;
    
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
    
    if ([filePicArray count] <= 1) {
        [Tool showCustomHUD:@"please upload File" andView:self.view andImage:nil andAfterDelay:1.2f];
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
    for(int i = 0; i < newsPicArray.count; ++i)
    {
        imgbegin = nil;
        imgbegin = newsPicArray[i];
        if(imgbegin)
        {
            int random = (arc4random() % 501) + 500;
            NSString *picFirstName = @"Correspondance";
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
    DoSomething = @"上传附件";
    if(delFileNameStr.length > 0)
    {
        DoSomething = [NSString stringWithFormat:@"%@|%@", DoSomething, @"删除附件"];
        [self deleteImg];
    }
    [self updateDataToDb];
}

- (void)deleteImg
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DeleteMultFile",api_base_url]]];
    
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:delFileNameStr forKey:@"fileNames"];
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
        };
        
        [utils stringFromparserXML:response target:@"string"];
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
                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
                img = nil;
                base64Encoded = nil;
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, userinfo.TrueName, userinfo.EnName, string, self.TypeEnLB.text];
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
                        
                        if(newsallfilenameStr == nil || [newsallfilenameStr isEqualToString:@"null"])
                        {
                            newsallfilenameStr = @"";
                        }
                        newsallfilenameStr = [NSString stringWithFormat:@"%@|%@",newsallfilenameStr,fileName];
                        newsallfilenameStr = [newsallfilenameStr stringByReplacingOccurrencesOfString:@"null" withString:@""];
                    }
                }
            }
        }
    }
    return isOK;
}

- (void)updateDataToDb
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'update [Tb_CUST_ProjInf_ComeGoLetter] set allfilename=@allfilename,Uploader=@Uploader,Uploader_En=@Uploader_En,UploadTime=@UploadTime where ID=@ID ',N'@allfilename varchar(500),@Uploader varchar(50),@Uploader_En varchar(100),@UploadTime datetime,@ID int', @allfilename='%@',@Uploader='%@',@Uploader_En='%@',@UploadTime='%@',@ID='%@'", newsallfilenameStr, userinfo.TrueName, userinfo.EnName, [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"], self.ID];
    
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
            
            //写日志
            NSString *ip = [Tool getIPAddress:YES];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
            [request setUseCookiePersistence:NO];
            [request setTimeOutSeconds:30];
            NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,TimeStr,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@TimeStr,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@TimeStr datetime,@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@TimeStr='%@',@Operation='修改(英文版)',@Plate='往来函件',@ProjName='',@DoSomething='%@',@IpStr='++++%@++++'", userinfo.TrueName, [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"], @"11", ip];
            
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_CorrespondenceListReLoad" object:nil];
                    [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                }
            }
        }
        else
        {
            [Tool showCustomHUD:@"提交失败" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 1)
        {
            Img *img = [filePicArray objectAtIndex:selectPicIndex];
            NSString *delname = [NSString stringWithFormat:@"|%@", [img.Url lastPathComponent]];
            if(newsallfilenameStr.length > 30)
            {
                newsallfilenameStr = [newsallfilenameStr stringByReplacingOccurrencesOfString:delname withString:@""];
            }
            else
            {
                newsallfilenameStr = @"";
            }
            delFileNameStr = [NSString stringWithFormat:@"%@%@", delFileNameStr, delname];
            
            [filePicArray removeObjectAtIndex:selectPicIndex];
            doChange = YES;
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
        
//        NSData *imageData = UIImageJPEGRepresentation(smallImage,0.8f);
//        UIImage *tImg = [UIImage imageWithData:imageData];
//        Img *tem = [[Img alloc] init];
//        tem.img = smallImage;
        [newsPicArray addObject:smallImage];
        
        doChange = YES;
        
        [filePicArray insertObject:smallImage atIndex:[filePicArray count] -1];
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

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
