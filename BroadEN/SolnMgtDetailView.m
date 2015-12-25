//
//  SolnMgtDetailView.m
//  BroadEN
//
//  Created by Seven on 15/12/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SolnMgtDetailView.h"
#import "SolnMgt.h"
#import "ImageCollectionCell.h"
#import "Img.h"
#import "MWPhotoBrowser.h"

@interface SolnMgtDetailView ()<UICollectionViewDataSource,UICollectionViewDelegate,MWPhotoBrowserDelegate>
{
    SolnMgt *solnMgt;
    
    NSArray *picArray;
    NSMutableArray *filePicArray;
    NSMutableArray *_photos;
}
@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation SolnMgtDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Solution Management";
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
    
    [self getSolnDetailData];
}

- (void)getSolnDetailData
{
    NSString *sqlStr = [NSString stringWithFormat:@"SP_GetSolutionReportEn'%@'", self.ID];
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
    self.InspectorSignDateLB.text = [Tool DateTimeRemoveTime:solnMgt.InspectorSignDate andSeparated:@" "];
    
    self.LithiumLb.text = [NSString stringWithFormat:@"%@Kg/t", solnMgt.Lithium];
    
    self.HandingDateTF.text = [Tool DateTimeRemoveTime:solnMgt.HandleTime andSeparated:@" "];
    self.ExplainInfoTV.text = solnMgt.Other;
    
    if (solnMgt.allfilename.length > 0) {
        [self getImg:solnMgt.allfilename andImageIndex:3];
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
             if(picArray && picArray.count > 0)
             {
                 switch (imageIndex) {
                     case 3:
                         filePicArray = [NSMutableArray arrayWithArray:picArray];
                         [self reloadOtherHeight:YES andIsInit:YES];
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

- (void)reloadOtherHeight:(BOOL )addORcutRow andIsInit:(BOOL )ISInit
{
    int addRow = 0;
    if(ISInit)
    {
        if ([filePicArray count] % 3 > 0) {
            addRow = [filePicArray count]/3 + 1 - 1;
        }
        else
        {
            addRow = [filePicArray count]/3 - 1;
        }
    }
    else
    {
        if(addORcutRow)
        {
            if ([filePicArray count] % 3 == 1) {
                addRow = 1;
            }
        }
        else
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

//    //设置photoView下移
    CGRect photoViewFrame = self.photoView.frame;
    photoViewFrame.origin.y = photoViewFrame.origin.y + addHeight;
    self.photoView.frame = photoViewFrame;
    
    CGRect explainViewFrame = self.explainView.frame;
    explainViewFrame.origin.y = explainViewFrame.origin.y + addHeight;
    self.explainView.frame = explainViewFrame;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.explainView.frame.origin.y + self.explainView.frame.size.height);
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
    Img *picImage = [filePicArray objectAtIndex:row];
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
