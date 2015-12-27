//
//  UserBasicInfoModifyFoldView.h
//  BroadEN
//
//  Created by Seven on 15/12/28.
//  Copyright © 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBasicInfo.h"

@interface UserBasicInfoModifyFoldView : UIViewController

@property (strong, nonatomic) UserBasicInfo *basicInfo;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//Name Adress
@property (weak, nonatomic) IBOutlet UIView *NameAddressView;
@property (weak, nonatomic) IBOutlet UIView *NameAddressCView;

@property (weak, nonatomic) IBOutlet UITextField *EnglishNameTF;
@property (weak, nonatomic) IBOutlet UITextField *DistributorTF;
@property (weak, nonatomic) IBOutlet UITextField *ChinesenameTF;
@property (weak, nonatomic) IBOutlet UITextField *ShortnameTF;
@property (weak, nonatomic) IBOutlet UITextField *FormernameTF;
@property (weak, nonatomic) IBOutlet UITextField *AdressTF;
@property (weak, nonatomic) IBOutlet UITextField *CountryTF;
@property (weak, nonatomic) IBOutlet UITextField *CityTF;
@property (weak, nonatomic) IBOutlet UITextField *ZipTF;
@property (weak, nonatomic) IBOutlet UITextField *FaxTF;

//Contacts
@property (weak, nonatomic) IBOutlet UIView *ContactsView;
@property (weak, nonatomic) IBOutlet UIView *ContactsCView;

@property (weak, nonatomic) IBOutlet UITextField *SLTF;
@property (weak, nonatomic) IBOutlet UITextField *SLDepartmentTF;
@property (weak, nonatomic) IBOutlet UITextField *SLDutiesTF;
@property (weak, nonatomic) IBOutlet UITextField *SLCellNoTF;
@property (weak, nonatomic) IBOutlet UITextField *SLMailTF;

@property (weak, nonatomic) IBOutlet UITextField *MLTF;
@property (weak, nonatomic) IBOutlet UITextField *MLDepartmentTF;
@property (weak, nonatomic) IBOutlet UITextField *MLDutiesTF;
@property (weak, nonatomic) IBOutlet UITextField *MLCellNoTF;
@property (weak, nonatomic) IBOutlet UITextField *MLMailTF;

@property (weak, nonatomic) IBOutlet UITextField *BLTF;
@property (weak, nonatomic) IBOutlet UITextField *BLDepartmentTF;
@property (weak, nonatomic) IBOutlet UITextField *BLDutiesTF;
@property (weak, nonatomic) IBOutlet UITextField *BLCellNoTF;
@property (weak, nonatomic) IBOutlet UITextField *BLMailTF;

//BusinessInfo
@property (weak, nonatomic) IBOutlet UIView *BusinessInfoView;
@property (weak, nonatomic) IBOutlet UIView *BusinessInfoCView;

@property (weak, nonatomic) IBOutlet UITextField *ContractNoTF;
@property (weak, nonatomic) IBOutlet UITextField *ContractmanagerTF;
@property (weak, nonatomic) IBOutlet UITextField *SigningDateTF;
@property (weak, nonatomic) IBOutlet UITextField *InvestmentcompanyTF;

//BuildingInfoZ
@property (weak, nonatomic) IBOutlet UIView *BuildingInfoView;
@property (weak, nonatomic) IBOutlet UIView *BuildingInfoCView;

@property (weak, nonatomic) IBOutlet UITextField *BuildingheightTF;
@property (weak, nonatomic) IBOutlet UITextField *NatureofindustryTF;
@property (weak, nonatomic) IBOutlet UITextField *BuildingareaTF;
@property (weak, nonatomic) IBOutlet UITextField *ApplicationsTF;
@property (weak, nonatomic) IBOutlet UITextField *TotalACareaTF;
@property (weak, nonatomic) IBOutlet UITextField *CoolingloadTF;
@property (weak, nonatomic) IBOutlet UITextField *HeatingloadTF;

//Unit Info
@property (weak, nonatomic) IBOutlet UIView *UnitInfoView;
@property (weak, nonatomic) IBOutlet UIView *UnitInfoCView;

@property (weak, nonatomic) IBOutlet UITextField *VarietiesoffuelTF;
@property (weak, nonatomic) IBOutlet UITextField *CalorificvalueTF;
@property (weak, nonatomic) IBOutlet UITextField *FuelpressureTF;
@property (weak, nonatomic) IBOutlet UITextField *RatedconsumptionTF;
@property (weak, nonatomic) IBOutlet UITextField *RuntimeperdayTF;

@property (weak, nonatomic) IBOutlet UITextField *ChilledpressureTF;
@property (weak, nonatomic) IBOutlet UITextField *ColdWaterOutPressureTF;

@property (weak, nonatomic) IBOutlet UITextField *WarmpressureTF;
@property (weak, nonatomic) IBOutlet UITextField *WarmWaterOutPressureTF;

@property (weak, nonatomic) IBOutlet UITextField *CoolingpressureTF;
@property (weak, nonatomic) IBOutlet UITextField *CoolWaterOutPressureTF;

@property (weak, nonatomic) IBOutlet UITextField *HotpressureTF;
@property (weak, nonatomic) IBOutlet UITextField *HotWaterOutpressureTF;

@property (weak, nonatomic) IBOutlet UITextView *DescribeCWCHTF;

//System Info
@property (weak, nonatomic) IBOutlet UIView *SystemInfoView;
@property (weak, nonatomic) IBOutlet UIView *SystemInfoCView;

@property (weak, nonatomic) IBOutlet UITextField *Flow1chilledWaterpumpTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CWHeadTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CWPowerTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CWPcsTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CWOriginTF;

@property (weak, nonatomic) IBOutlet UITextField *Flow2chilledWaterpumpTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CWHeadTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CWPowerTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CWPcsTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CWOriginTF;

@property (weak, nonatomic) IBOutlet UITextField *Flow1coolingWaterpumpTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CoolWHeadTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CoolWPowerTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CoolWPcsTF;
@property (weak, nonatomic) IBOutlet UITextField *F1CoolWOriginTF;

@property (weak, nonatomic) IBOutlet UITextField *Flow2coolingWaterpumpTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CoolWHeadTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CoolWPowerTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CoolWPcsTF;
@property (weak, nonatomic) IBOutlet UITextField *F2CoolWOriginTF;

@property (weak, nonatomic) IBOutlet UITextView *Sys_ElseThingTF;

//UserBackground
@property (weak, nonatomic) IBOutlet UIView *UserBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *UserBackgroundCView;

@property (weak, nonatomic) IBOutlet UITextView *OthersTF;

- (IBAction)selectCountryAction:(id)sender;

- (IBAction)NameAddressControl:(id)sender;
- (IBAction)ContactsControl:(id)sender;
- (IBAction)BussinessInfoControl:(id)sender;
- (IBAction)BuildingInfoControl:(id)sender;
- (IBAction)UnitInfoControl:(id)sender;
- (IBAction)SystemInfoControl:(id)sender;
- (IBAction)UserBackgroundControl:(id)sender;

@end
