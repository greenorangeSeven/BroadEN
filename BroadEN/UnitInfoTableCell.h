//
//  UnitInfoTableCell.h
//  BroadEN
//
//  Created by Seven on 15/11/24.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitInfoTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *UnitModelLb;
@property (weak, nonatomic) IBOutlet UILabel *ProductionLb;
@property (weak, nonatomic) IBOutlet UILabel *SerialLb;
@property (weak, nonatomic) IBOutlet UILabel *DeliveryLb;

@end
