//
//  YKRMainCollectionViewCell.h
//  TFQ_Loan
//
//  Created by MAC on 2019/5/27.
//  Copyright © 2019 com.lj.tfq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMainCollectionViewCellIdentifier;

@interface YKRMainCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, strong) UILabel *titleLabel;
@end

NS_ASSUME_NONNULL_END
