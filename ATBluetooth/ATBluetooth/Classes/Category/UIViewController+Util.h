//
//  UIViewController+Util.h
//  YAMI
//
//  Created by Apple on 14-9-6.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UIViewController (Util)

@property(nonatomic, weak)UITapGestureRecognizer *tapGestureRecognizer;
@property(nonatomic, weak)UIView *currentInput;
@property(nonatomic, weak)UIView *currentFocus;
@property(nonatomic, weak)UIView *currentTextFiledChangeView;
@property(nonatomic, assign)CGRect currentFocusRect;
@property(nonatomic, assign, readonly)CGRect currentTextFailedChangeViewOldFrame;

- (void)currentInputResignFirstResponder;
- (void)didTapAnywhere:(UITapGestureRecognizer*) recognizer;

/**
 *  设置导航栏标题
 */
- (void)setNavTitle:(NSString *)title;
/**
 *  返回上一个界面
 */
- (void)goBack;
- (void)goBack:(BOOL)animated;

- (instancetype)topPresentedVC;
+ (instancetype)rootTopPresentedVC;
@end
