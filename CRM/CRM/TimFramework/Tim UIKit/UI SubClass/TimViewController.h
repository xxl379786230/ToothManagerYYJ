//
//  TimViewController.h
//  PhotoSharer
//
//  Created by TimTiger on 3/12/14.
//  Copyright (c) 2014 TimTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma Type Define

@interface TimViewController : UIViewController
//视图数据的操作， initView 和 initData在 viewdidload中已经调用了，子类中只需要实现这两个方法就好
- (void)initView;
- (void)refreshView;
- (void)initData;
- (void)refreshData;

//相当于self.navigationviewcontroller push的功能
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)presentToViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)dismissModelViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end


@interface TimViewController (Notification)
- (void)addNotificationObserver;
- (void)removeNotificationObserver;
- (void)addUIkeyboardNotificationObserver;
- (void)removeUIkeyboardNotificationObserver;

//监听某个通知
- (void)addObserveNotificationWithName:(NSString *)aName;
- (void)addObserveNotificationWithName:(NSString *)aName object:(id)anObject;
- (void)removeObserverNotificationWithName:(NSString *)aName;
- (void)removeObserverNotificationWithName:(NSString *)aName object:(id)anObject;

//发送通知
- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

//监听到通知后的处理函数
- (void)handNotification:(NSNotification *)notifacation;
- (void)keyboardWillShow:(CGFloat)keyboardHeight;
- (void)keyboardWillHidden:(CGFloat)keyboardHeight;
- (void)keyboardFrameChnaged:(CGFloat)changeHeight;

@end

@interface TimViewController (UIBarButtonItem)

- (void)setBackBarButtonWithImage:(UIImage *)image;
- (void)setRightBarButtonWithImage:(UIImage *)image;
- (void)setLeftBarButtonWithImage:(UIImage *)image;
- (void)setRightBarButtonWithTitle:(NSString *)title;
- (void)onBackButtonAction:(id)sender;
- (void)onRightButtonAction:(id)sender;
- (void)onLeftButtonAction:(id)sender;

@end