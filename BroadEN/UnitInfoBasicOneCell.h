//
//  UnitInfoBasicOneCell.h
//  BroadEN
//
//  Created by Seven on 15/11/26.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitInfoBasicOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Prod_NumLB;
@property (weak, nonatomic) IBOutlet UILabel *OutFact_NumLB;
@property (weak, nonatomic) IBOutlet UILabel *AirCondUnit_ModeLB;
@property (weak, nonatomic) IBOutlet UILabel *AirCondUnit_ConfigLB;
@property (weak, nonatomic) IBOutlet UILabel *AirCondUnit_State_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *KeepFix_SignENLB;
@property (weak, nonatomic) IBOutlet UILabel *KeepFix_DateLB;
@property (weak, nonatomic) IBOutlet UILabel *bzbxLB;

@end
