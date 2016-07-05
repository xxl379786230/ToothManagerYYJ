//
//  YYJPatientListCell.h
//  CRM
//
//  Created by Argo Zhang on 16/6/29.
//  Copyright © 2016年 TimTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYJPatientCellModel,YYJPatientListCell;
@protocol YYJPatientListCellDelegate <NSObject>

@optional
- (void)patientListCell:(YYJPatientListCell *)patientListCell didClickButton:(UIButton *)button;

@end

@interface YYJPatientListCell : UITableViewCell

@property (nonatomic, weak)id<YYJPatientListCellDelegate> delegate;

@property (nonatomic, strong)YYJPatientCellModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


+ (CGFloat)cellHeight;

@end
