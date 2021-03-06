//
//  TimTableViewController.m
//  CRM
//
//  Created by TimTiger on 5/13/14.
//  Copyright (c) 2014 TimTiger. All rights reserved.
//

#import "TimTableViewController.h"
#import "CommonMacro.h"
#import "TimRequest.h"
#import "DBManager.h"
#import "UIBarButtonItem+Extension.h"
#import "CRMAppDelegate.h"
#import "UIColor+Extension.h"
#import "UINavigationItem+Margin.h"

@interface TimTableViewController ()

@end

@implementation TimTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef __IPHONE_7_0
    if (IOS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    if (IOS_7_OR_LATER) {
        if (!self.navigationController || [self.navigationController isNavigationBarHidden]) {
            self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-20);
        } else {
            self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64);
        }
    } else if (IOS_5_OR_LATER) {
        if (!self.navigationController || ![self.navigationController isNavigationBarHidden]) {
            self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44);
        }
    }
    self.tableView.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor colorWithHex:VIEWCONTROLLER_BACKGROUNDCOLOR];
    
    
    
    [self performSelector:@selector(initData)];
    [self performSelector:@selector(initView)];
    [self becomeRequestResponder]; //成为网络数据响应者
}

- (void)initView {
    // Do any additional setup after did load the view.
}

- (void)refreshView {
    
}

- (void)initData {
    // Do any additional data setup after did load the view.
}

- (void)refreshData {
    // Do any data setup when want to refresh data.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CRMAppDelegate *appDelegate = (CRMAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self addUIkeyboardNotificationObserver];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSLog(@"viewDidAppear %d",viewControllers.count);
    CRMAppDelegate *appDelegate = (CRMAppDelegate *)[UIApplication sharedApplication].delegate;
    if (viewControllers.count <= 1) {
        [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        if (IOS_7_OR_LATER) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    else{
        [appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        if (IOS_7_OR_LATER) {
            self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *viewControllers = self.navigationController.viewControllers;
    NSLog(@"viewWillDisappear %d",viewControllers.count);
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        // NSLog(@"New view controller was pushed");
        if (IOS_7_OR_LATER) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        //  NSLog(@"View controller was popped");
    }
    [self removeUIkeyboardNotificationObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self removeRequestResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Public API
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - Pvivate API
- (void)becomeRequestResponder {
    [[TimRequest deafalutRequest] addResponder:self];
}

- (void)removeRequestResponder {
    [[TimRequest deafalutRequest] removeResponder:self];
}

- (void)addUIkeyboardNotificationObserver {
    [self addObserveNotificationWithName:UIKeyboardWillShowNotification];
//    [self addObserveNotificationWithName:UIKeyboardWillHideNotification];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    if(IOS_5_OR_LATER) {
//        [self addObserveNotificationWithName:UIKeyboardWillChangeFrameNotification];
    }
#endif
    
//    [self addObserveNotificationWithName:UITextFieldTextDidChangeNotification];
    [self addObserveNotificationWithName:UITextFieldTextDidEndEditingNotification];
//    [self addObserveNotificationWithName:UITextViewTextDidChangeNotification];
//    [self addObserveNotificationWithName:UITextViewTextDidEndEditingNotification];
    
}

- (void)removeUIkeyboardNotificationObserver {
    [self removeObserverNotificationWithName:UIKeyboardWillShowNotification];
//    [self removeObserverNotificationWithName:UIKeyboardWillHideNotification];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    if(IOS_5_OR_LATER) {
//        [self removeObserverNotificationWithName:UIKeyboardWillChangeFrameNotification];
    }
#endif
    
//    [self removeObserverNotificationWithName:UITextFieldTextDidChangeNotification];
    [self removeObserverNotificationWithName:UITextFieldTextDidEndEditingNotification];
//    [self removeObserverNotificationWithName:UITextViewTextDidChangeNotification];
//    [self removeObserverNotificationWithName:UITextViewTextDidEndEditingNotification];
}

#pragma mark Notification

//- (void)keyboardWillShow:(NSNotification *)notification {
//    
//    NSDictionary *userInfo = [notification userInfo];
//    
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    CGFloat tableHeight = self.tableView.bounds.size.height;  //table高度
//    CGFloat keyboardHeight = keyboardRect.size.height;  //键盘高度
//    CGFloat visibleHeight = tableHeight-keyboardHeight; //可见区域
//    CGFloat cellBottomY = self.firstResponderCell.frame.origin.y+self.firstResponderCell.bounds.size.height;
//    
//    if (cellBottomY > visibleHeight) { //当cell被键盘挡住的时候
//        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//        NSTimeInterval animationDuration;
//        [animationDurationValue getValue:&animationDuration]; //获得键盘弹出的动画时间
//        [UIView animateWithDuration:animationDuration animations:^{
//            self.tableView.contentOffset = CGPointMake(0,cellBottomY-visibleHeight);
//        }];
//    }
//}
//
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//    
//    NSDictionary* userInfo = [notification userInfo];
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.tableView.contentOffset = CGPointMake(0,0);
//    }];
//    
//}

- (void)textDidChange {
    [self performSelector:@selector(getInputData)];
}

- (void)getInputData {
    
}

#pragma mark ScrollView DElegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


@end

@implementation TimTableViewController (Notification)

- (void)addNotificationObserver {
    
}

- (void)removeNotificationObserver {
    
}

- (void)addObserveNotificationWithName:(NSString *)aName {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handNotification:) name:aName object:nil];
}

- (void)addObserveNotificationWithName:(NSString *)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handNotification:) name:aName object:anObject];
}

- (void)removeObserverNotificationWithName:(NSString *)aName {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:aName object:nil];
}

- (void)removeObserverNotificationWithName:(NSString *)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:aName object:anObject];
}

- (void)postNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

- (void)handNotification:(NSNotification *)notifacation {
    if ([notifacation.name isEqualToString:UIKeyboardWillShowNotification]) {
        [self keyboardWillShow];
    }else if ([notifacation.name isEqualToString:UITextFieldTextDidBeginEditingNotification]) {
        
    }
}

- (void)keyboardWillShow {
    
}
//        else if ([notifacation.name isEqualToString:UIKeyboardWillHideNotification]) {
//        [self keyboardWillHide:notifacation];
//    } else
//        if ([notifacation.name isEqualToString:UIKeyboardWillChangeFrameNotification]
//               || [notifacation.name isEqualToString:UITextFieldTextDidChangeNotification]
//               || [notifacation.name isEqualToString:UITextFieldTextDidEndEditingNotification]
//               || [notifacation.name isEqualToString:UITextViewTextDidChangeNotification]
//               || [notifacation.name isEqualToString:UITextViewTextDidEndEditingNotification]) {
//        [self textDidChange];
//    }
//}

@end

@implementation TimTableViewController (UIBarButtonItem)

- (void)setBackBarButtonWithImage:(UIImage *)image {
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithImage:image target:self action:@selector(onBackButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)setLeftBarButtonWithImage:(UIImage *)image {
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithImage:image target:self action:@selector(onLeftButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)setRightBarButtonWithImage:(UIImage *)image {
    UIBarButtonItem *rightItem = [UIBarButtonItem itemWithImage:image target:self action:@selector(onRightButtonAction:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)setRightBarButtonWithTitle:(NSString *)title {
    UIBarButtonItem *rightItem = [UIBarButtonItem itemWithTitle:title target:self action:@selector(onRightButtonAction:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}


- (void)onLeftButtonAction:(id)sender {
    
}

- (void)onBackButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRightButtonAction:(id)sender {
    
}

@end

