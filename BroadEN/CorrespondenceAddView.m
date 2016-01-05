//
//  CorrespondenceAddView.m
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "CorrespondenceAddView.h"
#import "ImageCollectionCell.h"
#import "SGActionView.h"
#import "MWPhotoBrowser.h"

@interface CorrespondenceAddView ()<UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate>
{
    UserInfo *userinfo;
    NSMutableArray *fileArray;
    NSUInteger selectPicIndex;
    
    NSString *Engineer;//责任工程师
    NSString *Exec_Man;//责任工程师中文
    
    NSArray *fileTypeDicArray;//类型字典数组
    NSMutableArray *fileTypeENArray;//类型英文名称数组
    NSDictionary *selectFileTypeDic;
    NSUInteger selectedFileTypeIndex;
    
    NSString *allfilename;//photo
    
    BOOL fromCamera;
    
    MBProgressHUD *hud;
    
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation CorrespondenceAddView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Corrpdnc Mail";
    
    UIBarButtonItem *submitBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = submitBtn;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    fromCamera = NO;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    Engineer = userinfo.EnName;
    Exec_Man = userinfo.UserName;
    
    self.Exec_Man_EnLb.text = userinfo.EnName;
    self.UploadTimeLb.text = [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"];
    
    //初始化图片区域
    fileArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    [fileArray addObject:addPicImage];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    selectedFileTypeIndex = 100;
    fileTypeDicArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FileType.plist" ofType:nil]];
    fileTypeENArray = [[NSMutableArray alloc] init];
    for (NSDictionary *typeDic in fileTypeDicArray) {
        [fileTypeENArray addObject:[typeDic objectForKey:@"typeEN"]];
    }
}

- (IBAction)chooseFileTypeAction:(id)sender {
    
    [SGActionView showSheetWithTitle:@"Choose file type:"
                          itemTitles:fileTypeENArray
                       itemSubTitles:nil
                       selectedIndex:selectedFileTypeIndex
                      selectedHandle:^(NSInteger index){
                          if (selectedFileTypeIndex != index) {
                              selectedFileTypeIndex = index;
                              selectFileTypeDic = [fileTypeDicArray objectAtIndex:index];
                              self.FileTypeLb.text = [fileTypeENArray objectAtIndex:index];
                          }
                      }];
}

- (void)submitAction:(id )sender
{
    NSString *fileType = self.FileTypeLb.text;
    if (fileType.length == 0)
    {
        [Tool showCustomHUD:@"please choose File Type" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if ([fileArray count] <= 1) {
        [Tool showCustomHUD:@"please upload File" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Waiting..." andView:self.view andHUD:hud];
    
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    if ([fileType isEqualToString:@"Annual service report"])
    {
        NSString *sql = [NSString stringWithFormat:@"Select COUNT(ID) From Tb_CUST_ProjInf_ComeGoLetter Where Proj_ID='%@' and FileType='年度服务总结报告' and YEAR(Exec_Date)='%d'", self.projId, (int)year];
        
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
                 NSString *count = [dic objectForKey:@"Column1"];
                 if([count intValue] > 0)
                 {
                     if (hud) {
                         [hud hide:YES];
                     }
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert:" message:@"There are correspondence records of the same FileType,please do not repeat!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alertView show];
                     self.navigationItem.rightBarButtonItem.enabled = YES;
                     return;
                 }
                 else
                 {
                     [self updateImg];
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
    else
    {
        NSString *sql = @"select getdate() ";
        [[AFOSCClient  sharedClient] postPath:[NSString stringWithFormat:@"%@JsonDataInDZDA",api_base_url] parameters:[NSDictionary dictionaryWithObjectsAndKeys:sql,@"sqlstr", nil] success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self updateImg];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [self updateImg];
         }];
    }
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
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, Exec_Man, Engineer, string, self.FileTypeLb.text];
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
    NSString *FileTypeCN = [selectFileTypeDic objectForKey:@"typeCN"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [Tb_CUST_ProjInf_ComeGoLetter] (Proj_ID,Exec_Man,Exec_Man_En,Exec_Date,CUST_Name_CN,FileType,allfilename,Uploader,Uploader_En,UploadTime) values  (@Proj_ID,@Exec_Man,@Exec_Man_En,@Exec_Date,@CUST_Name_CN,@FileType,@allfilename,@Uploader,@Uploader_En,@UploadTime);select @@IDENTITY', N'@Proj_ID varchar(32),@Exec_Man varchar(32),@Exec_Man_En varchar(100),@Exec_Date datetime,@CUST_Name_CN varchar(100), @FileType varchar(32),@allfilename varchar(500),@Uploader varchar(50),@Uploader_En varchar(100),@UploadTime datetime',@Proj_ID='%@',@Exec_Man='%@',@Exec_Man_En='%@',@Exec_Date='%@',@CUST_Name_CN='%@',@FileType='%@',@allfilename='%@',@Uploader='admin',@Uploader_En='%@',@UploadTime='%@'", self.projId, Exec_Man, Engineer, self.UploadTimeLb.text, self.PROJ_Name, FileTypeCN, allfilename, Engineer, [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"]];
    
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
            NSString *sql = [NSString stringWithFormat:@"exec sp_executesql N'insert into [ERPRiZhi] (UserName,TimeStr,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@TimeStr,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@TimeStr datetime,@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@TimeStr='%@',@Operation='新增(英文版)',@Plate='往来函件',@ProjName='%@',@DoSomething='往来函件新增',@IpStr='%@'", Exec_Man, [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"], self.PROJ_Name, ip];
            
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_CorrespondenceListReLoad" object:nil];
                    [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                }
            }
        }
        else
        {
            [Tool showCustomHUD:@"Submit failure" andView:self.view andImage:nil andAfterDelay:1.2f];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
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
    
    //多加了个View暂时先这么办吧
    CGRect fileViewrame = self.fileView.frame;
    fileViewrame.size.height = fileViewrame.size.height + addHeight;
    self.fileView.frame = fileViewrame;
    
    //    //设置view高度跟随增加
    //        CGRect mainViewFrame = self.view.frame;
    //        mainViewFrame.size.height = mainViewFrame.size.height + addHeight;
    //        self.view.frame = mainViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.fileView.frame.origin.y + self.fileView.frame.size.height);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 1)
        {
            UIImage *image = [fileArray objectAtIndex:selectPicIndex];
            if (image) {
                [self.photos removeAllObjects];
                if ([self.photos count] == 0) {
                    NSMutableArray *photos = [[NSMutableArray alloc] init];
                    MWPhoto * photo = [MWPhoto photoWithImage:image];
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

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
