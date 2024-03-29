//
//  ClassroomLivingTableViewCell.h
//  tiku
//
//  Created by aaa on 2017/5/12.
//  Copyright © 2017年 ytx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShakeView.h"



@interface ClassroomLivingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *payTypeLB;

@property (weak, nonatomic) IBOutlet UIImageView *livingStateImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLB;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLBLayoutLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *livingLBLayoutLeft;
@property (weak, nonatomic) IBOutlet UIImageView *bofangImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLBWidth;

@property (weak, nonatomic) IBOutlet UIImageView *livingIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *livingTitleleLabel;
@property (weak, nonatomic) IBOutlet UILabel *livingTeacherNameLB;

@property (weak, nonatomic) IBOutlet UIButton *stateBT;

@property (weak, nonatomic) IBOutlet UIView *markView;
@property (strong, nonatomic) ShakeView *shakeView;
@property (weak, nonatomic) IBOutlet UILabel *livingLabel;

@property (weak, nonatomic) IBOutlet UIImageView *CountDownImageView;
@property (weak, nonatomic) IBOutlet UILabel *countDowmLB;

@property (weak, nonatomic) IBOutlet UIImageView *teacherIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *teachernameLB;

@property (nonatomic, copy)void(^countDownFinishBlock)();

@property(nonatomic, assign)BOOL livingDetailVC;

@property (nonatomic, copy)void(^LivingPlayBlock)(LivingPlayType playType);

- (void)resetWithDic:(NSDictionary *)infoDic;

@end
