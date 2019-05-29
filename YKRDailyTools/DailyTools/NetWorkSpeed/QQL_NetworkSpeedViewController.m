//
//  QQL_NetworkSpeedViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_NetworkSpeedViewController.h"
#import "QQL_NetSpeedView.h"
#import "MeasurNetTools.h"
#import "QBTools.h"
#import "AFNetworking.h"
// 屏宽高

@interface QQL_NetworkSpeedViewController ()

@property (strong, nonatomic) UILabel *numberLb;
@property (strong, nonatomic) QQL_NetSpeedView *rectView;

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, assign) CGFloat lastTrans;

@end

@implementation QQL_NetworkSpeedViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"测网速";
    [self createSubviews];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(15, 35, 37, 37);
    [button setImage:[UIImage imageNamed:@"tool_fanhui_left"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    __weak typeof(self) weakself = self;
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    __weak typeof(AFNetworkReachabilityManager *) weakreachabilityManager = reachabilityManager;
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable){
            
//            [MBProgressHUD addTipWith:self.view WithTipContent:@"暂无网络"];
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"当前是移动网络，测速可能会消耗较多流量，是否继续测速" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"继续" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"返回" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }];
            [alertC addAction:alertAction1];
            [alertC addAction:alertAction];
            [self presentViewController:alertC animated:YES completion:nil];
        }
        
        [weakreachabilityManager stopMonitoring];
    }];
    
}

- (void)buttonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createSubviews
{
    
    CGFloat width = SCREEN_WIDTH-40;
    CGFloat height = SCREEN_WIDTH-40;
    CGFloat x = 20;
    CGFloat y = 80;
    _rectView = [[QQL_NetSpeedView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    [_rectView show];
    [self.view addSubview:_rectView];
    
    _numberLb = [[UILabel alloc]initWithFrame:CGRectMake(80, CGRectGetMaxY(_rectView.frame)-90, SCREEN_WIDTH-160, 45)];
    _numberLb.textAlignment = NSTextAlignmentCenter;
    _numberLb.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    _numberLb.backgroundColor = [UIColor clearColor];
    _numberLb.textColor = [UIColor whiteColor];
    [self.view addSubview:_numberLb];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(80, CGRectGetMaxY(_rectView.frame), SCREEN_WIDTH-160, 45);
    [button setBackgroundImage:[UIImage imageNamed:@"cwsanniubg"] forState:(UIControlStateNormal)];
    [button setTitle:@"测网速" forState:(UIControlStateNormal)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    UILabel *message = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_numberLb.frame)+10, SCREEN_WIDTH, 18)];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor whiteColor];
    message.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [self.view addSubview:message];
    _messageLabel = message;
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame)+15, SCREEN_WIDTH, 20)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    [self.view addSubview:label1];
    _label1 = label1;
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label1.frame)+5, SCREEN_WIDTH, 20)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    [self.view addSubview:label2];
    _label2 = label2;
    
    _lastTrans = -0.75*M_PI;
}

- (void)buttonClick:(UIButton *)button
{
    button.userInteractionEnabled = NO;
    _messageLabel.text = @"正在检测网络,请稍后";
    
    if (_lastTrans != -0.75*M_PI) {
        
        if (_lastTrans > 0) {
            [self setRectViewTrans:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setRectViewTrans:-0.75*M_PI];
                [self startNetSpeedWith:button];
            });
        }else{
            [self setRectViewTrans:-0.75*M_PI];
            [self startNetSpeedWith:button];
        }
    }else{
        [self startNetSpeedWith:button];
    }
    
}

- (void)startNetSpeedWith:(UIButton *)button
{
    [self setIp];
    MeasurNetTools * meaurNet = [[MeasurNetTools alloc] initWithblock:^(float speed) {
        
        [self setProgressWith:speed andIsLast:NO];
        
    } finishMeasureBlock:^(float speed) {
        
        [self setProgressWith:speed andIsLast:YES];
        _messageLabel.text = [NSString stringWithFormat:@"当前速度相当于%@带宽",[QBTools formatBandWidth:speed/timeCount]];
        button.userInteractionEnabled = YES;
    } failedBlock:^(NSError *error) {
        button.userInteractionEnabled = YES;
    }];
    [meaurNet startMeasur];
}

- (void)setProgressWith:(CGFloat)speed andIsLast:(BOOL)isLast
{
    speed = speed/timeCount;
    NSString* speedStr = [NSString stringWithFormat:@"%@/S", [QBTools formattedFileSize:speed]];
    _numberLb.text = speedStr;
    
    CGFloat llM = 0;;
    CGFloat llMFloat = speedStr.floatValue;
    if ([speedStr containsString:@"KB"]) {
        llM = llMFloat/1024;
    }else if ([speedStr containsString:@"M"]){
        llM = llMFloat;
    }else if ([speedStr containsString:@"bytes"]){
        llM = llMFloat/1024/1024;
    }else if([speedStr containsString:@"GB"]){
        llM = llMFloat*1024;
    }
    
    CGFloat angle = llM/(float)12 * 1.5*M_PI;
    CGFloat needAngle = angle - 0.75*M_PI;
    
    if (needAngle > 0.75*M_PI) {
        needAngle = 0.75*M_PI;
    }
    
    if (needAngle < -0.75*M_PI) {
        needAngle = -0.75*M_PI;
    }
    
    [self setRectViewTrans:needAngle];
    if (isLast) {
        _lastTrans = needAngle;
    }
}

- (void)setRectViewTrans:(CGFloat)trans
{
    _rectView.needleLayer.transform = CATransform3DMakeRotation(trans, 0, 0, 1);
}

- (void)setIp
{
    NSURL *url = [NSURL URLWithString:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:100];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError == nil) {
            
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:nil];
            
            NSDictionary *dic = dataDic[@"data"];
            
            _label1.text = [NSString stringWithFormat:@"IP: %@",dic[@"ip"]];
            
            NSString *country = dic[@"country"];
            if ([country isKindOfClass:[NSString class]] && [country isEqualToString:@"中国"]) {
                NSString *city = dic[@"city"];
                if ([city isKindOfClass:[NSString class]] && city.length > 0) {
                    country = city;
                }
            }
            
            _label2.text = [NSString stringWithFormat:@"%@%@",country,dic[@"isp"]];
            
        }
    }];
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

@end
