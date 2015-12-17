//
//  UserBasicInfo.h
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBasicInfo : Jastor

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *PROJ_Name_En;
@property (copy, nonatomic) NSString *PROJ_Name;
@property (copy, nonatomic) NSString *CustShortName_CN;
@property (copy, nonatomic) NSString *Duty_PassEngineer_En;
@property (copy, nonatomic) NSString *PostalAdd_EN;
@property (copy, nonatomic) NSString *Country_EN;
@property (copy, nonatomic) NSString *City_EN;
@property (copy, nonatomic) NSString *Zip_Cd;
@property (copy, nonatomic) NSString *Fax;

@property (copy, nonatomic) NSString *Franchiser;
@property (copy, nonatomic) NSString *Mgmt_High;
@property (copy, nonatomic) NSString *Mgmt_High_Dept;
@property (copy, nonatomic) NSString *Mgmt_High_Pos;
@property (copy, nonatomic) NSString *Mgmt_High_Tel;
@property (copy, nonatomic) NSString *Mgmt_High_EMail;

@property (copy, nonatomic) NSString *Mgmt_Midd;
@property (copy, nonatomic) NSString *DeptMgmt_Midd_Pos;
@property (copy, nonatomic) NSString *DeptMgmt_Midd;
@property (copy, nonatomic) NSString *DeptMgmt_Midd_Tel;
@property (copy, nonatomic) NSString *DeptMgmt_Midd_EMail;

@property (copy, nonatomic) NSString *Mgmt_MachRoom;
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Dept;
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Email;
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Tel;
@property (copy, nonatomic) NSString *Mgmt_MachRoom_Pos;

@property (copy, nonatomic) NSString *CONTRACT_No;
@property (copy, nonatomic) NSString *Con_Manager;
@property (copy, nonatomic) NSString *ConJudm_Date;
@property (copy, nonatomic) NSString *Invest_Unit;
@property (copy, nonatomic) NSString *Building_Height;
@property (copy, nonatomic) NSString *Building_Area;
@property (copy, nonatomic) NSString *AirCond_Area;
@property (copy, nonatomic) NSString *Cust_Habitude;
@property (copy, nonatomic) NSString *Building_Usage;
@property (copy, nonatomic) NSString *Load_Refg;
@property (copy, nonatomic) NSString *Load_Heating;
@property (copy, nonatomic) NSString *FuelType;
@property (copy, nonatomic) NSString *Heat_Value;
@property (copy, nonatomic) NSString *Pressure;
@property (copy, nonatomic) NSString *RatingFuel_Num;
@property (copy, nonatomic) NSString *Day_RunTime;
@property (copy, nonatomic) NSString *ColdWaterIn_Pressure;
@property (copy, nonatomic) NSString *WarmWaterIn_Pressure;
@property (copy, nonatomic) NSString *CoolWaterIn_Pressure;
@property (copy, nonatomic) NSString *HotWaterIn_Pressure;
@property (copy, nonatomic) NSString *ColdWaterOut_Pressure;
@property (copy, nonatomic) NSString *WarmWaterOut_Pressure;
@property (copy, nonatomic) NSString *CoolWaterOut_Pressure;
@property (copy, nonatomic) NSString *HotWaterOut_Pressure;

@property (copy, nonatomic) NSString *ColdWater_PumpFlow;
@property (copy, nonatomic) NSString *ColdWater_PumpLift;
@property (copy, nonatomic) NSString *ColdWater_Brand;
@property (copy, nonatomic) NSString *ColdWater_Num;
@property (copy, nonatomic) NSString *ColdWater_Power;

@property (copy, nonatomic) NSString *ColdWater_PumpFlow2;
@property (copy, nonatomic) NSString *ColdWater_PumpLift2;
@property (copy, nonatomic) NSString *ColdWater_Brand2;
@property (copy, nonatomic) NSString *ColdWater_Num2;
@property (copy, nonatomic) NSString *ColdWater_Power2;

@property (copy, nonatomic) NSString *CoolWater_PumpFlow;
@property (copy, nonatomic) NSString *CoolWater_PumpLift;
@property (copy, nonatomic) NSString *CoolWater_Brand;
@property (copy, nonatomic) NSString *CoolWater_Num;
@property (copy, nonatomic) NSString *CoolWater_Power;

@property (copy, nonatomic) NSString *CoolWater_PumpFlow2;
@property (copy, nonatomic) NSString *CoolWater_PumpLift2;
@property (copy, nonatomic) NSString *CoolWater_Brand2;
@property (copy, nonatomic) NSString *CoolWater_Num2;
@property (copy, nonatomic) NSString *CoolWater_Power2;

@property (copy, nonatomic) NSString *MachRoom_Inf;
@property (copy, nonatomic) NSString *Engineer_Score;

@property (copy, nonatomic) NSString *Sys_ElseThing;

@end
