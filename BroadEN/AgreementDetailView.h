//
//  AgreementDetailView.h
//  BroadEN
//
//  Created by Seven on 15/12/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agreement.h"

@interface AgreementDetailView : UIViewController

@property (strong, nonatomic) Agreement *agreement;

@property (weak, nonatomic) IBOutlet UILabel *CN_NameLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_NoLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_ServDeptLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_Judm_ManLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_Judm_DateLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_Std_AmtLb;
@property (weak, nonatomic) IBOutlet UILabel *Agt_AmtLb;
@property (weak, nonatomic) IBOutlet UITextView *Agt_MemoTv;

@end
