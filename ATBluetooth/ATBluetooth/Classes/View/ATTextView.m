//
//  ATTextView.m
//  YAMI
//
//  Created by xiao6 on 14-10-19.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import "ATTextView.h"
#import "UIView+Common.h"
#import "UIViewController+Util.h"

@implementation ATTextView
#pragma mark -- 键盘状态 高度改变
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    UIViewController *vc = [self getViewController];
    // 使能手势
    if (vc && vc.tapGestureRecognizer != nil) {
        vc.tapGestureRecognizer.enabled = YES;
    }
    
    if(self != vc.currentInput){
        return;
    }
    UIScrollView *mutableSuperView = [self getSuperScrollView];
    if (!(vc && mutableSuperView)) {
        return;
    }
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    keyboardRect = [vc.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = mutableSuperView.frame;
    newTextViewFrame.size.height = keyboardTop - mutableSuperView.frame.origin.y;
    
    if (vc.currentTextFiledChangeView != nil ) {
        if (vc.currentTextFiledChangeView == mutableSuperView
            && vc.currentTextFiledChangeView.frame.size.height == newTextViewFrame.size.height) {
            return;
        }
    }
    
    // Get keyboard's duration of the animation and curve.
    NSTimeInterval animationDuration;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    vc.currentTextFiledChangeView = mutableSuperView;
    if (newTextViewFrame.size.height != 0 && newTextViewFrame.size.width != 0) {
        vc.currentTextFiledChangeView.frame = newTextViewFrame;
    }
    [UIView commitAnimations];
    
    //    ATLog(@"%@, %f ==> %f", vc.currentTextFiledChangeView, vc.currentTextFailedChangeViewOldFrame.size.height, newTextViewFrame.size.height);
    
    //滚动到当前输入框
    UIScrollView *scrollView = (UIScrollView *)vc.currentTextFiledChangeView;
    CGRect rect = [vc.currentInput convertRect:vc.currentInput.bounds toView:vc.currentTextFiledChangeView];
    [scrollView scrollRectToVisible:rect animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIViewController *vc = [self getViewController];
    // 禁用手势
    if (vc && vc.tapGestureRecognizer != nil) {
        vc.tapGestureRecognizer.enabled = NO;
    }
    
    if (vc == nil || vc.currentTextFiledChangeView == nil) {
        return;
    }
    if (self != vc.currentInput) {
        return;
    }
    // Get keyboard's duration of the animation and curve.
    NSTimeInterval animationDuration;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    if (vc.currentTextFailedChangeViewOldFrame.size.height != 0 && vc.currentTextFailedChangeViewOldFrame.size.width != 0) {
        vc.currentTextFiledChangeView.frame = vc.currentTextFailedChangeViewOldFrame;
    }
    [UIView commitAnimations];
    //    ATLog(@"%@, %f ==> %f", vc.currentTextFiledChangeView, vc.currentTextFailedChangeViewOldFrame.size.height, vc.currentTextFiledChangeView.frame.size.height);
    
    //滚动到当前输入框
    UIScrollView *scrollView = (UIScrollView *)vc.currentTextFiledChangeView;
    CGRect rect = [vc.currentInput
                   convertRect:vc.currentInput.bounds
                   toView:vc.currentTextFiledChangeView];
    [scrollView scrollRectToVisible:rect animated:YES];
    vc.currentTextFiledChangeView = nil;
}
@end

