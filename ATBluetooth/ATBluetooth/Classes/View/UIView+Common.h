//
//
#import <UIKit/UIKit.h>

@interface UIView (Common)

/**
 *	@brief	获取左上角横坐标
 *
 *	@return	坐标值
 */
- (CGFloat)left;

/**
 *	@brief	获取左上角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)top;

/**
 *	@brief	获取视图右下角横坐标
 *
 *	@return	坐标值
 */
- (CGFloat)right;

/**
 *	@brief	获取视图右下角纵坐标
 *
 *	@return	坐标值
 */
- (CGFloat)bottom;

/**
 *	@brief	获取视图宽度
 *
 *	@return	宽度值（像素）
 */
- (CGFloat)width;
/**
 *	@brief	获取视图高度
 *
 *	@return	高度值（像素）
 */
- (CGFloat)height;
/**
 *  设置view的宽度
 *
 *  @param width 宽度值(像素)
 */
- (void)setWidth:(CGFloat)width;
/**
 *  设置view的高度
 *
 *  @param height 高度在(像素)
 */
- (void)setHeight:(CGFloat)height;
/**
 *  设置view左上角横坐标
 *
 *  @param x view左上角横坐标
 */
- (void)setLeft:(CGFloat)x;
/**
 *  设置view左上角纵坐标
 *
 *  @param y view左上角纵坐标
 */
- (void)setTop:(CGFloat)y;

/**
 *	@brief	删除所有子对象
 */
- (void)removeAllSubviews;

/**
 *  获取view所在的viewController
 *
 *  @return view的父VC
 */
- (UIViewController *)getViewController;

/**
 *  获取view所在的navigationController
 *
 *  @return view的父NV
 */
- (UINavigationController *)getNavigationController;

/**
 *  获取view所在的ScrollView
 *
 *  @return view的父ScrollView
 */
- (UIScrollView *)getSuperScrollView;
- (UIImage *)capture;
@end
