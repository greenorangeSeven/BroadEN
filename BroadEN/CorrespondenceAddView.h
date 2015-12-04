//
//  CorrespondenceAddView.h
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CorrespondenceAddView : UIViewController

@property (strong, nonatomic) NSString *projId;
@property (strong, nonatomic) NSString *PROJ_Name;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *fileView;

@property (weak, nonatomic) IBOutlet UILabel *Exec_Man_EnLb;
@property (weak, nonatomic) IBOutlet UILabel *UploadTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *FileTypeLb;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

- (IBAction)chooseFileTypeAction:(id)sender;

@end
