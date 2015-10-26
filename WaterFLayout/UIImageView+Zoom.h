//
//  UIImageView+Zoom.h
//  WaterFLayout
//
//  Created by qingqing on 15/4/28.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import <UIKit/UIKit.h>

void zoom(CGRect rect, UIImage *image, NSString *urlString);

@interface UIImageView_Zoom : UIScrollView

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, copy) void (^tapBlock)(UIImageView_Zoom *sender);

@end
