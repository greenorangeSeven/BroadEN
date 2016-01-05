//
//  UserBasicFoldView.m
//  BroadEN
//
//  Created by Seven on 15/12/28.
//  Copyright © 2015年 greenorange. All rights reserved.
//

#import "UserBasicFoldView.h"
#import "UserBasicInfo.h"
#import "UserBasicInfoModifyFoldView.h"
#import "UserSecurity.h"

@interface UserBasicFoldView ()
{
    UIBarButtonItem *modifyBtn;
    UIBarButtonItem *saveBtn;
    UserBasicInfo *basicInfo;
    
    UserInfo *userinfo;
    NSString *jiaose;
    
    float NameAddressControlHeight;
    BOOL NameAddressIsExpand;
    
    float ContactsControlHeight;
    BOOL ContactsIsExpand;
    
    float BusinessInfoControlHeight;
    BOOL BusinessInfoIsExpand;
    
    float BuildingInfoControlHeight;
    BOOL BuildingInfoIsExpand;
    
    float UnitInfoControlHeight;
    BOOL UnitInfoIsExpand;
    
    float SystemInfoControlHeight;
    BOOL SystemInfoIsExpand;
    
    float UserBackgroundControlHeight;
    BOOL UserBackgroundIsExpand;
}

@end

@implementation UserBasicFoldView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.titleStr;
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    userinfo = app.userinfo;
    jiaose = userinfo.JiaoSe;
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
//    for (UIView *subView in [self.scrollView subviews])
//    {
//        if ([subView isKindOfClass:[UITextField class]])
//        {
//            ((UITextField *)subView).enabled = YES;
//        }
//        else
//        {
//            for (UIView *sub2View in [subView subviews])
//            {
//                if ([sub2View isKindOfClass:[UITextField class]])
//                {
//                    ((UITextField *)subView).enabled = YES;
//                }
//                else
//                {
//                    for (UIView *sub3View in [sub2View subviews])
//                    {
//                        if ([sub3View isKindOfClass:[UITextField class]])
//                        {
//                            ((UITextField *)subView).enabled = NO;
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReload) name:@"Notification_UserBasicInfoReLoad" object:nil];
    
    [self getSecurity];
    [self getData];
    
    NameAddressIsExpand = YES;
    ContactsIsExpand = YES;
    BusinessInfoIsExpand = YES;
    BuildingInfoIsExpand = YES;
    UnitInfoIsExpand = YES;
    SystemInfoIsExpand = YES;
    UserBackgroundIsExpand = YES;
    
    NameAddressControlHeight = self.NameAddressView.frame.size.height - ITEM_HEADER_HEIGHT;
    ContactsControlHeight = self.ContactsView.frame.size.height - ITEM_HEADER_HEIGHT;
    BusinessInfoControlHeight = self.BusinessInfoView.frame.size.height - ITEM_HEADER_HEIGHT;
    BuildingInfoControlHeight = self.BuildingInfoView.frame.size.height - ITEM_HEADER_HEIGHT;
    UnitInfoControlHeight = self.UnitInfoView.frame.size.height - ITEM_HEADER_HEIGHT;
    SystemInfoControlHeight = self.SystemInfoView.frame.size.height - ITEM_HEADER_HEIGHT;
    UserBackgroundControlHeight = self.UserBackgroundView.frame.size.height - ITEM_HEADER_HEIGHT;
}

- (void)dataReload
{
    [self getData];
}

- (void)getSecurity
{
    //%%为转义%
    NSString *sqlStr = [NSString stringWithFormat:@"Sp_GetPermissionByRoleNameInModuleLike_En '%@','DA01%%'", userinfo.JiaoSe];
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
    [Tool showHUD:@"Loading..." andView:self.view andHUD:request.hud];
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
            if ([s.ModuleCode isEqualToString:@"DA01"] && [s.PermissionName isEqualToString:@"修改"]) {
                modifyBtn = [[UIBarButtonItem alloc] initWithTitle: @"Modify" style:UIBarButtonItemStyleBordered target:self action:@selector(modifyAction:)];
                self.navigationItem.rightBarButtonItem = modifyBtn;
                break;
            }
        }
    };
    [utils stringFromparserXML:request.responseString target:@"string"];
}

- (void)modifyAction:(id)sender
{
    UserBasicInfoModifyFoldView *basicInfoModifyView = [[UserBasicInfoModifyFoldView alloc] init];
    basicInfoModifyView.basicInfo = basicInfo;
    basicInfoModifyView.title = self.titleStr;
    [self.navigationController pushViewController:basicInfoModifyView animated:YES];
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
    [Tool showHUD:@"Loading..." andView:self.view andHUD:request.hud];
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
    basicInfo.yhcym = [basicInfo.yhcym stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
    
    self.EnglishNameTF.text = basicInfo.PROJ_Name_En;
    self.DistributorTF.text = basicInfo.Franchiser;
    self.ChinesenameTF.text = basicInfo.PROJ_Name;
    self.ShortnameTF.text = basicInfo.CustShortName_CN;
    self.FormernameTF.text = basicInfo.yhcym;
    self.UserCodeTF.text = basicInfo.CUST_Code;
    self.AdressTF.text = basicInfo.PostalAdd_CN;
    self.CountryTF.text = basicInfo.Country_EN;
    self.CityTF.text = basicInfo.City_CN;
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
    self.ChilledpressureTF.text = [NSString stringWithFormat:@"%.2f/%.2fMPa", [basicInfo.ColdWaterIn_Pressure doubleValue], [basicInfo.ColdWaterOut_Pressure doubleValue]];
    self.WarmpressureTF.text = [NSString stringWithFormat:@"%.2f/%.2fMPa", [basicInfo.WarmWaterIn_Pressure doubleValue], [basicInfo.WarmWaterOut_Pressure doubleValue]];
    self.CoolingpressureTF.text = [NSString stringWithFormat:@"%.2f/%.2fMPa", [basicInfo.CoolWaterIn_Pressure doubleValue], [basicInfo.CoolWaterOut_Pressure doubleValue]];
    self.HotpressureTF.text = [NSString stringWithFormat:@"%.2f/%.2fMPa", [basicInfo.HotWaterIn_Pressure doubleValue], [basicInfo.HotWaterOut_Pressure doubleValue]];
    self.DescribeCWCHTF.text = basicInfo.MachRoom_Inf;
    
    self.OthersTF.text = basicInfo.Engineer_Score;
    
    self.Flow1chilledWaterpumpTF.text = [NSString stringWithFormat:@"%dm³", [basicInfo.ColdWater_PumpFlow intValue]];
    self.F1CWHeadTF.text = [NSString stringWithFormat:@"%dm", [basicInfo.ColdWater_PumpLift intValue]];
    self.F1CWPowerTF.text = [NSString stringWithFormat:@"%.1fkw", [basicInfo.ColdWater_Power doubleValue]];
    self.F1CWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.ColdWater_Num intValue]];
    self.F1CWOriginTF.text = basicInfo.ColdWater_Brand;
    
    self.Flow2chilledWaterpumpTF.text = [NSString stringWithFormat:@"%dm³", [basicInfo.ColdWater_PumpFlow2 intValue]];
    self.F2CWHeadTF.text = [NSString stringWithFormat:@"%dm", [basicInfo.ColdWater_PumpLift2 intValue]];
    self.F2CWPowerTF.text = [NSString stringWithFormat:@"%.1fkw", [basicInfo.ColdWater_Power2 doubleValue]];
    self.F2CWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.ColdWater_Num2 intValue]];
    self.F2CWOriginTF.text = basicInfo.ColdWater_Brand2;
    
    self.Flow1coolingWaterpumpTF.text = [NSString stringWithFormat:@"%dm³", [basicInfo.CoolWater_PumpFlow intValue]];
    self.F1CoolWHeadTF.text = [NSString stringWithFormat:@"%dm", [basicInfo.CoolWater_PumpFlow intValue]];
    self.F1CoolWPowerTF.text = [NSString stringWithFormat:@"%.1fkw", [basicInfo.CoolWater_Power doubleValue]];
    self.F1CoolWPcsTF.text = [NSString stringWithFormat:@"%i", [basicInfo.CoolWater_Num intValue]];
    self.F1CoolWOriginTF.text = basicInfo.CoolWater_Brand;
    
    self.Flow2coolingWaterpumpTF.text = [NSString stringWithFormat:@"%dm³", [basicInfo.CoolWater_PumpFlow2 intValue]];
    self.F2CoolWHeadTF.text = [NSString stringWithFormat:@"%dm", [basicInfo.CoolWater_PumpFlow2 intValue]];
    self.F2CoolWPowerTF.text = [NSString stringWithFormat:@"%.1fkw", [basicInfo.CoolWater_Power2 doubleValue]];
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

- (IBAction)NameAddressControl:(id)sender {
    NameAddressIsExpand = !NameAddressIsExpand;
    
    if(NameAddressIsExpand)
    {
        self.NameAddressCView.hidden = NO;
        [self.NameAddressStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect NameAddressFrame = self.NameAddressView.frame;
        NameAddressFrame.size.height = ITEM_HEADER_HEIGHT + NameAddressControlHeight;
        self.NameAddressView.frame = NameAddressFrame;
        
        CGRect ContactsFrame = self.ContactsView.frame;
        ContactsFrame.origin.y = ContactsFrame.origin.y + NameAddressControlHeight;
        self.ContactsView.frame = ContactsFrame;
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.origin.y = BusinessInfoFrame.origin.y + NameAddressControlHeight;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y + NameAddressControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y + NameAddressControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y + NameAddressControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + NameAddressControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.NameAddressCView.hidden = YES;
        [self.NameAddressStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect NameAddressFrame = self.NameAddressView.frame;
        NameAddressFrame.size.height = ITEM_HEADER_HEIGHT;
        self.NameAddressView.frame = NameAddressFrame;
        
        CGRect ContactsFrame = self.ContactsView.frame;
        ContactsFrame.origin.y = ContactsFrame.origin.y - NameAddressControlHeight;
        self.ContactsView.frame = ContactsFrame;
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.origin.y = BusinessInfoFrame.origin.y - NameAddressControlHeight;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y - NameAddressControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y - NameAddressControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y - NameAddressControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - NameAddressControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)ContactsControl:(id)sender {
    ContactsIsExpand = !ContactsIsExpand;
    
    if(ContactsIsExpand)
    {
        self.ContactsCView.hidden = NO;
        [self.ContactsStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect ContactsFrame = self.ContactsView.frame;
        ContactsFrame.size.height = ITEM_HEADER_HEIGHT + ContactsControlHeight;
        self.ContactsView.frame = ContactsFrame;
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.origin.y = BusinessInfoFrame.origin.y + ContactsControlHeight;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y + ContactsControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y + ContactsControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y + ContactsControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + ContactsControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.ContactsCView.hidden = YES;
        [self.ContactsStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect ContactsFrame = self.ContactsView.frame;
        ContactsFrame.size.height = ITEM_HEADER_HEIGHT;
        self.ContactsView.frame = ContactsFrame;
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.origin.y = BusinessInfoFrame.origin.y - ContactsControlHeight;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y - ContactsControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y - ContactsControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y - ContactsControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - ContactsControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)BussinessInfoControl:(id)sender {
    BusinessInfoIsExpand = !BusinessInfoIsExpand;
    
    if(BusinessInfoIsExpand)
    {
        self.BusinessInfoCView.hidden = NO;
        [self.BusinessInfoStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.size.height = ITEM_HEADER_HEIGHT + BusinessInfoControlHeight;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y + BusinessInfoControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y + BusinessInfoControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y + BusinessInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + BusinessInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.BusinessInfoCView.hidden = YES;
        [self.BusinessInfoStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect BusinessInfoFrame = self.BusinessInfoView.frame;
        BusinessInfoFrame.size.height = ITEM_HEADER_HEIGHT;
        self.BusinessInfoView.frame = BusinessInfoFrame;
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.origin.y = BuildingInfoFrame.origin.y - BusinessInfoControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y - BusinessInfoControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y - BusinessInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - BusinessInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)BuildingInfoControl:(id)sender {
    BuildingInfoIsExpand = !BuildingInfoIsExpand;
    
    if(BuildingInfoIsExpand)
    {
        self.BuildingInfoCView.hidden = NO;
        [self.BuildingInfoStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.size.height = ITEM_HEADER_HEIGHT + BuildingInfoControlHeight;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y + BuildingInfoControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y + BuildingInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + BuildingInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.BuildingInfoCView.hidden = YES;
        [self.BuildingInfoStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect BuildingInfoFrame = self.BuildingInfoView.frame;
        BuildingInfoFrame.size.height =  ITEM_HEADER_HEIGHT;
        self.BuildingInfoView.frame = BuildingInfoFrame;
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.origin.y = UnitInfoFrame.origin.y - BuildingInfoControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y - BuildingInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - BuildingInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)UnitInfoControl:(id)sender {
    UnitInfoIsExpand = !UnitInfoIsExpand;
    
    if(UnitInfoIsExpand)
    {
        self.UnitInfoCView.hidden = NO;
        [self.UnitInfoStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.size.height = ITEM_HEADER_HEIGHT + UnitInfoControlHeight;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y + UnitInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + UnitInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.UnitInfoCView.hidden = YES;
        [self.UnitInfoStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect UnitInfoFrame = self.UnitInfoView.frame;
        UnitInfoFrame.size.height =  ITEM_HEADER_HEIGHT;
        self.UnitInfoView.frame = UnitInfoFrame;
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.origin.y = SystemInfoFrame.origin.y - UnitInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - UnitInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)SystemInfoControl:(id)sender {
    SystemInfoIsExpand = !SystemInfoIsExpand;
    
    if(SystemInfoIsExpand)
    {
        self.SystemInfoCView.hidden = NO;
        [self.SystemInfoStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.size.height = ITEM_HEADER_HEIGHT + SystemInfoControlHeight;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y + SystemInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.SystemInfoCView.hidden = YES;
        [self.SystemInfoStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect SystemInfoFrame = self.SystemInfoView.frame;
        SystemInfoFrame.size.height =  ITEM_HEADER_HEIGHT;
        self.SystemInfoView.frame = SystemInfoFrame;
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.origin.y = UserBackgroundFrame.origin.y - SystemInfoControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

- (IBAction)UserBackgroundControl:(id)sender {
    UserBackgroundIsExpand = !UserBackgroundIsExpand;
    
    if(UserBackgroundIsExpand)
    {
        self.UserBackgroundCView.hidden = NO;
        [self.UserBackgroundStateIv setImage:[UIImage imageNamed:@"expand"]];
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.size.height = ITEM_HEADER_HEIGHT + UserBackgroundControlHeight;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    else
    {
        self.UserBackgroundCView.hidden = YES;
        [self.UserBackgroundStateIv setImage:[UIImage imageNamed:@"fold"]];
        
        CGRect UserBackgroundFrame = self.UserBackgroundView.frame;
        UserBackgroundFrame.size.height = ITEM_HEADER_HEIGHT;
        self.UserBackgroundView.frame = UserBackgroundFrame;
    }
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.UserBackgroundView.frame.origin.y + self.UserBackgroundView.frame.size.height);
}

@end
