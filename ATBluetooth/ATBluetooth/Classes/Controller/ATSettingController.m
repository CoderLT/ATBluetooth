//
//  ATSettingController.m
//  ATBluetooth
//
//  Created by 敖然 on 15/12/25.
//  Copyright © 2015年 AT. All rights reserved.
//

#import "ATSettingController.h"
#import <YYKit.h>
#import "UIView+Common.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>


@interface ATSettingController () <MFMailComposeViewControllerDelegate>

@end

@implementation ATSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBottom];// 底部按钮
}
- (void)initBottom {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height - 100 - 64, self.view.width, 100)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHexString:@"#a7a7a7"];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = [NSString stringWithFormat:@"Ver%@\r\n@2015 CoderLT", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [self.view addSubview:label];
    [self.view sendSubviewToBack:label];
}
#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self sendMailInApp];
            break;
        case 1: {
            UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:@[@"蓝牙助手", [NSURL URLWithString:APP_UPDATE]]
                                              applicationActivities:nil];
            [self.navigationController presentViewController:activityViewController
                                                    animated:YES
                                                  completion:^{
                                                  }];
            break;
        }
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_COMMENT]];
            break;
            
        default:
            break;
    }
    NSLog(@"%@", indexPath);
}

#pragma mark - 在应用内发送邮件
//激活邮件功能
- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self launchMailApp];
        return;
    }
    if (![mailClass canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:@"蓝牙助手-用户反馈" message:@"请将您的宝贵意见发送邮件到290907999@qq.com." delegate:nil cancelButtonTitle:@"确定并复制邮箱" otherButtonTitles:nil] show];
        [UIPasteboard generalPasteboard].string = @"290907999@qq.com";
        return;
    }
    [self displayMailPicker];
}

#pragma mark - 使用系统邮件客户端发送邮件
-(void)launchMailApp
{
    NSMutableString *mailUrl = [[NSMutableString alloc]init];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"290907999@qq.com"];
    [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
    //添加主题
    [mailUrl appendString:@"?subject=蓝牙助手-用户反馈"];
    //添加邮件内容
    [mailUrl appendFormat:@"&body=\t我的设备: %@, iOS %@\r\n\r\n\r\n\t", [[UIDevice currentDevice] machineModelName], [[UIDevice currentDevice] systemVersion]];
    NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"蓝牙助手-用户反馈"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"290907999@qq.com"];
    [mailPicker setToRecipients:toRecipients];
    
    NSString *emailBody = [NSString stringWithFormat:@"\t我的设备: %@, iOS %@\r\n\r\n\r\n\t", [[UIDevice currentDevice] machineModelName], [[UIDevice currentDevice] systemVersion]];
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:^{
        
    }];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *msg;
        switch (result) {
            case MFMailComposeResultCancelled:
                msg = @"用户取消编辑邮件";
                break;
            case MFMailComposeResultSaved:
                msg = @"用户成功保存邮件";
                break;
            case MFMailComposeResultSent:
                msg = @"用户点击发送，将邮件放到队列中，还没发送";
                [SVProgressHUD showInfoWithStatus:@"感谢您的宝贵意见, 我们会第一时间给您反馈"];
                break;
            case MFMailComposeResultFailed:
                msg = @"用户试图保存或者发送邮件失败";
                break;
            default:
                msg = @"";
                break;
        }
    }];
}

@end
