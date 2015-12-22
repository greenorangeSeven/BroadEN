//
//  FlowRecordItem.h
//  BroadEN
//
//  Created by Seven on 15/12/18.
//  Copyright © 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlowRecordItem : Jastor

@property (copy, nonatomic) NSString *StepName;
@property (copy, nonatomic) NSString *OwnerUserName;
@property (copy, nonatomic) NSString *OwnerUserNameEn;
@property (copy, nonatomic) NSString *ActionName;
@property (copy, nonatomic) NSString *Data;

@end