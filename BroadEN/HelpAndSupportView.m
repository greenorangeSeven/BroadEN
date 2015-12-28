//
//  HelpAndSupportView.m
//  BroadEN
//
//  Created by Seven on 15/12/10.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "HelpAndSupportView.h"

@interface HelpAndSupportView ()
{
    UIWebView *phoneCallWebView;
}

@end

@implementation HelpAndSupportView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Help and Support";
    
    self.versionInfoLb.text = [NSString stringWithFormat:@"Version :%@", AppVersion];
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

- (IBAction)telAction:(id)sender {
    NSURL *phoneURL = [NSURL URLWithString:@"tel:+86-731-84086265"];
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
}

- (IBAction)mailAction:(id)sender {
    NSURL *mailURL = [NSURL URLWithString:@"mailto://international@broad.net"];
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:mailURL]];
}

- (IBAction)webActon:(id)sender {
}
@end
