//
//  UserBasicInfoUpdateView.m
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "UserBasicInfoUpdateView.h"

@interface UserBasicInfoUpdateView ()
{
    UIBarButtonItem *saveBtn;
    
    NSString *PROJ_Name_En;
    NSString *Franchiser;
    NSString *PROJ_Name;
    NSString *CustShortName_CN;
    NSString *Duty_PassEngineer_En;
    NSString *PostalAdd_EN;
    NSString *Country_EN;
    NSString *City_EN;
    NSString *Zip_Cd;
    NSString *Fax;
    
    NSString *Mgmt_High;
    NSString *Mgmt_High_Dept;
    NSString *Mgmt_High_Pos;
    NSString *Mgmt_High_Tel;
    NSString *Mgmt_High_EMail;
    
    NSString *Mgmt_Midd;
    NSString *DeptMgmt_Midd;
    NSString *DeptMgmt_Midd_Pos;
    NSString *DeptMgmt_Midd_Tel;
    NSString *DeptMgmt_Midd_EMail;
    
    NSString *Mgmt_MachRoom;
    NSString *Mgmt_MachRoom_Dept;
    NSString *Mgmt_MachRoom_Pos;
    NSString *Mgmt_MachRoom_Tel;
    NSString *Mgmt_MachRoom_Email;
    
    NSString *CONTRACT_No;
    NSString *Con_Manager;
    NSString *ConJudm_Date;
    NSString *Invest_Unit;
    
    NSString *Building_Height;
    NSString *Cust_Habitude;
    NSString *Building_Area;
    NSString *Building_Usage;
    NSString *AirCond_Area;
    NSString *Load_Refg;
    NSString *Load_Heating;
    
    NSString *FuelType;
    NSString *Heat_Value;
    NSString *Pressure;
    NSString *RatingFuel_Num;
    NSString *Day_RunTime;
    
    NSString *ColdWaterIn_Pressure;
    NSString *ColdWaterOut_Pressure;
    NSString *WarmWaterIn_Pressure;
    NSString *WarmWaterOut_Pressure;
    NSString *CoolWaterIn_Pressure;
    NSString *CoolWaterOut_Pressure;
    NSString *HotWaterIn_Pressure;
    NSString *HotWaterOut_Pressure;
    NSString *MachRoom_Inf;
    NSString *Engineer_Score;
    
    NSString *ColdWater_PumpFlow;
    NSString *ColdWater_PumpLift;
    NSString *ColdWater_Power;
    NSString *ColdWater_Num;
    NSString *ColdWater_Brand;
    
    NSString *ColdWater_PumpFlow2;
    NSString *ColdWater_PumpLift2;
    NSString *ColdWater_Power2;
    NSString *ColdWater_Num2;
    NSString *ColdWater_Brand2;
    
    NSString *CoolWater_PumpFlow;
    NSString *CoolWater_PumpLift;
    NSString *CoolWater_Power;
    NSString *CoolWater_Num;
    NSString *CoolWater_Brand;
    
    NSString *CoolWater_PumpFlow2;
    NSString *CoolWater_PumpLift2;
    NSString *CoolWater_Power2;
    NSString *CoolWater_Num2;
    NSString *CoolWater_Brand2;
}

@end

@implementation UserBasicInfoUpdateView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveBtn = [[UIBarButtonItem alloc] initWithTitle: @"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    for (UIView *subView in [self.scrollView subviews])
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            ((UITextField *)subView).enabled = YES;
            ((UITextField *)subView).background = [UIImage imageNamed:@"textfieldbg"];
        }
    }
    [self bindData];
}

- (void)saveAction:(id)sender
{
//    NSString *verifyStr = [self verifyData];
//    if([Tool isStringExist:verifyStr])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert:" message:verifyStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    NSMutableString *mutableSQL = [[NSMutableString alloc] initWithString:@"update TB_CUST_ProjInf set"];
    [mutableSQL appendString:[NSString stringWithFormat:@" PROJ_Name_En='%@',", PROJ_Name_En]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Franchiser='%@',", Franchiser]];
    [mutableSQL appendString:[NSString stringWithFormat:@" PROJ_Name='%@',", PROJ_Name]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CustShortName_CN='%@',", CustShortName_CN]];
    [mutableSQL appendString:[NSString stringWithFormat:@" yhcym='%@',", Duty_PassEngineer_En]];
    [mutableSQL appendString:[NSString stringWithFormat:@" PostalAdd_CN='%@',", PostalAdd_EN]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Country_EN='%@',", Country_EN]];
    [mutableSQL appendString:[NSString stringWithFormat:@" City_CN='%@',", City_EN]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Zip_Cd='%@',", Zip_Cd]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Fax='%@',", Fax]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_High='%@',", Mgmt_High]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_High_Dept='%@',", Mgmt_High_Dept]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_High_Pos='%@',", Mgmt_High_Pos]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_High_Tel='%@',", Mgmt_High_Tel]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_High_EMail='%@',", Mgmt_High_EMail]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_Midd='%@',", Mgmt_Midd]];
    [mutableSQL appendString:[NSString stringWithFormat:@" DeptMgmt_Midd='%@',", DeptMgmt_Midd]];
    [mutableSQL appendString:[NSString stringWithFormat:@" DeptMgmt_Midd_Pos='%@',", DeptMgmt_Midd_Pos]];
    [mutableSQL appendString:[NSString stringWithFormat:@" DeptMgmt_Midd_Tel='%@',", DeptMgmt_Midd_Tel]];
    [mutableSQL appendString:[NSString stringWithFormat:@" DeptMgmt_Midd_EMail='%@',", DeptMgmt_Midd_EMail]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_MachRoom='%@',", Mgmt_MachRoom]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_MachRoom_Dept='%@',", Mgmt_MachRoom_Dept]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_MachRoom_Pos='%@',", Mgmt_MachRoom_Pos]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_MachRoom_Tel='%@',", Mgmt_MachRoom_Tel]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Mgmt_MachRoom_EMail='%@',", Mgmt_MachRoom_Email]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CONTRACT_No='%@',", CONTRACT_No]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Con_Manager='%@',", Con_Manager]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ConJudm_Date='%@',", ConJudm_Date]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Invest_Unit='%@',", Invest_Unit]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Building_Height='%@',", Building_Height]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Cust_Habitude='%@',", Cust_Habitude]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Building_Area='%@',", Building_Area]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Building_Usage='%@',", Building_Usage]];
    [mutableSQL appendString:[NSString stringWithFormat:@" AirCond_Area='%@',", AirCond_Area]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Load_Refg='%@',", Load_Refg]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Load_Heating='%@',", Load_Heating]];
    [mutableSQL appendString:[NSString stringWithFormat:@" FuelType='%@',", FuelType]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Heat_Value='%@',", Heat_Value]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Pressure='%@',", Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" RatingFuel_Num='%@',", RatingFuel_Num]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Day_RunTime='%@',", Day_RunTime]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWaterIn_Pressure='%@',", ColdWaterIn_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWaterOut_Pressure='%@',", ColdWaterOut_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" WarmWaterIn_Pressure='%@',", WarmWaterIn_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" WarmWaterOut_Pressure='%@',", WarmWaterOut_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWaterIn_Pressure='%@',", CoolWaterIn_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWaterOut_Pressure='%@',", CoolWaterOut_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" HotWaterIn_Pressure='%@',", HotWaterIn_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" HotWaterOut_Pressure='%@',", HotWaterOut_Pressure]];
    [mutableSQL appendString:[NSString stringWithFormat:@" MachRoom_Inf='%@',", MachRoom_Inf]];
    [mutableSQL appendString:[NSString stringWithFormat:@" Engineer_Score='%@',", Engineer_Score]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_PumpFlow='%@',", ColdWater_PumpFlow]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_PumpLift='%@',", ColdWater_PumpLift]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Power='%@',", ColdWater_Power]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Num='%@',", ColdWater_Num]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Brand='%@',", ColdWater_Brand]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_PumpFlow2='%@',", ColdWater_PumpFlow2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_PumpLift2='%@',", ColdWater_PumpLift2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Power2='%@',", ColdWater_Power2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Num2='%@',", ColdWater_Num2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" ColdWater_Brand2='%@',", ColdWater_Brand2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_PumpFlow='%@',", CoolWater_PumpFlow]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_PumpLift='%@',", CoolWater_PumpLift]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Power='%@',", CoolWater_Power]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Num='%@',", CoolWater_Num]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Brand='%@',", CoolWater_Brand]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_PumpFlow2='%@',", CoolWater_PumpFlow2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_PumpLift2='%@',", CoolWater_PumpLift2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Power2='%@',", CoolWater_Power2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Num2='%@',", CoolWater_Num2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" CoolWater_Brand2='%@' ", CoolWater_Brand2]];
    [mutableSQL appendString:[NSString stringWithFormat:@" where ID='%@'", self.basicInfo.ID]];
    
    NSString *sqlStr = [NSString stringWithString:mutableSQL];
    NSString *urlStr = [NSString stringWithFormat:@"%@DoActionInDZDA", api_base_url];
    NSURL *url = [NSURL URLWithString: urlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:sqlStr forKey:@"sqlstr"];
    [request setDelegate:self];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSave:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"Saveing..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
}

- (void)requestSave:(ASIHTTPRequest *)request
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
//        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *error;
        NSLog(string);
        if([string isEqualToString:@"true"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_UserBasicInfoReLoad" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    NSLog(@"%@",request.responseString);
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (NSString *)verifyData
{
    NSString *verifyStr = @"";
    
    PROJ_Name_En = self.EnglishNameTF.text;
    if(![Tool isStringExist:PROJ_Name_En])
    {
        verifyStr = @"Please Write English name";
        return verifyStr;
    }
    Franchiser = self.DistributorTF.text;
    PROJ_Name = self.ChinesenameTF.text;
    if(![Tool isStringExist:PROJ_Name])
    {
        verifyStr = @"Please Write Chinese name";
        return verifyStr;
    }
    CustShortName_CN = self.ShortnameTF.text;
    if(![Tool isStringExist:CustShortName_CN])
    {
        verifyStr = @"Please Write ShortName";
        return verifyStr;
    }
    Duty_PassEngineer_En = self.FormernameTF.text;
    PostalAdd_EN = self.AdressTF.text;
    if(![Tool isStringExist:PostalAdd_EN])
    {
        verifyStr = @"Please Write adress";
        return verifyStr;
    }
    Country_EN = self.CountryTF.text;
    if(![Tool isStringExist:Country_EN])
    {
        verifyStr = @"Please Write country";
        return verifyStr;
    }
    City_EN = self.CityTF.text;
    if(![Tool isStringExist:City_EN])
    {
        verifyStr = @"Please Write city";
        return verifyStr;
    }
    Zip_Cd = self.ZipTF.text;
    if(![Tool isStringExist:Zip_Cd])
    {
        verifyStr = @"Please Write zip";
        return verifyStr;
    }
    Fax = self.FaxTF.text;
    
    Mgmt_High = self.SLTF.text;
    Mgmt_High_Dept = self.SLDepartmentTF.text;
    Mgmt_High_Pos = self.SLDutiesTF.text;
    Mgmt_High_Tel = self.SLCellNoTF.text;
    Mgmt_High_EMail = self.SLMailTF.text;
    
    Mgmt_Midd = self.MLTF.text;
    DeptMgmt_Midd = self.MLDepartmentTF.text;
    if(![Tool isStringExist:DeptMgmt_Midd])
    {
        verifyStr = @"Please Write Middle Department";
        return verifyStr;
    }
    DeptMgmt_Midd_Pos = self.MLDutiesTF.text;
    if(![Tool isStringExist:DeptMgmt_Midd_Pos])
    {
        verifyStr = @"Please Write Middle Pos";
        return verifyStr;
    }
    DeptMgmt_Midd_Tel = self.MLCellNoTF.text;
    if(![Tool isStringExist:DeptMgmt_Midd_Tel])
    {
        verifyStr = @"Please Write Middle Phone";
        return verifyStr;
    }
    DeptMgmt_Midd_EMail = self.MLMailTF.text;
    if(![Tool isStringExist:DeptMgmt_Midd_EMail])
    {
        verifyStr = @"Please Write Middle EMail";
        return verifyStr;
    }
    
    Mgmt_MachRoom = self.BLTF.text;
    Mgmt_MachRoom_Dept = self.BLDepartmentTF.text;
    Mgmt_MachRoom_Pos = self.BLDutiesTF.text;
    Mgmt_MachRoom_Tel = self.BLCellNoTF.text;
    Mgmt_MachRoom_Email = self.BLMailTF.text;
    
    CONTRACT_No = self.ContractNoTF.text;
    Con_Manager = self.ContractmanagerTF.text;
    ConJudm_Date = self.SigningDateTF.text;
    Invest_Unit = self.InvestmentcompanyTF.text;
    
    Building_Height = self.BuildingheightTF.text;
    if(![Tool isStringExist:Building_Height])
    {
        verifyStr = @"Please Write Buildingheight";
        return verifyStr;
    }
    Cust_Habitude = self.NatureofindustryTF.text;
    if(![Tool isStringExist:Cust_Habitude])
    {
        verifyStr = @"Please Write Natureofindustry";
        return verifyStr;
    }
    Building_Area = self.BuildingareaTF.text;
    if(![Tool isStringExist:Building_Area])
    {
        verifyStr = @"Please Write Buildingarea";
        return verifyStr;
    }
    Building_Usage = self.ApplicationsTF.text;
    if(![Tool isStringExist:Building_Usage])
    {
        verifyStr = @"Please Write Applications";
        return verifyStr;
    }
    AirCond_Area = self.TotalACareaTF.text;
    if(![Tool isStringExist:AirCond_Area])
    {
        verifyStr = @"Please Write TotalACarea";
        return verifyStr;
    }
    Load_Refg = self.CoolingloadTF.text;
    Load_Heating = self.HeatingloadTF.text;
    
    FuelType = self.VarietiesoffuelTF.text;
    Heat_Value = self.CalorificvalueTF.text;
    Pressure = self.FuelpressureTF.text;
    RatingFuel_Num = self.RatedconsumptionTF.text;
    Day_RunTime = self.RuntimeperdayTF.text;
    
    ColdWaterIn_Pressure = self.ChilledpressureTF.text;
    ColdWaterOut_Pressure = self.ColdWaterOutPressureTF.text;
    WarmWaterIn_Pressure = self.WarmpressureTF.text;
    WarmWaterOut_Pressure = self.WarmWaterOutPressureTF.text;
    CoolWaterIn_Pressure = self.CoolingpressureTF.text;
    CoolWaterOut_Pressure = self.CoolWaterOutPressureTF.text;
    HotWaterIn_Pressure = self.HotpressureTF.text;
    HotWaterOut_Pressure = self.HotWaterOutpressureTF.text;
    MachRoom_Inf = self.DescribeCWCHTF.text;
    Engineer_Score = self.OthersTF.text;
    
    ColdWater_PumpFlow = self.Flow1chilledWaterpumpTF.text;
    if(![Tool isStringExist:ColdWater_PumpFlow])
    {
        verifyStr = @"Please Write Flow of No.1 chilled w.pum";
        return verifyStr;
    }
    ColdWater_PumpLift = self.F1CWHeadTF.text;
    if(![Tool isStringExist:ColdWater_PumpLift])
    {
        verifyStr = @"Please Write Flow of No.1 chilled w.pum Head";
        return verifyStr;
    }
    ColdWater_Power = self.F1CWPowerTF.text;
    if(![Tool isStringExist:ColdWater_Power])
    {
        verifyStr = @"Please Write Flow of No.1 chilled w.pum Power";
        return verifyStr;
    }
    ColdWater_Num = self.F1CWPcsTF.text;
    if(![Tool isStringExist:ColdWater_Num])
    {
        verifyStr = @"Please Write Flow of No.1 chilled w.pum Pcs";
        return verifyStr;
    }
    ColdWater_Brand = self.F1CWOriginTF.text;
    if(![Tool isStringExist:ColdWater_Brand])
    {
        verifyStr = @"Please Write Flow of No.1 chilled w.pum Origin Brand";
        return verifyStr;
    }
    
    ColdWater_PumpFlow2 = self.Flow2chilledWaterpumpTF.text;
    ColdWater_PumpLift2 = self.F2CWHeadTF.text;
    ColdWater_Power2 = self.F2CWPowerTF.text;
    ColdWater_Num2 = self.F2CWPcsTF.text;
    ColdWater_Brand2 = self.F2CWOriginTF.text;
    
    CoolWater_PumpFlow = self.Flow1coolingWaterpumpTF.text;
    if(![Tool isStringExist:CoolWater_PumpFlow])
    {
        verifyStr = @"Please Write Flow of No.1 cooling w.pum";
        return verifyStr;
    }
    CoolWater_PumpLift = self.F1CoolWHeadTF.text;
    if(![Tool isStringExist:CoolWater_PumpLift])
    {
        verifyStr = @"Please Write Flow of No.1 cooling w.pum Head";
        return verifyStr;
    }
    CoolWater_Power = self.F1CoolWPowerTF.text;
    if(![Tool isStringExist:ColdWater_Power])
    {
        verifyStr = @"Please Write Flow of No.1 cooling w.pum Power";
        return verifyStr;
    }
    CoolWater_Num = self.F1CoolWPcsTF.text;
    if(![Tool isStringExist:ColdWater_Num])
    {
        verifyStr = @"Please Write Flow of No.1 cooling w.pum Pcs";
        return verifyStr;
    }
    CoolWater_Brand = self.F1CoolWOriginTF.text;
    if(![Tool isStringExist:ColdWater_Brand])
    {
        verifyStr = @"Please Write Flow of No.1 cooling w.pum Origin Brand";
        return verifyStr;
    }
    
    CoolWater_PumpFlow2 = self.Flow2coolingWaterpumpTF.text;
    CoolWater_PumpLift2 = self.F2CoolWHeadTF.text;
    CoolWater_Power2 = self.F2CoolWPowerTF.text;
    CoolWater_Num2 = self.F2CoolWPcsTF.text;
    CoolWater_Brand2 = self.F2CoolWOriginTF.text;
    return verifyStr;
}

- (void)bindData
{
    self.EnglishNameTF.text = self.basicInfo.PROJ_Name_En;
    self.DistributorTF.text = self.basicInfo.Franchiser;
    self.ChinesenameTF.text = self.basicInfo.PROJ_Name;
    self.ShortnameTF.text = self.basicInfo.CustShortName_CN;
    self.FormernameTF.text = self.basicInfo.Duty_PassEngineer_En;
    self.AdressTF.text = self.basicInfo.PostalAdd_EN;
    self.CountryTF.text = self.basicInfo.Country_EN;
    self.CityTF.text = self.basicInfo.City_EN;
    self.ZipTF.text = self.basicInfo.Zip_Cd;
    self.FaxTF.text = self.basicInfo.Fax;
    
    self.SLTF.text = self.basicInfo.Mgmt_High;
    self.SLDepartmentTF.text = self.basicInfo.Mgmt_High_Dept;
    self.SLDutiesTF.text = self.basicInfo.Mgmt_High_Pos;
    self.SLCellNoTF.text = self.basicInfo.Mgmt_High_Tel;
    self.SLMailTF.text = self.basicInfo.Mgmt_High_EMail;
    
    self.MLTF.text = self.basicInfo.Mgmt_Midd;
    self.MLDepartmentTF.text = self.basicInfo.DeptMgmt_Midd;
    self.MLDutiesTF.text = self.basicInfo.DeptMgmt_Midd_Pos;
    self.MLCellNoTF.text = self.basicInfo.DeptMgmt_Midd_Tel;
    self.MLMailTF.text = self.basicInfo.DeptMgmt_Midd_EMail;
    
    self.BLTF.text = self.basicInfo.Mgmt_MachRoom;
    self.BLDepartmentTF.text = self.basicInfo.Mgmt_MachRoom_Dept;
    self.BLDutiesTF.text = self.basicInfo.Mgmt_MachRoom_Pos;
    self.BLCellNoTF.text = self.basicInfo.Mgmt_MachRoom_Tel;
    self.BLMailTF.text = self.basicInfo.Mgmt_MachRoom_Email;
    
    self.ContractNoTF.text = self.basicInfo.CONTRACT_No;
    self.ContractmanagerTF.text = self.basicInfo.Con_Manager;
    self.SigningDateTF.text = self.basicInfo.ConJudm_Date;
    self.InvestmentcompanyTF.text = self.basicInfo.Invest_Unit;
    
    self.BuildingheightTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Building_Height];
    self.NatureofindustryTF.text = self.basicInfo.Cust_Habitude;
    self.BuildingareaTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Building_Area];
    self.ApplicationsTF.text = self.basicInfo.Building_Usage;
    self.TotalACareaTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.AirCond_Area];
    self.CoolingloadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Load_Refg];
    self.HeatingloadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Load_Heating];

    self.VarietiesoffuelTF.text = self.basicInfo.FuelType;
    self.CalorificvalueTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Heat_Value];
    self.FuelpressureTF.text = [NSString stringWithFormat:@"%@KPa", self.basicInfo.Pressure];
    self.RatedconsumptionTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.RatingFuel_Num doubleValue]];
    self.RuntimeperdayTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.Day_RunTime];
    self.ChilledpressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.ColdWaterIn_Pressure doubleValue]];
    self.ColdWaterOutPressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.ColdWaterOut_Pressure doubleValue]];
    self.WarmpressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.WarmWaterIn_Pressure doubleValue]];
    self.WarmWaterOutPressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.WarmWaterOut_Pressure doubleValue]];
    self.CoolingpressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.CoolWaterIn_Pressure doubleValue]];
    self.CoolWaterOutPressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.CoolWaterOut_Pressure doubleValue]];
    self.HotpressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.HotWaterIn_Pressure doubleValue]];
    self.HotWaterOutpressureTF.text = [NSString stringWithFormat:@"%.1f", [self.basicInfo.HotWaterOut_Pressure doubleValue]];
    self.DescribeCWCHTF.text = self.basicInfo.MachRoom_Inf;
    
    self.OthersTF.text = self.basicInfo.Engineer_Score;
    
    self.Flow1chilledWaterpumpTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_PumpFlow];
    self.F1CWHeadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_PumpLift];
    self.F1CWPowerTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_Power];
    self.F1CWPcsTF.text = [NSString stringWithFormat:@"%i", [self.basicInfo.ColdWater_Num intValue]];
    self.F1CWOriginTF.text = self.basicInfo.ColdWater_Brand;

    self.Flow2chilledWaterpumpTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_PumpFlow2];
    self.F2CWHeadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_PumpLift2];
    self.F2CWPowerTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.ColdWater_Power2];
    self.F2CWPcsTF.text = [NSString stringWithFormat:@"%i", [self.basicInfo.ColdWater_Num2 intValue]];
    self.F2CWOriginTF.text = self.basicInfo.ColdWater_Brand2;
    
    self.Flow1coolingWaterpumpTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_PumpFlow];
    self.F1CoolWHeadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_PumpLift];
    self.F1CoolWPowerTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_Power];
    self.F1CoolWPcsTF.text = [NSString stringWithFormat:@"%i", [self.basicInfo.CoolWater_Num intValue]];
    self.F1CoolWOriginTF.text = self.basicInfo.CoolWater_Brand;
    
    self.Flow2coolingWaterpumpTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_PumpFlow2];
    self.F2CoolWHeadTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_PumpLift2];
    self.F2CoolWPowerTF.text = [NSString stringWithFormat:@"%@", self.basicInfo.CoolWater_Power2];
    self.F2CoolWPcsTF.text = [NSString stringWithFormat:@"%i", [self.basicInfo.CoolWater_Num2 intValue]];
    self.F2CoolWOriginTF.text = self.basicInfo.CoolWater_Brand2;
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
