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
    NSMutableDictionary *picDic;
    NSMutableArray *otherPicArray;
    NSUInteger selectOtherPicIndex;
    NSDate *serviceDate;
    UserInfo *userinfo;
    
    NSString *Engineer;//责任工程师
    NSString *Exec_Man;//责任工程师中文
    NSString *PROJ_Name;
    NSString *serviceItemCN;
    
    NSMutableArray *outFactNumArray;
    
    NSArray *serviceTypeDicArray;//服务类型字典数组
    NSMutableArray *serviceTypeENArray;//服务类型英文名称数组
    NSDictionary *selectServiceTypeDic;
    NSArray *serviceItemDicArray;//服务项目字典数组
    NSMutableArray *serviceItemENArray;//服务项目英文数组
    NSDictionary *selectServiceItemDic;
    NSArray *units;
    UnitInfo *selectedUnit;
    
    BOOL fromCamera;
    
    NSInteger selectedServiceTypeIndex;
    NSInteger selectedServiceItemIndex;
    NSInteger selectedUnitIndex;
    NSInteger selectedPicIndex;
    
    MBProgressHUD *hud;
    
    NSString *FileType;
    NSString *allfilename;//other
    NSString *allfilename02;//service foem
    NSString *allfilename03;//TouchSencePhoto
    NSString *allfilename04;//SnecePhoto
    NSString *AirCondUnit_Mode;
    
    NSString *Mark;
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

//检查上传是否重复
//String methodName = "JsonDataInDZDA";
//String endPoint = Constant.CONSTANTURL+"/JkzxService.asmx";
//String soapAction = Constant.CONSTANTURL+"/JsonDataInDZDA";
//String year=getyera((new Date().getTime())/1000+"");
//String sql="Select COUNT(*)  From TB_CUST_ProjInf_MatnRec Where Project='"+Project+"' and Proj_ID='"+Prj_id+"' and OutFact_Num='"+OutFact_Num+"' and YEAR(UploadTime)="+year+"";

@implementation MaintainingAddView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Maintaining Add";
    
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithTitle: @"Submit" style:UIBarButtonItemStyleBordered target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    fromCamera = NO;
    FileType = @"维护保养(IOS app)";
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    Mark = [NSString stringWithFormat:@"%.0f%d", a,(arc4random() % 501) + 500];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    
    Exec_Man = userinfo.TrueName;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    self.UploadDateTF.text = [Tool getCurrentTimeStr:@"YYYY-MM-dd HH:mm"];
    
    //初始化图片区域
    picDic = [[NSMutableDictionary alloc] init];
    otherPicArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    [otherPicArray addObject:addPicImage];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    UITapGestureRecognizer *serviceFormTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picChooseAction:)];
    self.ServiceFormIV.tag = 1;
    [self.ServiceFormIV addGestureRecognizer:serviceFormTap];
    
    UITapGestureRecognizer *snecePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picChooseAction:)];
    self.SnecePhotoIV.tag = 2;
    [self.SnecePhotoIV addGestureRecognizer:snecePhotoTap];
    
    UITapGestureRecognizer *touchSencePhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picChooseAction:)];
    self.TouchSencePhotoIV.tag = 3;
    [self.TouchSencePhotoIV addGestureRecognizer:touchSencePhotoTap];
    
    //初始化选择区域
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
    return NO;
}

- (void)picChooseAction:(UITapGestureRecognizer *)recognizer
{
    NSUInteger tag = recognizer.view.tag;
    selectedPicIndex = tag;
    UIImage *picImage = [picDic objectForKey:[NSString stringWithFormat:@"%d", selectedPicIndex]];
    if (!picImage) {
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
//        UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                              delegate:self
//                                                     cancelButtonTitle:@"取消"
//                                                destructiveButtonTitle:nil
//                                                     otherButtonTitles:@"删除", nil];
//        delSheet.tag = -1;
//        [delSheet showInView:self.view];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
        alert.tag = 1;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if(alertView.tag == 1)
        {
            [picDic removeObjectForKey:[NSString stringWithFormat:@"%d", selectedPicIndex]];
            
            switch (selectedPicIndex)
            {
                case 1:
                    self.ServiceFormIV.image = [UIImage imageNamed:@"addPic"];
                    break;
                case 2:
                    self.SnecePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    break;
                case 3:
                    self.TouchSencePhotoIV.image = [UIImage imageNamed:@"addPic"];
                    break;
            }
        }
        if(alertView.tag == 2)
        {
            [otherPicArray removeObjectAtIndex:selectOtherPicIndex];
            [self reloadOtherHeight:NO];
            [self.otherCollectionView reloadData];
        }
    }
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
        if ([otherPicArray count] <= 6)
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
    selectedPicIndex = 100;
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
//        UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                              delegate:self
//                                                     cancelButtonTitle:@"取消"
//                                                destructiveButtonTitle:nil
//                                                     otherButtonTitles:@"删除", nil];
//        delSheet.tag = -4;
//        selectOtherPicIndex = row;
//        [delSheet showInView:self.view];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"请选择?" delegate:self cancelButtonTitle:@"删除图片" otherButtonTitles:@"取消", nil];
        alert.tag = 2;
        selectOtherPicIndex = row;
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
//    else if (actionSheet.tag == -4) {
//        if (buttonIndex == 0) {
//            [otherPicArray removeObjectAtIndex:selectOtherPicIndex];
//            [self reloadOtherHeight:NO];
//            [self.otherCollectionView reloadData];
//        }
//    }
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
                case 1:
                    [self.ServiceFormIV setImage:tImg];
                    break;
                case 2:
                    [self.SnecePhotoIV setImage:tImg];
                    break;
                case 3:
                    [self.TouchSencePhotoIV setImage:tImg];
                    break;
            }
            [picDic setObject:tImg forKey:[NSString stringWithFormat:@"%d",selectedPicIndex]];
        }
        else
        {
            [otherPicArray insertObject:smallImage atIndex:[otherPicArray count] -1];
            [self reloadOtherHeight:YES];
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

- (void)submitAction:(id )sender
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
    if (![picDic objectForKey:@"1"]) {
        [Tool showCustomHUD:@"please upload Service Form" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    if (engineerNote.length == 0)
    {
        [Tool showCustomHUD:@"please engineerNote" andView:self.view andImage:nil andAfterDelay:1.2f];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:hud];
    
    NSDateComponents *datec = [Tool getCurrentYear_Month_Day];
    NSInteger year = [datec year];
    
    if ([self.serviceTypeTF.text isEqualToString:@"Annual 4 times maintenace"])
    {
        NSString *sql = [NSString stringWithFormat:@"Select COUNT(*) From TB_CUST_ProjInf_MatnRec Where Project='%@' and Proj_ID='%@' and OutFact_Num='%@' and YEAR(UploadTime)=%d", serviceItemCN, self.projId, unitNum, year];
        
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
                     [Tool showCustomHUD:@"This Type record already exists" andView:self.view andImage:nil andAfterDelay:1.2f];
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
                case 1:
                    picFirstName = @"SnecePhoto";
                    break;
                case 2:
                    picFirstName = @"ServiceForm";
                    break;
                case 3:
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
    for(int i = 0; i < otherPicArray.count - 1; ++i)
    {
        imgbegin = nil;
        imgbegin = otherPicArray[i];
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
                NSString *string = [NSString stringWithFormat:@"/UploadFile/%@/", [Tool getCurrentTimeStr:@"yyyyMMdd"]];
                img = nil;
                base64Encoded = nil;
                
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO ERPSaveFileName ([NowName],[OldName],[Uploader],[UploaderEn],[FileUrl],[FileType])VALUES ('%@', '%@','%@' ,'%@','%@','%@')", fileName, reName, Exec_Man, Engineer, string, FileType];
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
                    
                    //                    if([response containsString:@"true"])
                    if([response2 rangeOfString:@"true"].length > 0)
                    {
                        isOK = YES;
                        switch (index)
                        {
//                                NSString *allfilename;//other
//                                NSString *allfilename02;//service form
//                                NSString *allfilename03;//TouchSencePhoto
//                                NSString *allfilename04;//SnecePhoto
                            case 1:
                                allfilename02 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 2:
                                allfilename04 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 3:
                                allfilename03 = [NSString stringWithFormat:@"|%@",fileName];
                                break;
                            case 4:
                                if(allfilename == nil || [allfilename isEqualToString:@"null"])
                                {
                                    allfilename = @"";
                                }
                                allfilename = [NSString stringWithFormat:@"%@|%@",allfilename,fileName];
                                allfilename = [allfilename stringByReplacingOccurrencesOfString:@"null" withString:@""];
                                break;
                        }
                    }
                }
            }
        }
    }
    return isOK;
}

- (void)insertData
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
    
    if(![Tool isStringExist:allfilename])
    {
        allfilename = @"null";
    }
    else
    {
        allfilename = [NSString stringWithFormat:@"'%@'", allfilename];
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    NSString *sql = [NSString stringWithFormat:@"insert into TB_CUST_ProjInf_MatnRec  ( Proj_ID, Exec_Man, Exec_Man_En,  Exec_Date, Exec_Date01, Exec_Date02,AirCondUnit_Mode,OutFact_Num,Pro_Num,Type,Type_En,Project,Project_En,Uploader,Uploader_En,UploadTime,AirCondUnit_Mode_Hold,OutFact_Num_Hold,Serv_Dept_Hold,Engineer_Hold,CUST_Code_Hold,CUST_Name,Rating,allfilename,allfilename02,allfilename03,allfilename04,EngineerNote,EngineerSign,EngineerSignDate,ManagerNote,ManagerSign,ManagerSignDate,UserHQNote,UserHQSign,UserHQSignDate,Mark,EngineerFeedback,EngineerFeedbackSign,EngineerFeedbackSignDate) values  ('%@','%@','%@','%@',NULL,NULL,'%@','%@','%@','%@','%@','%@','%@','%@','%@','%@',NULL,NULL,NULL,NULL,NULL,NULL,NULL,%@,%@,%@,%@,'%@','%@','%@',NULL,NULL,NULL,NULL,NULL,NULL,'%@',NULL,NULL,NULL)",self.projId, Exec_Man, Engineer, self.serviceDateTF.text, AirCondUnit_Mode, selectedUnit.OutFact_Num, selectedUnit.Prod_Num, [selectServiceTypeDic objectForKey:@"typeCN"], [selectServiceTypeDic objectForKey:@"typeEN"], [selectServiceItemDic objectForKey:@"itemCN"], [selectServiceItemDic objectForKey:@"itemEN"], Exec_Man, Engineer, self.UploadDateTF.text,allfilename, allfilename02, allfilename03, allfilename04, self.EngineerNoteTV.text, Engineer, self.UploadDateTF.text, Mark];
    
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
            
//            [Tool showCustomHUD:@"成功" andView:self.view andImage:nil andAfterDelay:1.2f];
//            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_WeiXiuListReLoad" object:nil];
//            [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
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
    NSString *sql = [NSString stringWithFormat:@"Sp_GetFlowStartInfo_En '维护保养审批(英文版)','%@'", userinfo.UserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@JsonDataInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sql forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSelectNext:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"请稍后..." andView:self.view andHUD:request.hud];
}

- (void)requestSelectNext:(ASIHTTPRequest *)request
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
        NSMutableArray *StepNames = [[NSMutableArray alloc] init];
        NSMutableArray *NextUserNames = [[NSMutableArray alloc] init];
        for(NSDictionary *jsonDic in jsonArray)
        {
            [StepNames addObject:jsonDic[@"StepName"]];
            [NextUserNames addObject:jsonDic[@"NextUserName"]];
        }
        [SGActionView showSheetWithTitle:@"Please Select" itemTitles:NextUserNames itemSubTitles:StepNames selectedIndex:-1 selectedHandle:^(NSInteger index){
            NSDictionary *dic = jsonArray[index];
            
            NSString *sql = [NSString stringWithFormat:@"Sp_FlowStart_En '%@','维护保养审批(英文版)','%d','Fill in the information','%@','%@'", userinfo.UserName, [[dic objectForKey:@"NextUserNameCode"] intValue], Mark, self.projId];
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
        }];
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
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
            //写日志
            NSString *ip = [Tool getIPAddress:YES];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@DoActionInDZDA",api_base_url]]];
            [request setUseCookiePersistence:NO];
            [request setTimeOutSeconds:30];
            NSString *sql = [NSString stringWithFormat:@"sp_executesql N'insert into [ERPRiZhi] (UserName,Operation,Plate,ProjName,DoSomething,IpStr) values (@UserName,@Operation,@Plate,@ProjName,@DoSomething,@IpStr);select @@IDENTITY',N'@UserName varchar(50),@Operation varchar(20),@Plate varchar(100),@ProjName varchar(500),@DoSomething varchar(1000),@IpStr varchar(50)',@UserName='%@',@Operation='新增',@Plate='维护保养审批(英文app)',@ProjName='%@',@DoSomething='维护保养信息审批(英文版)',@IpStr='%@'", userinfo.UserName, PROJ_Name, ip];
            
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_MaintainingListReLoad" object:nil];
                    [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
                }
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"Back";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
