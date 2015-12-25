//
//  ATTextInputController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/22.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATTextInputController.h"
#import "UIViewController+Util.h"
#import <YYTextView.h>
#import <Masonry/Masonry.h>
#import "DOKeyboard.h"

@interface ATTextInputController () <YYTextViewDelegate>
@property (nonatomic, strong) YYTextView *textView;

@property (nonatomic, copy) ATTextInputCompletion completion;
@property (nonatomic, assign) BOOL isHex;
@end

@implementation ATTextInputController
+ (instancetype)VCWithType:(BOOL)isHex completion:(ATTextInputCompletion)completion {
    ATTextInputController *vc = [[self alloc] init];
    vc.isHex = isHex;
    vc.completion = completion;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavTitle:@"编辑"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finish)];
    
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textView.superview);
    }];
    if (self.isHex) {
        DOKeyboard *keyboard = [DOKeyboard keyboardWithType:DOKeyboardTypeHex];
        keyboard.input = self.textView;
    }
    [self.textView becomeFirstResponder];
}

#pragma mark - actions
- (void)finish {
    [self.view endEditing:YES];
    if (self.completion) {
        self.completion(self.textView.text);
        self.completion = nil;
    }
    [self goBack];
}
- (void)goBack {
    self.completion = nil;
    [super goBack];
}

#pragma mark - getter
- (YYTextView *)textView {
    if (!_textView) {
        _textView = [[YYTextView alloc] init];
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = [UIColor colorWithWhite:0x40/255.0 alpha:1.0f];
        _textView.placeholderText = @"请输入文字...";
        _textView.placeholderTextColor = [UIColor colorWithWhite:0x87/255.0 alpha:1.0f];
        _textView.delegate = self;
    }
    return _textView;
}
@end
