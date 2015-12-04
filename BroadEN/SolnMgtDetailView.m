//
//  SolnMgtDetailView.m
//  BroadEN
//
//  Created by Seven on 15/12/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "SolnMgtDetailView.h"
#import "SolnMgt.h"

@interface SolnMgtDetailView ()
{
    SolnMgt *solnMgt;
}

@end

@implementation SolnMgtDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Soln Mgt Message";
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
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
    [Tool showHUD:@"加载中..." andView:self.view andHUD:request.hud];
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
        else if ([CN isEqualToString:@"不合格"]) {
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
