//
//  ATLogController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/23.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATLogController.h"
#import "YYKit.h"
#import <Masonry.h>
#import <NSObject+YYAddForKVO.h>

#define kDateWidth 60
#define kMarging 8

@interface YYTextAsyncExampleCell : UITableViewCell
@property (nonatomic, strong) YYLabel *dateLabel;
@property (nonatomic, strong) YYLabel *yyLabel;
@end


@implementation YYTextAsyncExampleCell {
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _yyLabel = [YYLabel new];
    _yyLabel.font = [UIFont systemFontOfSize:10];
    _yyLabel.numberOfLines = 0;
    _yyLabel.displaysAsynchronously = YES;
    [self.contentView addSubview:_yyLabel];
    _dateLabel = [YYLabel new];
    _dateLabel.font = [UIFont systemFontOfSize:10];
    _dateLabel.numberOfLines = 1;
    _dateLabel.displaysAsynchronously = YES;
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = UIColorHex(0x878787);
    [self.contentView addSubview:_dateLabel];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _dateLabel.frame = CGRectMake(0, kMarging/2, kDateWidth, 13);
    _yyLabel.frame = CGRectMake(_dateLabel.right+kMarging, kMarging/2, self.contentView.width - _dateLabel.right - kMarging * 2, self.contentView.height - kMarging);
}

@end


@interface ATLogController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<YYTextLayout *> *layouts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ATBTData *> *logs;
@end

@implementation ATLogController
+ (instancetype)vcWithLogs:(NSArray<ATBTData *> *)logs {
    ATLogController *vc = [[self alloc] init];
    vc.logs = logs;
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史记录";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tableView.superview);
    }];
    [self updateData];
}

#pragma mark - actions
- (void)share {
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < self.logs.count; i++) {
        ATBTData *log = self.logs[i];
        [string appendFormat:@"%@ %@\r\n", [log.date stringWithFormat:@"mm:ss.SSS:"], log.text];
    }
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                            animated:YES
                                          completion:^{
                                          }];
}
- (void)updateData {
    NSDictionary *logAttrDic = @{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                 NSForegroundColorAttributeName : UIColorHex(0x404040)};
    NSDictionary *logWriteAttrDic = @{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                      NSForegroundColorAttributeName : UIColorHex(0x0000ff)};
    [self.layouts removeAllObjects];
    for (int i = 0; i < self.logs.count; i++) {
        ATBTData *log = self.logs[i];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:log.text ?: @" "
                                                                   attributes:[log isKindOfClass:[ATBTDataW class]] ? logWriteAttrDic : logAttrDic];
        
        // it better to do layout in background queue...
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - kDateWidth - kMarging * 2, CGFLOAT_MAX)];
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:text];
        [self.layouts addObject:layout];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layouts.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.layouts[indexPath.row].textBoundingSize.height + kMarging;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTextAsyncExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    cell.yyLabel.textLayout = self.layouts[indexPath.row];
    cell.dateLabel.text = [self.logs[indexPath.row].date stringWithFormat:@"mm:ss.SSS:"];
    return cell;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.frame = self.view.bounds;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[YYTextAsyncExampleCell class] forCellReuseIdentifier:@"id"];
    }
    return _tableView;
}
- (NSMutableArray<YYTextLayout *> *)layouts {
    if (!_layouts) {
        _layouts = [NSMutableArray array];
    }
    return _layouts;
}
@end
