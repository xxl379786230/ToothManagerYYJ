//
//  GroupPatientCell.m
//  CRM
//
//  Created by Argo Zhang on 15/12/9.
//  Copyright © 2015年 TimTiger. All rights reserved.
//

#import "GroupPatientCell.h"
#import "UIColor+Extension.h"
#import "GroupPatientModel.h"
#import "DBTableMode.h"
#import "GroupMemberModel.h"

#define CommenFont [UIFont systemFontOfSize:14]
#define CommenColor [UIColor blackColor]

#define Margin 10
#define RowHeight 44

@interface GroupPatientCell (){
    UIImageView *_signImageView;//是否是转诊患者标识
    UILabel *_nameLabel;    //患者姓名
    UILabel *_introducerLabel; //介绍人
    UIButton *_chooseButton; //是否选中
}

@end

@implementation GroupPatientCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"group_patient_cell";
    GroupPatientCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
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

#pragma mark - 初始化方法
- (void)setUp{
    //是否是转诊患者标识
    _signImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhuan"]];
    _signImageView.hidden = YES;
    [self.contentView addSubview:_signImageView];
    
    //患者姓名
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = CommenFont;
    _nameLabel.textColor = CommenColor;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_nameLabel];
    
    //介绍人
    _introducerLabel = [[UILabel alloc] init];
    _introducerLabel.font = CommenFont;
    _introducerLabel.textColor = CommenColor;
    _introducerLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_introducerLabel];
    
    //是否选中
    _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseButton setImage:[UIImage imageNamed:@"no-choose"] forState:UIControlStateNormal];
    [_chooseButton setImage:[UIImage imageNamed:@"choose-blue"] forState:UIControlStateSelected];
    [_chooseButton addTarget:self action:@selector(chooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_chooseButton];
}

- (void)setModel:(GroupMemberModel *)model{
    _model = model;
    
    if (model.nickName && [model.nickName isNotEmpty]) {
        _nameLabel.text = model.nickName;
    }else{
        _nameLabel.text = model.patient_name;
    }
    _introducerLabel.text = model.intr_name;
    if (model.is_transfer == 0) {
        _signImageView.hidden = YES;
    }else{
        _signImageView.hidden = NO;
    }

    //如果已经是组员，默认不可选
    if (model.isMember) {
        [_chooseButton setImage:[UIImage imageNamed:@"choose-grey"] forState:UIControlStateNormal];
        _chooseButton.enabled = NO;
    }else {
        [_chooseButton setImage:[UIImage imageNamed:@"no-choose"] forState:UIControlStateNormal];
        _chooseButton.enabled = YES;
        
        //判断是否选中
        if (model.isChoose) {
            _chooseButton.selected = YES;
        }else{
            _chooseButton.selected = NO;
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat commonW = (kScreenWidth - 30) / 2;
    if (!self.isManage) {
        commonW = (kScreenWidth - 50) / 2;
    }
    
    //计算所有的size
    CGFloat nameW = commonW * .6;
    CGFloat nameX = commonW - nameW;
    _nameLabel.frame = CGRectMake(nameX, 0, nameW, RowHeight); //95
    
    CGFloat signW = 20;
    CGFloat signH = signW;
    CGFloat signX = commonW - nameW - signW;
    _signImageView.frame = CGRectMake(signX, (RowHeight - signH) / 2, signW, signH);
    _introducerLabel.frame = CGRectMake(_nameLabel.right, 0, commonW, RowHeight);
    
    if (!self.isManage) {
        _chooseButton.frame = CGRectMake(self.width - RowHeight - 5, 0, RowHeight + 5, RowHeight);
    }
}

#pragma mark - 按钮选中事件
- (void)chooseAction:(UIButton *)button{
    button.selected = !button.isSelected;
    if ([self.delegate respondsToSelector:@selector(didChooseCell:withChooseStatus:)]) {
        [self.delegate didChooseCell:self withChooseStatus:button.isSelected];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
