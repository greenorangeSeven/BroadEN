//
//  UserBasicInfoView.m
//  BroadEN
//
//  Created by Seven on 15/11/23.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserBasicInfoView.h"
#import "UserBasicInfo.h"
#import "UserBasicInfoUpdateView.h"

@interface UserBasicInfoView ()
{
    UIBarButtonItem *modifyBtn;
    UIBarButtonItem *saveBtn;
    UserBasicInfo *basicInfo;
}

@end

@implementation UserBasicInfoView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    
    modifyBtn = [[UIBarButtonItem alloc] initWithTitle: @"Modify" style:UIBarButtonItemStyleBordered target:self action:@selector(modifyAction:)];
    self.navigationItem.rightBarButtonItem = modifyBtn;
    
    saveBtn = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    for (UIView *subView in [self.scrollView subviews])
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            ((UITextField *)subView).enabled = NO;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReload) name:@"Notification_UserBasicInfoReLoad" object:nil];
    
    [self getData];
}

- (void)dataReload
{
    [self getData];
}

- (void)modifyAction:(id)sender
{
    UserBasicInfoUpdateView *basicInfoUpdateView = [[UserBasicInfoUpdateView alloc] init];
    basicInfoUpdateView.basicInfo = basicInfo;
    basicInfoUpdateView.title = self.titleStr;
    [self.navigationController pushViewController:basicInfoUpdateView animated:YES];
}

- (void)saveAction:(id)sender
{
    
}

- (void)getData
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * FROM [TB_CUST_ProjInf] where ID='%@'",self.ID];
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
        NSLog(string);
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if(jsonArray && jsonArray.count > 0){
            NSDictionary *jsonDic = [jsonArray objectAtIndex:0];
            basicInfo = [Tool readJsonDicToObj:jsonDic andObjClass:[UserBasicInfo class]];
            if (basicInfo) {
                [self bindData];
            }
        }
        
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)bindData
{
    self.EnglishNameTF.text = basicInfo.PROJ_Name_En;
    self.DistributorTF.text = basicInfo.Franchiser;
    self.ChinesenameTF.text = basicInfo.PROJ_Name;
    self.ShortnameTF.text = basicInfo.CustShortName_CN;
    self.FormernameTF.text = basicInfo.Duty_PassEngineer_En;
    self.AdressTF.text = basicInfo.PostalAdd_EN;
    self.CountryTF.text = basicInfo.Country_EN;
    self.CityTF.text = basicInfo.City_EN;
    self.ZipTF.text = basicInfo.Zip_Cd;
    self.FaxTF.text = basicInfo.Fax;
    
    self.SLTF.text = basicInfo.Mgmt_High;
    self.SLDepartmentTF.text = basicInfo.Mgmt_High_Dept;
    self.SLDutiesTF.text = basicInfo.Mgmt_High_Pos;
    self.SLCellNoTF.text = basicInfo.Mgmt_High_Tel;
    self.SLMailTF.text = basicInfo.Mgmt_High_EMail;
    
    self.MLTF.text = basicInfo.Mgmt_Midd;
    self.MLDepartmentTF.text = basicInfo.DeptMgmt_Midd;
    self.MLDutiesTF.text = basicInfo.DeptMgmt_Midd_Pos;
    self.MLCellNoTF.text = basicInfo.DeptMgmt_Midd_Tel;
    self.MLMailTF.text = basicInfo.DeptMgmt_Midd_EMail;
    
    self.BLTF.text = basicInfo.Mgmt_MachRoom;
    self.BLDepartmentTF.text = basicInfo.Mgmt_MachRoom_Dept;
    self.BLDutiesTF.text = basicInfo.Mgmt_MachRoom_Pos;
    self.BLCellNoTF.text = basicInfo.Mgmt_MachRoom_Tel;
    self.BLMailTF.text = basicInfo.Mgmt_MachRoom_Email;
    
    self.ContractNoTF.text = basicInfo.CONTRACT_No;
    self.ContractmanagerTF.text = basicInfo.Con_Manager;
    self.SigningDateTF.text = basicInfo.ConJudm_Date;
    self.InvestmentcompanyTF.text = basicInfo.Invest_Unit;
    
    
    self.BuildingheightTF.text = [NSString stringWithFormat:@"%@m", basicInfo.Building_Height];
    self.NatureofindustryTF.text = basicInfo.Cust_Habitude;
    self.BuildingareaTF.text = [NSString stringWithFormat:@"%@m²", basicInfo.Building_Area];
    self.ApplicationsTF.text = basicInfo.Building_Usage;
    self.TotalACareaTF.text = [NSString stringWithFormat:@"%@m²", basicInfo.AirCond_Area];
    self.CoolingloadTF.text = [NSString stringWithFormat:@"%@x10⁴Kcal", basicInfo.Load_Refg];
    self.HeatingloadTF.text = [NSString stringWithFormat:@"%@x10⁴Kcal", basicInfo.Load_Heating];
    
    self.VarietiesoffuelTF.text = basicInfo.FuelType;
    self.CalorificvalueTF.text = [NSString stringWithFormat:@"%@Kcal/m³", basicInfo.Heat_Value];
    self.FuelpressureTF.text = [NSString stringWithFormat:@"%@KPa", basicInfo.Pressure];
    self.RatedconsumptionTF.text = [NSString stringWithFormat:@"%.1fm³/h", [basicInfo.RatingFuel_Num doubleValue]];
    self.RuntimeperdayTF.text = [NSString stringWithFormat:@"%@h", basicInfo.Day_RunTime];
    self.ChilledpressureTF.text = [NSString stringWithFormat:@"%@/%@MPa", basicInfo.ColdWaterIn_Pressure, basicInfo.ColdWaterOut_Pressure];
    self.WarmpressureTF.text = [NSString stringWithFormat:@"%@/%@MPa", basicInfo.WarmWaterIn_Pressure, basicInfo.WarmWaterOut_Pressure];
    self.CoolingpressureTF.text = [NSString stringWithFormat:@"%@/%@MPa", basicInfo.CoolWaterIn_Pressure, basicInfo.CoolWaterOut_Pressure];
    self.HotpressureTF.text = [NSString stringWithFormat:@"%@/%@MPa", basicInfo.HotWaterIn_Pressure, basicInfo.HotWaterOut_Pressure];
    self.DescribeCWCHTF.text = basicInfo.MachRoom_Inf;
    
    self.OthersTF.text = basicInfo.Engineer_Score;
    
    self.Flow1chilledWaterpumpTF.text = [NSString stringWithFormat:@"%@m³", basicInfo.ColdWater_PumpFlow];
    self.F1CWHeadTF.text = [NSString stringWithFormat:@"%@m", basicInfo.ColdWater_PumpLift];
    self.F1CWPowerTF.text = [NSString stringWithFormat:@"%@kw", basicInfo.ColdWater_Power];
    self.F1CWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.ColdWater_Num intValue]];
    self.F1CWOriginTF.text = basicInfo.ColdWater_Brand;
    
    self.Flow2chilledWaterpumpTF.text = [NSString stringWithFormat:@"%@m³", basicInfo.ColdWater_PumpFlow2];
    self.F2CWHeadTF.text = [NSString stringWithFormat:@"%@m", basicInfo.ColdWater_PumpLift2];
    self.F2CWPowerTF.text = [NSString stringWithFormat:@"%@kw", basicInfo.ColdWater_Power2];
    self.F2CWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.ColdWater_Num2 intValue]];
    self.F2CWOriginTF.text = basicInfo.ColdWater_Brand2;
    
    self.Flow1coolingWaterpumpTF.text = [NSString stringWithFormat:@"%@m³", basicInfo.CoolWater_PumpFlow];
    self.F1CoolWHeadTF.text = [NSString stringWithFormat:@"%@m", basicInfo.CoolWater_PumpFlow];
    self.F1CoolWPowerTF.text = [NSString stringWithFormat:@"%@kw", basicInfo.CoolWater_Power];
    self.F1CoolWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.CoolWater_Num intValue]];
    self.F1CoolWOriginTF.text = basicInfo.CoolWater_Brand;
    
    self.Flow2coolingWaterpumpTF.text = [NSString stringWithFormat:@"%@m³", basicInfo.CoolWater_PumpFlow2];
    self.F2CoolWHeadTF.text = [NSString stringWithFormat:@"%@m", basicInfo.CoolWater_PumpFlow2];
    self.F2CoolWPowerTF.text = [NSString stringWithFormat:@"%@kw", basicInfo.CoolWater_Power2];
    self.F2CoolWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.CoolWater_Num2 intValue]];
    self.F2CoolWOriginTF.text = basicInfo.CoolWater_Brand2;
    
    self.Sys_ElseThingTF.text = basicInfo.Sys_ElseThing;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
