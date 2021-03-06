//
//  TimNavigationBarMenuView.h
//  CRM
//
//  Created by TimTiger on 6/6/14.
//  Copyright (c) 2014 TimTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimNavigationBarMenuViewDelegate;
@interface TimNavigationBarMenuView : UIView

@property (nonatomic,retain) NSArray *menuArray;
@property (nonatomic,assign) id <TimNavigationBarMenuViewDelegate> delegate;

@end

@protocol TimNavigationBarMenuViewDelegate <NSObject>

- (void)menuView:(UITableView *)menuView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end