//
//  ATTextBaseView.h
//  YAMI
//
//  Created by xiao6 on 14-10-22.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATTextViewDelegate <NSObject>
@optional
- (BOOL)textViewShouldReturn:(UITextView *)textView;
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UITextView *)textView;
- (void)textViewDidChangeSelection:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
@end

@interface ATTextViewDelegateImp : NSObject<UITextViewDelegate>
@property(nonatomic, weak)  id <ATTextViewDelegate> delegate;
@end

@interface ATTextBaseView : UITextView
/**
 *  提示用户输入的标语
 **/
@property(nonatomic,copy)     NSString               *placeholder;          // default is nil. 70% gray
@property(nonatomic,assign)   BOOL            placeholderMutiLines; // default is NO
/**
 *  协议代理
 **/
@property(nonatomic,weak)   id <ATTextViewDelegate> ATDelegate;


/**
 *  获取自身文本占据有多少行
 *
 *  @return 返回行数
 */
- (NSUInteger)numberOfLinesOfText;

/**
 *  获取每行的高度
 *
 *  @return 根据iPhone或者iPad来获取每行字体的高度
 */
+ (NSUInteger)maxCharactersPerLine;

/**
 *  获取某个文本占据自身适应宽带的行数
 *
 *  @param text 目标文本
 *
 *  @return 返回占据行数
 */
+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;

/**
 *  键盘监听
 **/
- (void)keyboardChangeFrame:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
@end
