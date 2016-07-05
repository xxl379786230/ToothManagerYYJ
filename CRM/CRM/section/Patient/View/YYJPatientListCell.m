//
//  YYJPatientListCell.m
//  CRM
//
//  Created by Argo Zhang on 16/6/29.
//  Copyright © 2016年 TimTiger. All rights reserved.
//

#import "YYJPatientListCell.h"
#import "UIColor+Extension.h"
#import "YYJPatientCellModel.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>

#define kBorderColor [UIColor colorWithHex:0xcccccc]
#define kNameFont [UIFont systemFontOfSize:18]
#define kNameColor [UIColor colorWithHex:0x333333]
#define kTimeFont [UIFont systemFontOfSize:13]
#define kTimeColor [UIColor colorWithHex:0x888888]

#define kMessageButtonColor [UIColor colorWithHex:0x78bf32]
#define kAppointButtonColor [UIColor colorWithHex:0x5fa8ed]

#define kCellHeight 70
#define kHeadImageHeight 50
#define kHeadImageWidth kHeadImageHeight
#define kMargin 10
#define kNameHeight 24
#define kTimeHeight 16
#define kButtonWidth 40
#define kButtonHeight 25

@interface YYJPatientListCell ()

@property (nonatomic, strong)UIImageView *headImageView; //患者CT图片
@property (nonatomic, strong)UILabel *nameLabel;    //患者名称
@property (nonatomic, strong)UILabel *cureTimeLabel;//初诊时间
@property (nonatomic, strong)UIButton *messageButton;//消息按钮
@property (nonatomic, strong)UIButton *appointButton;//预约按钮

@end

@implementation YYJPatientListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"patient_list_cell";
    YYJPatientListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化
        [self setUp];
    }
    return self;
}

#pragma mark - ********************* Private Method ***********************
#pragma mark 初始化
- (void)setUp{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.cureTimeLabel];
    [self.contentView addSubview:self.messageButton];
    [self.contentView addSubview:self.appointButton];
    
    //设置约束
    [self setUpContraints];
}

#pragma mark 设置约束
- (void)setUpContraints{
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(kMargin);
        make.size.mas_equalTo(CGSizeMake(kHeadImageWidth, kHeadImageHeight));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kMargin);
        make.left.equalTo(self.headImageView.mas_right).offset(kMargin);
        make.right.equalTo(self.messageButton.mas_left).offset(-kMargin);
        make.height.mas_equalTo(kNameHeight);
    }];
    
    [self.cureTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-kMargin);
        make.width.mas_equalTo(self.nameLabel.mas_width);
        make.height.mas_equalTo(kTimeHeight);
        make.left.equalTo(self.headImageView.mas_right).offset(kMargin);
    }];
    
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kButtonWidth, kButtonHeight));
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.appointButton.mas_left).offset(-kMargin);
    }];
    
    [self.appointButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kButtonWidth, kButtonHeight));
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-kMargin);
    }];
}

- (void)setModel:(YYJPatientCellModel *)model{
    _model = model;
    
    self.nameLabel.text = model.patientName;
    if ([model.cureTime isNotEmpty]) {
        self.cureTimeLabel.text = [NSString stringWithFormat:@"初诊时间：%@",[model.cureTime componentsSeparatedByString:@" "][0]];
    }else{
        self.cureTimeLabel.text = @"初诊时间：";
    }
    if ([model.mainCTImage isNotEmpty]) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.mainCTImage] placeholderImage:[UIImage imageNamed:@"ct_holderImage"] options:SDWebImageRefreshCached | SDWebImageRetryFailed];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"patient_no_ct"];
    }
}

#pragma mark 消息按钮点击
- (void)messageButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(patientListCell:didClickButton:)]) {
        [self.delegate patientListCell:self didClickButton:_messageButton];
    }
}

#pragma mark 预约按钮点击
- (void)appointButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(patientListCell:didClickButton:)]) {
        [self.delegate patientListCell:self didClickButton:_appointButton];
    }
}

#pragma mark - ********************* Public Method ***********************
+ (CGFloat)cellHeight{
    return kCellHeight;
}

#pragma mark - ********************* Lazy Method ***********************
- (UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.layer.cornerRadius = 5;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.layer.borderWidth = 1;
        _headImageView.layer.borderColor = kBorderColor.CGColor;
    }
    return _headImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = kNameColor;
        _nameLabel.font = kNameFont;
    }
    return _nameLabel;
}

- (UILabel *)cureTimeLabel{
    if (!_cureTimeLabel) {
        _cureTimeLabel = [[UILabel alloc] init];
        _cureTimeLabel.textColor = kTimeColor;
        _cureTimeLabel.font = kTimeFont;
    }
    return _cureTimeLabel;
}

- (UIButton *)messageButton{
    if (!_messageButton) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageButton.layer.cornerRadius = 3;
        _messageButton.layer.masksToBounds = YES;
        [_messageButton setTitle:@"消息" forState:UIControlStateNormal];
        [_messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _messageButton.titleLabel.font = kTimeFont;
        _messageButton.backgroundColor = kMessageButtonColor;
        [_messageButton addTarget:self action:@selector(messageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

- (UIButton *)appointButton{
    if (!_appointButton) {
        _appointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _appointButton.layer.cornerRadius = 3;
        _appointButton.layer.masksToBounds = YES;
        [_appointButton setTitle:@"预约" forState:UIControlStateNormal];
        [_appointButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _appointButton.titleLabel.font = kTimeFont;
        _appointButton.backgroundColor = kAppointButtonColor;
        [_appointButton addTarget:self action:@selector(appointButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _appointButton;
}

@end
