//
//  MaintauningDetailView.m
//  BroadEN
//
//  Created by Seven on 15/11/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MaintauningDetailView.h"
#import "ImageCollectionCell.h"
#import "Maintaining.h"
#import "Img.h"
#import "UIImageView+WebCache.h"
#import "MWPhotoBrowser.h"

@interface MaintauningDetailView ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate>
{
    Maintaining *maintaining;
    NSArray *picArray;
    NSMutableArray *otherPicArray;
    NSString *allfilename02Url;
    NSString *allfilename03Url;
    NSString *allfilename04Url;

    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation MaintauningDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Maintenance Record";
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    otherPicArray = [[NSMutableArray alloc] init];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getDetailData];
    
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

- (void)getDetailData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from TB_CUST_ProjInf_MatnRec where id='%@'", self.ID];
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
    
    //多加了个View暂时先这么办吧
    CGRect mainViewFrame = self.mainView.frame;
    mainViewFrame.size.height = mainViewFrame.size.height + addHeight;
    self.mainView.frame = mainViewFrame;
    
    CGRect main2ViewFrame = self.main2View.frame;
    main2ViewFrame.origin.y= main2ViewFrame.origin.y + addHeight;
    self.main2View.frame = main2ViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.main2View.frame.origin.y + self.main2View.frame.size.height);
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

@end
