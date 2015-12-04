//
//  Correspondence.h
//  BroadEN
//
//  Created by Seven on 15/12/2.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Correspondence : Jastor

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *Uploader_En;
@property (copy, nonatomic) NSString *UploadTime;
@property (copy, nonatomic) NSString *FileTypeEn;

@property (copy, nonatomic) NSString *PROJ_ID;
@property (copy, nonatomic) NSString *PROJ_Name;
@property (copy, nonatomic) NSString *PROJ_Name_En;
@property (copy, nonatomic) NSString *Exec_Man_En;
@property (copy, nonatomic) NSString *Exec_Date;
@property (copy, nonatomic) NSString *CUST_Name_CN;
@property (copy, nonatomic) NSString *FileType;
@property (copy, nonatomic) NSString *allfilename;
@property (copy, nonatomic) NSString *TypeEn;

@end
