//
//  CansultTeachersListView.m
//  Accountant
//
//  Created by aaa on 2017/11/2.
//  Copyright © 2017年 tianming. All rights reserved.
//

#import "CansultTeachersListView.h"
#import "SettingTableViewCell.h"
#define kSettingCellID @"SettingTableViewCellID"

@interface CansultTeachersListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;


@end

@implementation CansultTeachersListView

- (instancetype)initWithFrame:(CGRect)frame andTeachersArr:(NSArray *)array
{
    if (self = [super initWithFrame:frame]) {
        self.teachersArray = array;
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI
{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    backView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
    [self addSubview:backView];
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAction)];
    [backView addGestureRecognizer:backTap];
    
    self.teachersArray = @[@""];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenHeight - self.teachersArray.count * 50 - 50 - 80, kScreenWidth, self.teachersArray.count * 50 + 50 + 80) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingTableViewCell" bundle:nil] forCellReuseIdentifier:kSettingCellID];
    [self addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingCellID forIndexPath:indexPath];
    cell.iconImageView.image = [UIImage imageNamed:@"img_tx"];
    cell.titleLB.text = @"张三";
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel * titleLB = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth, 15)];
    titleLB.text = @"在线咨询";
    titleLB.textColor = kMainTextColor;
    titleLB.font = kMainFont;
    titleLB.textAlignment = 1;
    [headView addSubview:titleLB];
    
    UILabel * contentLB = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(titleLB.frame) + 5, kScreenWidth - 30, 40)];
    contentLB.text = @"可在此咨询关于课程的内容、价格、售前、售后服务等相关信息";
    contentLB.numberOfLines = 0;
    contentLB.textColor = kCommonMainTextColor_150;
    contentLB.font = kMainFont;
    [headView addSubview:contentLB];
    
    return headView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, kScreenWidth, 50);
    cancelBtn.backgroundColor = UIRGBColor(245, 245, 245);
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    return cancelBtn;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (void)dismissAction
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

@end