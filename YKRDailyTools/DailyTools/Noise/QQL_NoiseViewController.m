//
//  QQL_NoiseViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_NoiseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DrawRectView.h"

@interface QQL_NoiseViewController ()

@property (strong, nonatomic) UILabel *numberLb;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) NSTimer *levelTimer;
@property (strong, nonatomic) DrawRectView *rectView;

@end

@implementation QQL_NoiseViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_levelTimer && [_levelTimer isValid]) {
        
        [_levelTimer invalidate];
        _levelTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"噪音测试";
    self.view.backgroundColor = UICOLORFROMRGB(0x0063b0);
    [self createSubviews];
    
    [self testVoice];
    
}

- (void)testVoice{
    
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (_recorder)
    {
        [_recorder prepareToRecord];
        //是否启用音频测量
        _recorder.meteringEnabled = YES;
        //开始录音
        [_recorder record];
        _levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    else
    {
        NSLog(@"%@", [error description]);
    }
}

- (void)levelTimerCallback:(NSTimer *)timer {
    
    [_recorder updateMeters];
    
    //最终获取的值 0~1之间
    float level;
    
    //最小分贝 -80 去除分贝过小的声音
    float minDecibels = -80.0f;
    
    //获取通道0的分贝
    float decibels = [_recorder averagePowerForChannel:0];
    
    if (decibels < minDecibels){
        //控制最小值 0
        level = 0.0f;
    }else if (decibels >= 0.0f){
        //控制最大值 1
        level = 1.0f;
    }else{
        
        level =(1 - decibels/(float)minDecibels);
    }
    
    //扩大范围 0~1 -> 0~110
    CGFloat theVal = level * 110;
    [_numberLb setText:[NSString stringWithFormat:@"%.0f",theVal]];
    [_numberLb setAttributedText:[self changeLabelWithText:[NSString stringWithFormat:@"%.0fdb",theVal]]];
    
    CGFloat angle = theVal/(float)110 * 1.5*M_PI;
    CGFloat needAngle = angle - 0.75*M_PI;
    
    _rectView.needleLayer.transform = CATransform3DMakeRotation(needAngle, 0, 0, 1);
}

- (void)createSubviews
{
    CGFloat imgHeight = SCREEN_WIDTH*604/375.f;
    UIImageView *baseImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-imgHeight, SCREEN_WIDTH, imgHeight)];
    baseImgV.image = [UIImage imageNamed:@"cezao-bg"];
    [self.view addSubview:baseImgV];
    //288.5的宽度是相对屏幕288.5+86的宽度
    CGFloat width = 288.5*SCREEN_WIDTH/(288.5+86);
    CGFloat height = 248.5*SCREEN_WIDTH/(288.5+86);
    CGFloat x = (SCREEN_WIDTH - width)/2.f;
    CGFloat y = 30;
    _rectView = [[DrawRectView alloc]initWithFrame:CGRectMake(x, y+kStatesNavHeight, width, height)];
    [_rectView show];
    [self.view addSubview:_rectView];
    
    _numberLb = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_rectView.frame)-30, SCREEN_WIDTH, 45)];
    _numberLb.textAlignment = NSTextAlignmentCenter;
    _numberLb.font = [UIFont systemFontOfSize:45 weight:UIFontWeightMedium];
    _numberLb.backgroundColor = [UIColor clearColor];
    [_numberLb setAttributedText:[self changeLabelWithText:@"0db"]];
    _numberLb.textColor = [UIColor whiteColor];
    [self.view addSubview:_numberLb];
    
    UILabel *message = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_numberLb.frame)+20, SCREEN_WIDTH, 18)];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor whiteColor];
    message.text = @"当前噪音/单位db";
    message.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.view addSubview:message];
}

- (NSMutableAttributedString*) changeLabelWithText:(NSString*)needText
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:needText];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(needText.length-2,2)];
    return attrString;
}

- (void)dealloc{
    
    _recorder = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
