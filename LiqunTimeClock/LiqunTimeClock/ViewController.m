//
//  ViewController.m
//  LiqunTimeClock
//
//  Created by HF on 2019/1/10.
//  Copyright © 2019年 HF. All rights reserved.
//

#import "ViewController.h"
#import "HomeTimeVC.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
    [btn setTitle:@"点我" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction:(id)sender
{
    HomeTimeVC *vc = [HomeTimeVC new];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
