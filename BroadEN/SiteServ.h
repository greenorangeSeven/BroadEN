//
//  SiteServ.h
//  BroadEN
//
//  Created by Seven on 15/11/22.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiteServ : Jastor

/**
 * 自增长列
 */
@property (copy, nonatomic) NSString *ID;

@property (copy, nonatomic) NSString *PROJ_Name_En;

@property (copy, nonatomic) NSString *PROJ_Name;

@property (copy, nonatomic) NSString *OutFact_Num;

@property (copy, nonatomic) NSString *Project;
@property (copy, nonatomic) NSString *Project_En;

@property (copy, nonatomic) NSString *Type;
@property (copy, nonatomic) NSString *Type_En;
@property (copy, nonatomic) NSString *userid;

@end
