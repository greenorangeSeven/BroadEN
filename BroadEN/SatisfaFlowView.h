//
//  SatisfaFlowView.h
//  BroadEN
//
//  Created by Seven on 15/12/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SatisfaFlowView : UIViewController

@property (strong, nonatomic) NSString *Mark;
@property BOOL isQuery;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *PROJ_Name_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *Engineer_Sign_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *Follow_Name_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *Follow_DateLB;

@property (weak, nonatomic) IBOutlet UILabel *Run_ReliabilityLB;
@property (weak, nonatomic) IBOutlet UILabel *Handle_easeLB;
@property (weak, nonatomic) IBOutlet UILabel *Run_resultLB;
@property (weak, nonatomic) IBOutlet UILabel *Prod_OverallMeritLB;
@property (weak, nonatomic) IBOutlet UILabel *Save_EnergyLB;

@property (weak, nonatomic) IBOutlet UILabel *Serv_NormalizationLB;
@property (weak, nonatomic) IBOutlet UILabel *Locale_GuideLB;
@property (weak, nonatomic) IBOutlet UILabel *Serv_AtitudeLB;
@property (weak, nonatomic) IBOutlet UILabel *Serv_TimelinesLB;
@property (weak, nonatomic) IBOutlet UILabel *Serv_Tech_LevelLB;
@property (weak, nonatomic) IBOutlet UILabel *Serv_OverallMeritLB;

@property (weak, nonatomic) IBOutlet UITextView *CUST_SugstTV;

//流程二步View
@property (weak, nonatomic) IBOutlet UIView *UserHQ_SugstView;
@property (weak, nonatomic) IBOutlet UITextView *UserHQ_SugstTV;
@property (weak, nonatomic) IBOutlet UILabel *UserHQ_Sign_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *UserHQ_SignDateLB;

//流程三步View
@property (weak, nonatomic) IBOutlet UIView *ServiceBranchView;
@property (weak, nonatomic) IBOutlet UITextView *Serv_Dept_SugstTV;
@property (weak, nonatomic) IBOutlet UILabel *Serv_Dept_SignLB;
@property (weak, nonatomic) IBOutlet UILabel *Serv_Dept_SignDateLB;

//流程四步View
@property (weak, nonatomic) IBOutlet UIView *EngineerView;
@property (weak, nonatomic) IBOutlet UIView *EngineerBottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *Engineer_SugstTV;
@property (weak, nonatomic) IBOutlet UILabel *Engineer_SignLB;
@property (weak, nonatomic) IBOutlet UILabel *Engineer_SignDateLB;

//流程五步View
@property (weak, nonatomic) IBOutlet UIView *UserHQConfirmOpinionView;
@property (weak, nonatomic) IBOutlet UITextView *UserHQ_ConfirmTV;
@property (weak, nonatomic) IBOutlet UILabel *UserHQ_Confirm_SignLB;
@property (weak, nonatomic) IBOutlet UILabel *UserHQ_Confirm_SignDateLB;

- (IBAction)checkFlowRecord:(id)sender;

@end
