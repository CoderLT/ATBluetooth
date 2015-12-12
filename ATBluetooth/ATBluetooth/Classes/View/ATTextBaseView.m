//
//  ATTextBaseView.m
//  YAMI
//
//  Created by xiao6 on 14-10-22.
//  Copyright (c) 2014年 Summer. All rights reserved.
//

#import "ATTextBaseView.h"
#import "UIView+Common.h"
#import "UIViewController+Util.h"

@interface ATTextBaseView()
{
    ATTextViewDelegateImp *delegateImp;
}
@end

@implementation ATTextBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    // 1.默认配置
    self.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f,0.0f,4.0f,1.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDone;
    self.textAlignment = NSTextAlignmentLeft;
    _placeholderMutiLines = NO;
    // 2.添加监听 处理placeholder
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    // 3.初始化代理传递链
    delegateImp = [[ATTextViewDelegateImp alloc] init];
    super.delegate = delegateImp;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    // 添加手势
    UIViewController *vc = [self getViewController];
    if (vc && vc.tapGestureRecognizer == nil) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:vc
                                                                                               action:@selector(didTapAnywhere:)];
        [vc.view addGestureRecognizer:tapGestureRecognizer];
        vc.tapGestureRecognizer = tapGestureRecognizer;
        vc.tapGestureRecognizer.enabled = NO;
    }
    // 添加监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void)keyboardChangeFrame:(NSNotification *)notification
{
    UIViewController *vc = [self getViewController];
    // 使能手势
    if (vc && vc.tapGestureRecognizer != nil) {
        vc.tapGestureRecognizer.enabled = YES;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIViewController *vc = [self getViewController];
    // 禁用手势
    if (vc && vc.tapGestureRecognizer != nil) {
        vc.tapGestureRecognizer.enabled = NO;
    }
}
- (void)setATDelegate:(id<ATTextViewDelegate>)delegate
{
    // 响应链传递
    _ATDelegate = delegate;
    delegateImp.delegate = _ATDelegate;
}


- (void)dealloc
{
    _placeholder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

#pragma mark - 重写uitextView 父类方法
- (void)setTextAlignment:(NSTextAlignment)textAlignment{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)insertText:(NSString *)text{
    [super insertText:text];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setPlaceholder:(NSString *)placeholder{
    if([placeholder isEqualToString:_placeholder]) {
        return;
    }
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderMutiLines:(BOOL)placeholderMutiLines
{
    _placeholderMutiLines = placeholderMutiLines;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if ([self.text length] == 0 && self.placeholder){
        UIColor *placeholderColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        CGRect placeHolderRect = CGRectMake(7.0f + self.textContainerInset.left,
                                            self.textContainerInset.top,
                                            rect.size.width - 2.0f - self.textContainerInset.left - self.textContainerInset.right,
                                            rect.size.height - self.textContainerInset.top - self.textContainerInset.right);
        [placeholderColor set];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        if (!_placeholderMutiLines) {
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        paragraphStyle.alignment = self.textAlignment;
        
        [self.placeholder drawInRect:placeHolderRect
                      withAttributes:@{ NSFontAttributeName : self.font,
                                        NSForegroundColorAttributeName : placeholderColor,
                                        NSParagraphStyleAttributeName : paragraphStyle }];
    }
}

- (NSUInteger)numberOfLinesOfText{
    return [ATTextBaseView numberOfLinesForMessage:self.text];
}

+ (NSUInteger)maxCharactersPerLine{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)?33:109;
}

+ (NSUInteger)numberOfLinesForMessage:(NSString *)text{
    return (text.length / [ATTextBaseView maxCharactersPerLine]) + 1;
}
@end

@implementation ATTextViewDelegateImp
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
        [_delegate textViewDidBeginEditing:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
        [_delegate textViewDidEndEditing:textView];
    }
    UIViewController *vc = [textView getViewController];
    if (vc.currentInput == textView) {
        [vc currentInputResignFirstResponder];
    }
}

- (BOOL)textView:(ATTextBaseView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        BOOL shouldReturn = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(textViewShouldReturn:)]) {
            shouldReturn = [_delegate textViewShouldReturn:textView];
        }
        if (shouldReturn) {
            [textView resignFirstResponder];
        }
        return !shouldReturn;
    }
    else if (_delegate && [_delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return [_delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(ATTextBaseView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [_delegate textViewDidChange:textView];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    BOOL begin = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
        begin = [_delegate textViewShouldBeginEditing:textView];
    }
    if (begin) {
        UIViewController *vc = [textView getViewController];
        if (vc != nil) {
            vc.currentInput = textView;
        }
    }
    return begin;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
        return [_delegate textViewShouldEndEditing:textView];
    }
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [_delegate textViewDidChangeSelection:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if (_delegate && [_delegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
        return [_delegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    if (_delegate && [_delegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
        return [_delegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    }
    return YES;
}

@end
