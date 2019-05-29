//
//  QQL_RuleViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_RuleViewController.h"
#import "ZJ_RulesLineView.h"

@interface QQL_RuleViewController ()

@property (nonatomic, strong) ZJ_RulesLineView *lineView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation QQL_RuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)buttonClick
{
    [_lineView removeFromSuperview];
    [_button removeFromSuperview];
    UIWindow *application = [UIApplication sharedApplication].keyWindow;
    application.windowLevel = 0.0;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIWindow *application = [UIApplication sharedApplication].keyWindow;
    application.windowLevel = UIWindowLevelAlert;
    ZJ_RulesLineView *lineView = [[ZJ_RulesLineView alloc] initWithFrame:application.bounds];
    [application addSubview:lineView];
    _lineView = lineView;
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(SCREEN_WIDTH-100, 35, 37, 37);
    [button setImage:[UIImage imageNamed:@"tool_fanhui"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:(UIControlEventTouchUpInside)];
    [application addSubview:button];
    _button = button;
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
