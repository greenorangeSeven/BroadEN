//
//  MaintauningDetailView.h
//  BroadEN
//
//  Created by Seven on 15/11/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintauningDetailView : UIViewController

@property (strong, nonatomic) NSString *ID;

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
@property (weak, nonatomic) IBOutlet UITextView *EngineerNoteTV;

@property (weak, nonatomic) IBOutlet UIImageView *ServiceFormIV;
@property (weak, nonatomic) IBOutlet UIImageView *SnecePhotoIV;
@property (weak, nonatomic) IBOutlet UIImageView *TouchSencePhotoIV;

@end
