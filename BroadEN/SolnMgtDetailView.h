//
//  SolnMgtDetailView.h
//  BroadEN
//
//  Created by Seven on 15/12/1.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SolnMgtDetailView : UIViewController

@property (strong, nonatomic) NSString *ID;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *PROJ_Name_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *Exec_DateLB;
@property (weak, nonatomic) IBOutlet UILabel *Exec_ManEnLB;
@property (weak, nonatomic) IBOutlet UILabel *TypeSerialLB;

@property (weak, nonatomic) IBOutlet UILabel *LiBrLB;
@property (weak, nonatomic) IBOutlet UILabel *LiBrResultLB;

@property (weak, nonatomic) IBOutlet UILabel *DensityTempLB;
@property (weak, nonatomic) IBOutlet UILabel *DensityTempResultLB;

@property (weak, nonatomic) IBOutlet UILabel *OutwardEnLB;
@property (weak, nonatomic) IBOutlet UILabel *OutwardResultLB;

@property (weak, nonatomic) IBOutlet UILabel *PHLB;
@property (weak, nonatomic) IBOutlet UILabel *PHResultLB;

@property (weak, nonatomic) IBOutlet UILabel *CU2LB;
@property (weak, nonatomic) IBOutlet UILabel *CU2ResultLB;

@property (weak, nonatomic) IBOutlet UILabel *FeLB;
@property (weak, nonatomic) IBOutlet UILabel *FeResultLB;

@property (weak, nonatomic) IBOutlet UILabel *Licro4LB;
@property (weak, nonatomic) IBOutlet UILabel *Licro4ResultLB;

@property (weak, nonatomic) IBOutlet UILabel *PrecipitationLB;
@property (weak, nonatomic) IBOutlet UILabel *PrecipitationResultLB;

@property (weak, nonatomic) IBOutlet UILabel *ClLB;
@property (weak, nonatomic) IBOutlet UILabel *ClResultLB;

@property (weak, nonatomic) IBOutlet UILabel *InspectorSignEnLB;
@property (weak, nonatomic) IBOutlet UILabel *InspectorSignDateLB;
@property (weak, nonatomic) IBOutlet UILabel *LithiumLb;

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *HandingDateTF;
@property (weak, nonatomic) IBOutlet UITextView *ExplainInfoTV;

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIView *explainView;

@end
