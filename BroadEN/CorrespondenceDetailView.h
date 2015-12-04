//
//  CorrespondenceDetailView.h
//  BroadEN
//
//  Created by Seven on 15/12/3.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CorrespondenceDetailView : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) NSString *ID;

@property (weak, nonatomic) IBOutlet UILabel *PROJ_Name_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *Uploader_EnLB;
@property (weak, nonatomic) IBOutlet UILabel *UploadTimeLB;
@property (weak, nonatomic) IBOutlet UILabel *TypeEnLB;

@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

@end
