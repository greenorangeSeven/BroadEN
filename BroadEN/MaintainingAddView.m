//
//  MaintainingAddView.m
//  BroadEN
//
//  Created by Seven on 15/11/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MaintainingAddView.h"
#import "ImageCollectionCell.h"
#import "UnitInfo.h"
#import "SGActionView.h"

@interface MaintainingAddView ()
{
    NSMutableArray *otherPicArray;
    NSUInteger selectOtherPicIndex;
    NSDate *serviceDate;
    UserInfo *userinfo;
    
    NSString *Engineer;//责任工程师
    NSString *Exec_Man;//责任工程师中文
    NSString *PROJ_Name;
    
    NSMutableArray *outFactNumArray;
    
    NSArray *serviceTypeDicArray;//服务类型字典数组
    NSMutableArray *serviceTypeENArray;//服务类型英文名称数组
    NSArray *serviceItemDicArray;//服务项目字典数组
    NSMutableArray *serviceItemENArray;//服务项目英文数组
    NSArray *units;
    
    BOOL fromCamera;
    
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceItemIndex;
    NSInteger selectedUnitIndex;
}

@end

//获取Duty_Engineer_En；
//String endPoint = Constant.CONSTANTURL+"/JkzxService.asmx";
//// SOAP Action
//String soapAction = Constant.CONSTANTURL+"/JsonDataInDZDA";
//String sql="select Duty_Engineer_En,PROJ_Name from TB_CUST_ProjInf where PROJ_ID='"+Prj_id+"'";

//获取机组信息
//String methodName = "JsonDataInDZDA";
//String endPoint = Constant.CONSTANTURL+"/JkzxService.asmx";
//// SOAP Action
//String soapAction = Constant.CONSTANTURL+"/JsonDataInDZDA";
//String sql="select A.AirCondUnit_Mode,A.OutFact_Num,A.Prod_Num from Tb_CUST_ProjInf_AirCondUnit as A, TB_CUST_ProjInf as P where A.PROJ_ID=P.PROJ_ID and P.PROJ_ID='"+Prj_id+"'";

@implementation MaintainingAddView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Maintaining Add";
    
    fromCamera = NO;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    Exec_Man = userinfo.TrueName;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    self.UploadDateTF.text = [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"];
    
    otherPicArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    [otherPicArray addObject:addPicImage];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getEngineer];
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
                                  NSDictionary *type = [serviceTypeDicArray objectAtIndex:index];
                                  self.serviceTypeTF.text = [serviceTypeENArray objectAtIndex:index];
                                  self.serviceItemTF.text = @"";
                                  serviceItemDicArray = [type objectForKey:@"items"];
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
                                  NSDictionary *item = [serviceItemDicArray objectAtIndex:index];
                                  self.serviceItemTF.text = [serviceItemENArray objectAtIndex:index];
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
                              UnitInfo *unit = [units objectAtIndex:index];
                              self.unitTF.text = unit.OutFact_Num;
                          }];
    }
    return NO;
}

- (void)getEngineer
{
    NSString *sqlStr = [NSString stringWithFormat:@"select Duty_Engineer_En,PROJ_Name from TB_CUST_ProjInf where PROJ_ID='%@'",self.projId];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestEngineer:)];
    [request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestEngineer:(ASIHTTPRequest *)request
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
        if([jsonArray count] > 0)
        {
            NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
            Engineer = [jsonDic objectForKey:@"Duty_Engineer_En"];
            PROJ_Name = [jsonDic objectForKey:@"PROJ_Name"];
            self.EngineerTF.text = Engineer;
            self.UploadManTF.text = Engineer;
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)getUnits
{
    NSString *sqlStr = [NSString stringWithFormat:@"select A.AirCondUnit_Mode,A.OutFact_Num,A.Prod_Num from Tb_CUST_ProjInf_AirCondUnit as A, TB_CUST_ProjInf as P where A.PROJ_ID=P.PROJ_ID and P.PROJ_ID='%@'",self.projId];
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

- (void)reloadOtherHeight:(BOOL )addORcutRow
{
    int addRow = 0;
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
    
    //多加了个View暂时先这么办吧
    CGRect main2ViewFrame = self.mainView.frame;
    main2ViewFrame.size.height = main2ViewFrame.size.height + addHeight;
    self.mainView.frame = main2ViewFrame;
    
    //设置view高度跟随增加
    //    CGRect mainViewFrame = self.view.frame;
    //    mainViewFrame.size.height = mainViewFrame.size.height + addHeight;
    //    self.view.frame = mainViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.mainView.frame.size.height);
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
    UIImage *picImage = [otherPicArray objectAtIndex:row];
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
    if (row == [otherPicArray count] -1) {
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
        UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"删除", nil];
        delSheet.tag = -4;
        selectOtherPicIndex = row;
        [delSheet showInView:self.view];
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
    if (actionSheet.tag == -4) {
        if (buttonIndex == 0) {
            [otherPicArray removeObjectAtIndex:selectOtherPicIndex];
            [self reloadOtherHeight:NO];
            [self.otherCollectionView reloadData];
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
        
        [otherPicArray insertObject:smallImage atIndex:[otherPicArray count] -1];
        [self reloadOtherHeight:YES];
        [self.otherCollectionView reloadData];
        
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

@end
