//
//  OrderLivingCourseOperation.h
//  Accountant
//
//  Created by aaa on 2017/7/20.
//  Copyright © 2017年 tianming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderLivingCourseOperation : NSObject
- (void)didRequestOrderLivingCourseWithCourseId:(int )courseid withNotifiedObject:(id<UserModule_OrderLivingCourseProtocol>)object;
@end
