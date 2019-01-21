//
//  HomeTimeVC.m
//  LiqunTimeClock
//
//  Created by HF on 2019/1/10.
//  Copyright © 2019年 HF. All rights reserved.
//

#import "HomeTimeVC.h"
#import "HFTimeWeakTarget.h"
#import "UIView+HFFrame.h"
#import "Masonry.h"

@interface HomeTimeVC () <CAAnimationDelegate>

/// 时钟
@property (nonatomic, strong) UIImageView *clockImageV;
/// 时针
@property (nonatomic, strong) UIImageView *hourHandImageV;
/// 分针
@property (nonatomic, strong) UIImageView *minuteHandImageV;
/// 秒针
@property (nonatomic, strong) UIImageView *secondHandImageV;
//
@property (nonatomic, assign) BOOL isContinuous;
@property (nonatomic, assign) BOOL isWanderSecond;//是否是游走扫秒
@property (nonatomic, assign) CGFloat secondAngel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HomeTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"表盘时钟";
    [self configSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //start the clock at current time
    [self addTimeTarget];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //stop the clock
    [self.timer invalidate];
    self.timer = nil;
}


#pragma mark - event

#pragma mark -- 是否启用游走i秒针
- (void)switchAcion:(UISwitch *)switchBtn
{
    self.isWanderSecond = switchBtn.isOn;
    self.secondHandImageV.layer.transform = CATransform3DMakeRotation (self.secondAngel, 0, 0, 1);
}

#pragma mark -- 定时任务
- (void)tick {
    // NSCalendarIdentifierGregorian : 指定日历的算法
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // NSDateComponents封装了日期的组件,年月日时分秒等(个人感觉像是平时用的model模型)
    // 调用NSCalendar的components:fromDate:方法返回一个NSDateComponents对象
    // 需要的参数分别components:所需要的日期单位 date:目标月份的date对象
    // NSUInteger units = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;//所需要日期单位
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    //时钟偏转角度
    CGFloat hoursAngle = (components.hour / 12.0) * M_PI * 2.0;
    //分钟偏转角度
    CGFloat minsAngle = (components.minute / 60.0) * M_PI * 2.0;
    //秒钟旋转角度
    CGFloat secsAngle = (components.second / 60.0) * M_PI * 2.0;
    CGFloat prevSecAngle = ((components.second - 1) / 60.0) * M_PI * 2.0;
    
    self.secondAngel = secsAngle ;
    
    if (self.isWanderSecond) {
        //提前存储秒针layer的初始位置
        [self.secondHandImageV.layer removeAnimationForKey:@"transform"];
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        ani.duration = 1.f;
         ani .removedOnCompletion= NO;
        ani.delegate = self;
        ani.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(prevSecAngle , 0, 0, 1)];
      
        ani.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(secsAngle , 0, 0, 1)];
        [self.secondHandImageV.layer addAnimation:ani forKey:@"transform"];
    } else {
        [self.secondHandImageV.layer removeAnimationForKey:@"transform"];
        self.secondHandImageV.layer.transform = CATransform3DMakeRotation (secsAngle, 0, 0, 1);
        //self.secondHandImageV.transform = CGAffineTransformMakeRotation(secsAngle);
    }
    //
    if (self.isWanderSecond && self.isContinuous) {
        [UIView animateWithDuration:1.0 animations:^{
            self.hourHandImageV.transform = CGAffineTransformMakeRotation(hoursAngle);
            self.minuteHandImageV.transform = CGAffineTransformMakeRotation(minsAngle);
        }];
    } else {
        self.isContinuous = YES;
        self.hourHandImageV.transform = CGAffineTransformMakeRotation(hoursAngle);
        self.minuteHandImageV.transform = CGAffineTransformMakeRotation(minsAngle);
    }
    
}

#pragma mark -CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    //防止layer动画闪动
    self.secondHandImageV.layer.transform = CATransform3DMakeRotation (self.secondAngel, 0, 0, 1);
    //NSLog(@"animationDidStart%@",self.secondHandImageV.layer.animationKeys);
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //防止layer动画闪动
    self.secondHandImageV.layer.transform = CATransform3DMakeRotation (self.secondAngel, 0, 0, 1);
    //NSLog(@"animationDidStop%@",self.secondHandImageV.layer.animationKeys);
}
    
 

#pragma mark - private

- (void)configSubviews
{
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    mySwitch.onTintColor = [UIColor blackColor];
    mySwitch.top = 100;
    mySwitch.centerX = self.view.centerX;
    [self.view addSubview:mySwitch];
    [mySwitch addTarget:self action:@selector(switchAcion:) forControlEvents:UIControlEventTouchUpInside];
    [mySwitch setOn:YES];
    self.isWanderSecond =YES;
    //
    [self.view addSubview:self.clockImageV];
    [self.clockImageV addSubview:self.hourHandImageV];
    [self.clockImageV addSubview:self.minuteHandImageV];
    [self.clockImageV addSubview:self.secondHandImageV];
    //
    self.clockImageV.image = [UIImage imageNamed:@"clockBack.jpg"];
    self.hourHandImageV.image = [UIImage imageNamed:@"hourhand"];
    self.minuteHandImageV.image = [UIImage imageNamed:@"minutehand"];
    self.secondHandImageV.image = [UIImage imageNamed:@"secondhand"];
    self.clockImageV.backgroundColor = [UIColor yellowColor];
    // 设置位置
    CGFloat  clockBackWidth = 300;
    CGFloat  clockWidth = clockBackWidth - 30;
    //
    [self.clockImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(clockBackWidth));
        make.center.equalTo(self.view);
    }];
    self.hourHandImageV.frame = CGRectMake(0, 0, 8, clockWidth / 2 - 50);
    self.minuteHandImageV.frame = CGRectMake(0, 0 , 5, clockWidth / 2 - 35);
    self.secondHandImageV.frame = CGRectMake(0, 0,2, clockWidth / 2 - 25);
    //
    self.hourHandImageV.left = (clockBackWidth - self.hourHandImageV.width)/2;
    self.hourHandImageV.top =   (clockBackWidth - self.hourHandImageV.height)/2;
    //
    self.minuteHandImageV.left = (clockBackWidth - self.minuteHandImageV.width)/2;
    self.minuteHandImageV.top = (clockBackWidth - self.minuteHandImageV.height) / 2 ;
    //
    self.secondHandImageV.left = (clockBackWidth - self.secondHandImageV.width)/2;
    self.secondHandImageV.top = (clockBackWidth - self.secondHandImageV.height) / 2;
    // 调整位置
    self.hourHandImageV.layer.anchorPoint = CGPointMake(0.5f,  0.9f);
    self.minuteHandImageV.layer.anchorPoint = CGPointMake(0.5f,  0.9f);
    self.secondHandImageV.layer.anchorPoint = CGPointMake(0.5f,  0.9f);
}

- (void)addTimeTarget
{
    // 添加定时任务
    self.timer = [HFTimeWeakTarget scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:@{} repeats:YES];
    [self tick];
}

#pragma mark - getter setter

- (UIImageView *)clockImageV {
    if (_clockImageV == nil) {
        _clockImageV = [[UIImageView alloc] init];
    }
    return _clockImageV;
}

- (UIImageView *)hourHandImageV {
    if (_hourHandImageV == nil) {
        _hourHandImageV = [[UIImageView alloc] init];
        _hourHandImageV.backgroundColor = [UIColor whiteColor];
    }
    return _hourHandImageV;
}

- (UIImageView *)minuteHandImageV {
    if (_minuteHandImageV == nil) {
        _minuteHandImageV = [[UIImageView alloc] init];
        _minuteHandImageV.backgroundColor = [UIColor whiteColor];
    }
    return _minuteHandImageV;
}

- (UIImageView *)secondHandImageV {
    if (_secondHandImageV == nil) {
        _secondHandImageV = [[UIImageView alloc] init];
        _secondHandImageV.backgroundColor = [UIColor whiteColor];
    }
    return _secondHandImageV;
}


@end
