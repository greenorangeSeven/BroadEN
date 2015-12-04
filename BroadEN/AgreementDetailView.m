//
//  AgreementDetailView.m
//  BroadEN
//
//  Created by Seven on 15/12/4.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "AgreementDetailView.h"

@interface AgreementDetailView ()

@end

@implementation AgreementDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Agreement Mgt Message";
    
    self.CN_NameLb.text = self.agreement.CN_Name;
    self.Agt_NoLb.text = self.agreement.Agt_No;
    self.Agt_ServDeptLb.text = self.agreement.Agt_ServDept;
    self.Agt_Judm_ManLb.text = self.agreement.Agt_Judm_Man;
    self.Agt_Judm_DateLb.text = [Tool DateTimeRemoveTime:self.agreement.Agt_Judm_Date andSeparated:@" "];
    self.Agt_Std_AmtLb.text = [NSString stringWithFormat:@"%@万元", self.agreement.Agt_Std_Amt];
    self.Agt_AmtLb.text = [NSString stringWithFormat:@"%@万元", self.agreement.Agt_Amt];
    self.Agt_MemoTv.text = self.agreement.Agt_Memo;
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
