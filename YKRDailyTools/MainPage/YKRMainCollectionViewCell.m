//
//  YKRMainCollectionViewCell.m
//  TFQ_Loan
//
//  Created by MAC on 2019/5/27.
//  Copyright © 2019 com.lj.tfq. All rights reserved.
//

#import "YKRMainCollectionViewCell.h"

NSString *const kMainCollectionViewCellIdentifier = @"kMainCollectionViewCellIdentifier";

@implementation YKRMainCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self masLayoutSubview];
//        self.layer.cornerRadius = px1080Width(10);
//        self.layer.masksToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setImageName:(NSString *)imageName{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:imageName];
    self.coverImageView.image = [UIImage imageWithContentsOfFile:filePath];
}

- (UIImageView *)coverImageView
{
    
    if (!_coverImageView)
    {
        UIView *superView = self.contentView;
        CGFloat width = CGRectGetWidth(superView.bounds);
        NSLog(@"item宽度xxxx::%f", width);
        _coverImageView = [[UIImageView alloc] init];
        [superView addSubview:_coverImageView];
//        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _coverImageView.layer.cornerRadius = width * 0.5;
//        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UIView *superView = self.contentView;
        _titleLabel = [[UILabel alloc] init];
        [superView addSubview:_titleLabel];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (void)masLayoutSubview
{
    UIView *superView = self.contentView;
    CGFloat width = CGRectGetWidth(superView.bounds);
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(superView);//.mas_offset(ptWidth7(10));
        make.right.mas_equalTo(superView);//.mas_offset(ptWidth7(-10));
        make.top.mas_equalTo(superView);//.mas_equalTo(ptHeight7(10));
//        make.bottom.mas_lessThanOrEqualTo(self.titleLabel).mas_offset(ptHeight7(-10));
        make.height.mas_equalTo(width);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(superView);
        make.bottom.mas_equalTo(superView).mas_offset(ptHeight7(-2));
    }];
}
@end
