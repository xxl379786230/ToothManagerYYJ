//
//  XLPatientDisplayViewController.m
//  CRM
//
//  Created by Argo Zhang on 15/12/24.
//  Copyright © 2015年 TimTiger. All rights reserved.
//

#import "XLPatientDisplayViewController.h"
#import "EMSearchDisplayController.h"
#import "EMSearchBar.h"
#import "RealtimeSearchUtil.h"
#import "ChineseSearchEngine.h"
#import "CRMMacro.h"
#import "DBManager+Materials.h"
#import "DBManager+Patients.h"
#import "SDImageCache.h"
#import "LocalNotificationCenter.h"
#import "SVProgressHUD.h"
#import "SyncManager.h"
#import "PatientDetailViewController.h"
#import "DoctorGroupViewController.h"
#import "UISearchBar+XLMoveBgView.h"
#import "MJExtension.h"
#import "JSONKit.h"
#import "DBManager+AutoSync.h"
#import "DBManager+sync.h"
#import "MJRefresh.h"
#import "DBManager+Doctor.h"
#import "XLPatientDetailViewController.h"
#import "DBManager+LocalNotification.h"
#import "NSString+TTMAddtion.h"
#import "XLFilterView.h"
#import "XLTitleButton.h"
#import "UIImage+TTMAddtion.h"
#import "XLPatientSortManager.h"
#import "UITableView+NoResultAlert.h"
#import "AutoSyncGetManager.h"
#import "YYJPatientCellModel.h"
#import "YYJPatientListCell.h"
#import "XLAppointmentBaseViewController.h"
#import "ChatViewController.h"

#define kSearchTableViewType @"searchTableView"

@interface XLPatientDisplayViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,XLFilterViewDelegate,YYJPatientListCellDelegate>

@property (nonatomic, strong)EMSearchBar *searchBar;//搜索框
@property (nonatomic, strong)EMSearchDisplayController *searchController;//搜索视图
@property (nonatomic, weak)UITableView *seachTableView;

@property (nonatomic, strong)NSMutableArray *patientCellModeArray;//表示图显示所需数据源
@property (nonatomic,retain) NSArray *patientInfoArray;//获取数据库中患者的信息

@property (nonatomic, assign)int pageNum;//分页显示的页数，默认从0开始
@property (nonatomic, assign)NSInteger allCount;//所有数据


@end

@implementation XLPatientDisplayViewController


#pragma mark - ********************* Life Method ***********************
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark 拦截父类的方法
- (void)viewWillAppear:(BOOL)animated{}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置子视图
    [self setUpSubviews];
    //添加通知
    [self addNotification];
    //设置上拉加载和下拉刷新
    self.showRefreshHeader = YES;
    
    //显示加载效果
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    //每次view完全显示的时候请求本地数据
    [self firstRequestLocalData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ********************* Private Method ***********************
#pragma mark 设置子视图
- (void)setUpSubviews{
    self.pageNum = 0;
    self.tableView.frame = CGRectMake(0, 44 + 40, kScreenWidth, kScreenHeight - 64 - 40 - 44);
    //初始化搜索框
    [self.view addSubview:self.searchBar];
    [self.view addSubview:[self setUpGroupViewAndButtons]];
    //设置搜索框
    [self searchController];
}
#pragma mark 添加通知
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:PatientCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:PatientDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:PatientEditedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:MedicalCaseCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:MedicalCaseEditedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:PatientTransferNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstRequestLocalData) name:SyncGetSuccessNotification object:nil];
}

#pragma mark 同步成功后收到通知后调用的方法
- (void)syncGetAction{
    if ([self.tableView.header isRefreshing]) {
        [self.tableView.header endRefreshing];
    }
    [self firstRequestLocalData];
}

#pragma mark 首次请求数据
- (void)firstRequestLocalData{

    //重新请求数据
    self.pageNum = 0;
    [self requestLocalDataWithPage:self.pageNum isHeader:YES isFooter:NO];
}

#pragma mark 下拉刷新事件
- (void)tableViewDidTriggerHeaderRefresh{
    //请求网络数据
    [SVProgressHUD showWithStatus:@"正在加载最新数据"];
    [[AutoSyncGetManager shareInstance] startSyncGetShowSuccess:NO];
}
#pragma mark 上拉加载事件
- (void)tableViewDidTriggerFooterRefresh{
    //首先将页码加1
    if (self.patientCellModeArray.count < self.allCount) {
        self.pageNum++;
        [self requestLocalDataWithPage:self.pageNum isHeader:NO isFooter:YES];
    }else{
        self.showRefreshFooter = NO;
    }
}
#pragma mark  加载本地数据
- (void)requestLocalDataWithPage:(int)pageNum isHeader:(BOOL)isHeader isFooter:(BOOL)isFooter{
    WS(weakSelf);
    self.patientInfoArray = [[DBManager shareInstance] getPatientListCellModelsWithDoctorId:[AccountManager currentUserid] page:self.pageNum];
    
    [SVProgressHUD  dismiss];
    if (isHeader) {
        weakSelf.allCount = [[DBManager shareInstance] getAllPatientCount];
        [weakSelf.patientCellModeArray removeAllObjects];
        [weakSelf.patientCellModeArray addObjectsFromArray:[weakSelf.patientInfoArray copy]];
    }
    //刷新表示图
    [weakSelf.tableView reloadData];
    if (isHeader) {
        [weakSelf tableViewDidFinishTriggerHeader:YES reload:NO];
        //数据判断
        if (weakSelf.patientInfoArray.count < CommonPageSize) {
            weakSelf.showRefreshFooter = NO;
        }else{
            weakSelf.showRefreshFooter = YES;
        }
    }else if (isFooter){
        [weakSelf tableViewDidFinishTriggerHeader:NO reload:NO];
    }
}

#pragma mark 患者删除事件
- (void)deletePatientWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath sourceArray:(NSMutableArray *)souryArray type:(NSString *)type{
    WS(weakSelf);
    TimAlertView *alertView = [[TimAlertView alloc] initWithTitle:@"确认删除？" message:nil  cancelHandler:^{
        [tableView reloadData];
    } comfirmButtonHandlder:^{
        YYJPatientCellModel *cellMode = [souryArray objectAtIndex:indexPath.row];
        NSArray *libArray = [[DBManager shareInstance] getCTLibArrayWithPatientId:cellMode.patientId];
        for (CTLib *lib in libArray) {
            [[SDImageCache sharedImageCache] removeImageForKey:lib.ckeyid fromDisk:YES];
        }
        BOOL ret = [[DBManager shareInstance] deletePatientByPatientID:cellMode.patientId];
        if (ret == NO) {
            [SVProgressHUD showImage:nil status:@"删除失败"];
        } else {
            if ([type isEqualToString:kSearchTableViewType]) {
                [souryArray removeObject:cellMode];
                
                if ([weakSelf.patientCellModeArray containsObject:cellMode]) {
                    [weakSelf.patientCellModeArray removeObject:cellMode];
                }
                //刷新表示图
                [tableView reloadData];
                [weakSelf.tableView reloadData];
            }else{
                [souryArray removeObject:cellMode];
                [weakSelf.tableView reloadData];
            }
            Patient *pateintTemp = [[DBManager shareInstance] getPatientCkeyid:cellMode.patientId];
            //自动同步信息
            if (pateintTemp != nil) {
                InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_Patient postType:Delete dataEntity:[pateintTemp.keyValues JSONString] syncStatus:@"0"];
                [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                
                //获取所有的病历进行删除
                NSArray *medicalcases = [[DBManager shareInstance] getAllDeleteNeedSyncMedical_case];
                if (medicalcases.count > 0) {
                    for (MedicalCase *mCase in medicalcases) {
                        InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_MedicalCase postType:Delete dataEntity:[mCase.keyValues JSONString] syncStatus:@"0"];
                        [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                    }
                }
                
                //获取所有的耗材信息进行删除
                NSArray *medicalExpenses = [[DBManager shareInstance] getAllDeleteNeedSyncMedical_expense];
                if (medicalcases.count > 0) {
                    for (MedicalExpense *expense in medicalExpenses) {
                        InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_MedicalExpense postType:Delete dataEntity:[expense.keyValues JSONString] syncStatus:@"0"];
                        [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                    }
                }
                
                //获取所有的病历记录进行删除
                NSArray *medicalRecords = [[DBManager shareInstance] getAllDeleteNeedSyncMedical_record];
                if (medicalRecords.count > 0) {
                    for (MedicalRecord *record in medicalRecords) {
                        InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_MedicalRecord postType:Delete dataEntity:[record.keyValues JSONString] syncStatus:@"0"];
                        [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                    }
                }
                
                //获取所有的ct数据进行删除
                NSArray *ctLibs = [[DBManager shareInstance] getAllDeleteNeedSyncCt_lib];
                if (ctLibs.count > 0) {
                    for (CTLib *ctLib in ctLibs) {
                        InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_CtLib postType:Delete dataEntity:[ctLib.keyValues JSONString] syncStatus:@"0"];
                        [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                    }
                }
                
                //获取所有的会诊记录进行删除
                NSArray *patientCons = [[DBManager shareInstance] getPatientConsultationWithPatientId:cellMode.patientId];
                if (patientCons.count > 0) {
                    for (PatientConsultation *patientC in patientCons) {
                        InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_PatientConsultation postType:Delete dataEntity:[patientC.keyValues JSONString] syncStatus:@"0"];
                        [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                    }
                }
                
                //获取所有的预约数据进行删除
                NSArray *notis = [[DBManager shareInstance] localNotificationListByPatientId:cellMode.patientId];
                if (notis.count > 0) {
                    for (LocalNotification *noti in notis) {
                        
                        if([[DBManager shareInstance] deleteLocalNotification:noti]){
                            InfoAutoSync *info = [[InfoAutoSync alloc] initWithDataType:AutoSync_ReserveRecord postType:Delete dataEntity:[noti.keyValues JSONString] syncStatus:@"0"];
                            [[DBManager shareInstance] insertInfoWithInfoAutoSync:info];
                        }
                    }
                }
                //删除本地的患者介绍人关系表的数据
                [[DBManager shareInstance] deletePatientIntroducerMap:cellMode.patientId];
                //删除成功后发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:PatientDeleteNotification object:nil];
            }
        }
    }];
    [alertView show];
}

#pragma mark - ******************* Delegate / DataSource ********************
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    [tableView createNoResultAlertViewWithImageName:@"patientList_alert.png" showButton:NO ifNecessaryForRowCount:self.patientCellModeArray.count];
    return self.patientCellModeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [YYJPatientListCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YYJPatientListCell *cell = [YYJPatientListCell cellWithTableView:tableView];
    
    cell.delegate = self;
    //赋值,获取患者信息
    YYJPatientCellModel *cellMode = self.patientCellModeArray[indexPath.row];
    
    cell.model = cellMode;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YYJPatientCellModel *model = self.patientCellModeArray[indexPath.row];
    //跳转到新的患者详情页面
    PatientDetailViewController *detailVc = [[PatientDetailViewController alloc] init];
    detailVc.patientId = model.patientId;
    detailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVc animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deletePatientWithTableView:tableView indexPath:indexPath sourceArray:self.patientCellModeArray type:@"tableView"];
    }
}

#pragma mark - YYJPatientListCellDelegate
- (void)patientListCell:(YYJPatientListCell *)patientListCell didClickButton:(UIButton *)button{
    NSIndexPath *indexPath;
    if (self.seachTableView) {
        indexPath = [self.seachTableView indexPathForCell:patientListCell];
    }else{
        indexPath = [self.tableView indexPathForCell:patientListCell];
    }
    YYJPatientCellModel *model = self.patientCellModeArray[indexPath.row];
    if ([button.currentTitle isEqualToString:@"消息"]) {
        //跳转到即时通讯页面
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationChatter:model.patientId conversationType:eConversationTypeChat];
        chatController.title = model.patientName;
        chatController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatController animated:YES];
    }else{
        //预约
        Patient *patient = [[DBManager shareInstance] getPatientWithPatientCkeyid:model.patientId];
        XLAppointmentBaseViewController *baseVC = [[XLAppointmentBaseViewController alloc] init];
        baseVC.patient = patient;
        baseVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:baseVC animated:YES];
    }
}


#pragma mark UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isNotEmpty]) {
        NSArray *results = [[DBManager shareInstance] getPatientListCellModelsWithDoctorId:[AccountManager currentUserid] keyWord:searchText];
        [self.searchController.resultsSource removeAllObjects];
        [self.searchController.resultsSource addObjectsFromArray:results];
        [self.searchController.searchResultsTableView reloadData];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(nullable NSString *)searchString{
    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView *subview in weakSelf.searchDisplayController.searchResultsTableView.subviews) {
            if ([subview isKindOfClass: [UILabel class]])
            {
                subview.hidden = YES;
            }
        }
    });
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    self.seachTableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    self.seachTableView = tableView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void) keyboardWillHide {
    UITableView *tableView = self.searchController.searchResultsTableView;
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    
}

#pragma mark - ********************* View Create ***********************
#pragma mark 创建排序按钮
- (UIView *)setUpGroupViewAndButtons{
    
    CGFloat commonH = 40;
    
    UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, commonH)];
    superView.backgroundColor = [UIColor whiteColor];
    
    UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, commonH)];
    groupView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [groupView addGestureRecognizer:tapAction];
    [superView addSubview:groupView];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"patient_group_blue"]];
    iconView.frame = CGRectMake(20, 13, 16, 14);
    [groupView addSubview:iconView];
    
    UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 200, 40)];
    groupNameLabel.textColor = MyColor(35, 35, 35);
    groupNameLabel.font = [UIFont systemFontOfSize:15];
    groupNameLabel.text = @"我的分组";
    [groupView addSubview:groupNameLabel];
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_crm"]];
    arrowView.frame = CGRectMake(kScreenWidth - 10 - 13, 11, 13, 18);
    [groupView addSubview:arrowView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, kScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    [groupView addSubview:lineView];
    
    return superView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    DoctorGroupViewController *manageVc = [[DoctorGroupViewController alloc] initWithStyle:UITableViewStylePlain];
    manageVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:manageVc animated:YES];
}

- (NSMutableArray *)patientCellModeArray{
    if (!_patientCellModeArray) {
        _patientCellModeArray = [NSMutableArray array];
    }
    return _patientCellModeArray;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"患者姓名、备注名、手机号";
        [_searchBar moveBackgroundView];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        __weak XLPatientDisplayViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            
            YYJPatientListCell *cell = [YYJPatientListCell cellWithTableView:tableView];
            cell.delegate = weakSelf;
            //赋值,获取患者信息
            YYJPatientCellModel *cellMode = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];

            cell.model = cellMode;
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [YYJPatientListCell cellHeight];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            YYJPatientCellModel *model = weakSelf.searchController.resultsSource[indexPath.row];
            //跳转到新的患者详情页面
            PatientDetailViewController *detailVc = [[PatientDetailViewController alloc] init];
            detailVc.patientId = model.patientId;
            detailVc.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:detailVc animated:YES];
            
        }];
        
        [_searchController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
            return YES;
        }];
        
        [_searchController setCommitEditingStyleAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [weakSelf deletePatientWithTableView:tableView indexPath:indexPath sourceArray:weakSelf.searchController.resultsSource type:kSearchTableViewType];
        }];
    }
    
    return _searchController;
}

@end
