//
//  YKRMainViewController.m
//  TFQ_Loan
//
//  Created by MAC on 2019/5/27.
//  Copyright © 2019 com.lj.tfq. All rights reserved.
//

#import "YKRMainViewController.h"
#import "YKRMainCollectionViewCell.h"
#import "WeatherHomeViewController.h"

//#import "QQL_CompassViewController.h"
//#import "QQL_RuleViewController.h"
//#import "QQL_LevelViewController.h"
//#import "QQL_NoiseViewController.h"
//#import "QQL_MirrorViewController.h"
//#import "QQL_CorrectViewController.h"
//#import "QQL_ProtractorViewController.h"
//#import "QQL_NetworkSpeedViewController.h"

@interface YKRMainViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) UICollectionView *myCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *gridLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *listLayout;

@end

@implementation YKRMainViewController

#pragma mark - View Lifecycle （View 的生命周期）

- (void)viewWillDisappear:(BOOL)animated {
//    self.navigationController.navigationBarHidden = YES;
}

-(UICollectionViewFlowLayout *)gridLayout{
    if (!_gridLayout) {
        _gridLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = (self.view.frame.size.width - ptWidth7(25)) * 1/3;
        NSLog(@"item宽度::%f", width);
        _gridLayout.itemSize = CGSizeMake(width, ptHeight7(30) + width);
        _gridLayout.minimumLineSpacing = ptWidth7(5);
        _gridLayout.minimumInteritemSpacing = ptWidth7(5);
//        _gridLayout.sectionInset = UIEdgeInsetsZero;
        _gridLayout.sectionInset = UIEdgeInsetsMake(ptHeight7(10), ptWidth7(5), 0, ptWidth7(5));
    }
    return _gridLayout;
}

-(UICollectionViewFlowLayout *)listLayout{
    if (!_listLayout) {
        _listLayout = [[UICollectionViewFlowLayout alloc] init];
        _listLayout.itemSize = CGSizeMake(self.view.frame.size.width, ptHeight7(88));
        _listLayout.minimumLineSpacing = 0.5;
        _listLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _listLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self masLayoutSubview];
    self.title = @"Daily Tools";
    //test
//    self.view.backgroundColor = [UIColor grayColor];
//    self.imageNameArray = @[@"zhinanzhen",
//                            @"liangjiaoqi",
//                            @"zaoyin",
//                            @"netSpeed",
//                            @"shuipingyi",
//                            @"guawujiaozheng",
//                            @"chizi",
//                            @"jingzi",
//                            @"Weather"];
//    self.titleArray = @[@"指南针",
//                        @"量角器",
//                        @"测噪音",
//                        @"测网速",
//                        @"水平仪",
//                        @"挂物矫正",
//                        @"尺子",
//                        @"镜子",
//                        @"天气"];
    self.imageNameArray = @[@"Weather"];
    self.titleArray = @[@"天气"];
    
    _myCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.gridLayout];
    _myCollectionView.showsVerticalScrollIndicator = NO;
    _myCollectionView.backgroundColor = [UIColor whiteColor];
    _myCollectionView.delegate = self;
    _myCollectionView.dataSource = self;
    [self.view addSubview:_myCollectionView];
    
    [self.myCollectionView registerClass:[YKRMainCollectionViewCell class] forCellWithReuseIdentifier:kMainCollectionViewCellIdentifier];
    
}

#pragma mark - Custom Accessors （自定义访问器）


#pragma mark - IBActions


#pragma mark - Public


#pragma mark - Private

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YKRMainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMainCollectionViewCellIdentifier forIndexPath:indexPath];

//    cell.imageName = self.imageNameArray[indexPath.row % self.imageNameArray.count];
    cell.coverImageView.image = [UIImage imageNamed:self.imageNameArray[indexPath.row % self.imageNameArray.count]];
    cell.titleLabel.text = self.titleArray[indexPath.row % self.titleArray.count];
    
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0)
//    {
//        QQL_CompassViewController *VC = [[QQL_CompassViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 1)
//    {
//        QQL_ProtractorViewController *VC = [[QQL_ProtractorViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 2)
//    {
//        QQL_NoiseViewController *VC = [[QQL_NoiseViewController alloc] init];
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 3)
//    {
//        QQL_NetworkSpeedViewController *VC = [[QQL_NetworkSpeedViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 4)
//    {
//        QQL_LevelViewController *VC = [[QQL_LevelViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 5)
//    {
//        QQL_CorrectViewController *VC = [[QQL_CorrectViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 6)
//    {
//        QQL_RuleViewController *VC = [[QQL_RuleViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 7)
//    {
//        QQL_MirrorViewController *VC = [[QQL_MirrorViewController alloc] init];
//        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
//    }
//    else if (indexPath.row == 8) {
        WeatherHomeViewController *weatherVC = [[WeatherHomeViewController alloc] init];
        [self.navigationController pushViewController:weatherVC animated:YES];
//    }
//    else if (indexPath.row == 9) {
//        XSMainViewController *xsMainVC = [[XSMainViewController alloc] init];
//        [self.navigationController pushViewController:xsMainVC animated:YES];
////        [UIApplication sharedApplication].keyWindow.rootViewController = xsMainVC;
//    }
}

#pragma mark - ZOCSuperclass
// ... 重写来自 ZOCSuperclass 的方法

#pragma mark - NSObject
//- (YKRMainContainerView *)containerView {
//    if (!_containerView) {
//        UIView *superView = self.view;
//        _containerView = [[YKRMainContainerView alloc] init];
//        [superView addSubview:_containerView];
//        _containerView.collectionView.delegate = self;
//        _containerView.collectionView.dataSource = self;
//
//    }
//    return _containerView;
//}


- (void)masLayoutSubview
{
    UIView *superView = self.view;
  
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
