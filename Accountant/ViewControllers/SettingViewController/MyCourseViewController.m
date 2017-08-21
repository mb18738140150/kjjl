//
//  MyCourseViewController.m
//  Accountant
//
//  Created by aaa on 2017/3/20.
//  Copyright © 2017年 tianming. All rights reserved.
//

#import "MyCourseViewController.h"
#import "UIMacro.h"
#import "CommonMacro.h"
#import "CourseraManager.h"
#import "DownloadedCourseTableViewCell.h"
#import "UIUtility.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "NotificaitonMacro.h"
#import "CoursecategoryTableViewCell.h"
#import "HYSegmentedControl.h"
#define kHeaderViewHeight 45
#define kSegmentHeight 42
@interface MyCourseViewController ()<UITableViewDelegate,UITableViewDataSource,CourseModule_LearningCourseProtocol,CourseModule_CollectCourseProtocol,CourseModule_DeleteCollectCourseProtocol, HYSegmentedControlDelegate>

@property (nonatomic, strong)HYSegmentedControl * segmentC;
@property (nonatomic, strong)UIScrollView * scrollView;
@property (nonatomic,strong) UIView                                 *headerView;

@property (nonatomic,strong) UIButton                               *button1;
@property (nonatomic,strong) UIButton                               *button2;

@property (nonatomic,strong) UITableView                            *tikuTableView;
@property (nonatomic,strong) UITableView                            *collectTableView;

@property (nonatomic,strong) NSArray                                *learningCourseArray;
@property (nonatomic,strong) NSArray                                *collectCourseArray;

@end

@implementation MyCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self navigationViewSetup];
    [self segmentSetup];
    [self contentViewSetup];
    [self learningCourseRequest];
    [self collectCourseRequest];
}

- (void)learningCourseRequest
{
    [SVProgressHUD show];
    [[CourseraManager sharedManager] didRequestLearningCourseWithNotifiedObject:self];
    
}

- (void)collectCourseRequest
{
    [SVProgressHUD show];
    [[CourseraManager sharedManager] didRequestCollectCourseWithNotifiedObject:self];
}

- (void)deleteCollectCourseWithId:(int)courseId
{
    [SVProgressHUD show];
    [[CourseraManager sharedManager] didRequestDeleteCollectCourseWithCourseId:courseId andNotifiedObject:self];
}

#pragma mark - collect delegate
- (void)didRequestCollectCourseSuccessed
{
    [SVProgressHUD dismiss];
    [self.collectTableView.mj_header endRefreshing];
    self.collectCourseArray = [[CourseraManager sharedManager] getCollectCourseInfoArray];
    [self.collectTableView reloadData];
}

- (void)didRequestCollectCourseFailed:(NSString *)failedInfo
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:failedInfo];
    [self.collectTableView.mj_header endRefreshing];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)didRequestDeleteCollectCourseSuccessed
{
    [SVProgressHUD dismiss];
    [self collectCourseRequest];
}

- (void)didRequestDeleteCollectCourseFailed:(NSString *)failedInfo
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:failedInfo];
    [self.collectTableView.mj_header endRefreshing];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

#pragma mark - learning delegate
- (void)didRequestLearningCourseSuccessed
{
    [SVProgressHUD dismiss];
    [self.tikuTableView.mj_header endRefreshing];
    self.learningCourseArray = [[CourseraManager sharedManager] getLearningCourseInfoArray];
    [self.tikuTableView reloadData];
}

- (void)didRequestLearningCourseFailed:(NSString *)failedInfo
{
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:failedInfo];
    [self.tikuTableView.mj_header endRefreshing];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

#pragma mark - response func
- (void)switchLearningCourse
{
    [self.button1 setTitleColor:kCommonNavigationBarColor forState:UIControlStateNormal];
    [self.button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.collectTableView removeFromSuperview];
    [self.view addSubview:self.tikuTableView];
}

- (void)switchCollectCourse
{
    [self.button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button2 setTitleColor:kCommonNavigationBarColor forState:UIControlStateNormal];
    [self.tikuTableView removeFromSuperview];
    [self.view addSubview:self.collectTableView];
}

#pragma mark - ui
- (void)navigationViewSetup
{
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, kScreenWidth, 64)];
    [self.view addSubview:topView];
    topView.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"我的收藏";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBar.barTintColor = kCommonNavigationBarColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:kCommonMainTextColor_50};
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"public-返回"] title:@""];
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
}
- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)segmentSetup
{
    self.segmentC = [[HYSegmentedControl alloc] initWithOriginY:0 Titles:@[@"视频", @"题库"] delegate:self];
//    [self.view addSubview:self.segmentC];
}

- (void)contentViewSetup
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeight - kStatusBarHeight)];
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * 2, kScreenHeight - kNavigationBarHeight - kStatusBarHeight - kSegmentHeight);
    self.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    self.tikuTableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight - kStatusBarHeight - kNavigationBarHeight - kHeaderViewHeight) style:UITableViewStylePlain];
    self.tikuTableView.delegate = self;
    self.tikuTableView.dataSource = self;
    self.tikuTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(learningCourseRequest)];
    
    self.collectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kStatusBarHeight - kNavigationBarHeight) style:UITableViewStylePlain];
    self.collectTableView.delegate = self;
    self.collectTableView.dataSource = self;
    [self.collectTableView registerClass:[CoursecategoryTableViewCell class] forCellReuseIdentifier:@"collectVideo"];
    self.collectTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(collectCourseRequest)];
    
    [self.scrollView addSubview:self.tikuTableView];
    [self.scrollView addSubview:self.collectTableView];
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tikuTableView) {
        return self.learningCourseArray.count;
    }
    if (tableView == self.collectTableView) {
        return self.collectCourseArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView isEqual:self.collectTableView]) {
        CoursecategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"collectVideo" forIndexPath:indexPath];
        [cell resetCellContent:[self.collectCourseArray objectAtIndex:indexPath.row]];
        
        return cell;
    }
    
    DownloadedCourseTableViewCell *cell = (DownloadedCourseTableViewCell *)[UIUtility getCellWithCellName:@"downloadedCourseCell" inTableView:tableView andCellClass:[DownloadedCourseTableViewCell class]];
    if (tableView == self.tikuTableView) {
        [cell resetCellContent:[self.learningCourseArray objectAtIndex:indexPath.row]];
    }
    if (tableView == self.collectTableView) {
        [cell resetCellContent:[self.collectCourseArray objectAtIndex:indexPath.row]];
    }
    [cell.courseCountLabel removeFromSuperview];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tikuTableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOfCourseClick object:[self.learningCourseArray objectAtIndex:indexPath.row]];
    }
    if (tableView == self.collectTableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOfCourseClick object:[self.collectCourseArray objectAtIndex:indexPath.row]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.collectTableView) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.collectTableView) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && tableView == self.collectTableView) {
        NSDictionary *dic = [self.collectCourseArray objectAtIndex:indexPath.row];
        [self deleteCollectCourseWithId:[[dic objectForKey:kCourseID] intValue]];
    }
}
#pragma mark - HYSegmentedControl 代理方法
- (void)hySegmentedControlSelectAtIndex:(NSInteger)index
{
    [self.scrollView setContentOffset:CGPointMake(index * _scrollView.hd_width, 0) animated:NO];
}
@end