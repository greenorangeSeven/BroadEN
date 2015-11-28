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

#import "ZeroHeightTableCell.h"

@interface UnitInfoDetailView ()
{
    UnitInfoBasicOne *basicOne;
    UnitInfoBasicTwo *basicTwo;
    NSArray *shippings;
    NSArray *commisses;
    NSMutableArray *unitInforItems;
}

@end

@implementation UnitInfoDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Unit Info Detail";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    unitInforItems = [[NSMutableArray alloc] init];
    
    [self getBasicInfoData];
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
        UnitInfoBasicOne *u1 = (UnitInfoBasicOne *)item;
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
//    NSInteger row = [indexPath row];
//    UnitInfo *u = [units objectAtIndex:row];
//    UnitInfoDetailView *detailView = [[UnitInfoDetailView alloc] init];
//    detailView.ID = u.ID;
//    detailView.PROJ_ID = u.PROJ_ID;
//    [self.navigationController pushViewController:detailView animated:YES];
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

@end
