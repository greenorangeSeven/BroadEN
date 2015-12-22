//
//  FlowRecordCell.h
//  BroadEN
//
//  Created by Seven on 15/12/18.
//  Copyright © 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlowRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numLb;
@property (weak, nonatomic) IBOutlet UILabel *topLineLb;
@property (weak, nonatomic) IBOutlet UILabel *bottomLineLb;

@property (weak, nonatomic) IBOutlet UILabel *StepNameLb;
@property (weak, nonatomic) IBOutlet UILabel *OwnerUserNameLb;
@property (weak, nonatomic) IBOutlet UILabel *ActionNameLb;
@property (weak, nonatomic) IBOutlet UILabel *DataLb;

@end
