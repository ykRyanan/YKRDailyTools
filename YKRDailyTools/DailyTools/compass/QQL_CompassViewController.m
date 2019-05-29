//
//  QQL_CompassViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_CompassViewController.h"
#import "QQL_CompassView.h"

@interface QQL_CompassViewController ()

@end

@implementation QQL_CompassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    QQL_CompassView *compassView = [QQL_CompassView sharedWithRect:self.view.bounds radius:(self.view.bounds.size.width-20)/2];
    compassView.backgroundColor = [UIColor blackColor];
    compassView.textColor = [UIColor whiteColor];
    compassView.calibrationColor = [UIColor whiteColor];
    compassView.horizontalColor = [UIColor purpleColor];
    [self.view addSubview:compassView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(15, 35, 37, 37);
    [button setImage:[UIImage imageNamed:@"tool_fanhui_left"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)buttonClick
{
    [self.navigationController popViewControllerAnimated:YES];
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
