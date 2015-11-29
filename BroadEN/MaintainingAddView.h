//
//  MaintainingAddView.h
//  BroadEN
//
//  Created by Seven on 15/11/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSDatePickerViewController.h"

@interface MaintainingAddView : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,HSDatePickerViewControllerDelegate>

@property (strong, nonatomic) NSString *projId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UICollectionView *otherCollectionView;
@property (weak, nonatomic) IBOutlet UIView *attachmentView;
@property (weak, nonatomic) IBOutlet UITextField *EngineerTF;
@property (weak, nonatomic) IBOutlet UITextField *UploadManTF;
@property (weak, nonatomic) IBOutlet UITextField *UploadDateTF;

@property (weak, nonatomic) IBOutlet UITextField *serviceTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *serviceItemTF;
@property (weak, nonatomic) IBOutlet UITextField *serviceDateTF;
@property (weak, nonatomic) IBOutlet UITextField *unitTF;

@end
