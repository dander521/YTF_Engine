/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Config definition.
 * =============================================================================
 */

#ifndef ConfigDefinition_h
#define ConfigDefinition_h

#pragma mark - Custom Config

#define Config_AppId                @"id" // 应用id
#define Config_IndexSrc             @"indexSrc" // 启动页路径
#define Config_Extend               @"extend" // 插件

// preference
#define Config_Preference           @"preference" // 设置
#define Config_AppBG                @"appBg" // app背景颜色
#define Config_WindowBG             @"winBg" // window背景颜色
#define Config_FrameBG              @"frameBg" // frame背景颜色
#define Config_FrameGroupBG         @"frameGroupBg" // frame背景颜色

#define Config_WindowBounce         @"winBounce" // window页面是否弹动
#define Config_FrameBounce          @"frameBounce" // frame页面是否弹动
#define Config_HScrollBar           @"hScrollBar" // 水平滚动条
#define Config_VScrollBar           @"vScrollBar" // 垂直滚动条
#define Config_AutoLaunch           @"autoLaunch" // 启动页是否自动隐藏
#define Config_StatusBarAppearance  @"statusBarAppearance" // 沉浸式效果
#define Config_FullScreen           @"fullScreen" // 全屏运行
#define Config_SoftKeyboardMode     @"softKeyboardMode" // 键盘弹出方式
#define Config_WebViewScale         @"isScale" // 页面是否缩放
#define Config_Debug                @"debug" // 页面是否缩放
#define Config_leftZone             @0.6 // 侧滑的有效范围
#define Config_leftEdge             @0.6 // 侧滑的显示范围



#pragma mark - Default Config

#define Default_AppBG                @"rgba(0,0,0,0)" // app背景颜色
#define Default_WindowBG             @"rgba(0,0,0,0)" // window背景颜色
#define Default_FrameBG              @"rgba(0,0,0,0)" // frame背景颜色
#define Default_FrameGroupBG         @"rgba(0,0,0,0)" // frame背景颜色
#define Default_WindowBounce         @"0" // window页面是否弹动
#define Default_FrameBounce          @"0" // frame页面是否弹动
#define Default_WebViewScale         @"0" // 页面是否缩放
#define Default_HScrollBar           @"1" // 水平滚动条
#define Default_VScrollBar           @"1" // 垂直滚动条
#define Default_AutoLaunch           @"1" // 启动页是否自动隐藏
#define Default_StatusBarAppearance  @"0" // 沉浸式效果
#define Default_FullScreen           @"0" // 全屏运行
#define Default_isReload             @"0" // 页面已经打开时，是否重新加载页面
#define Default_isEditConfuse        @"document.documentElement.style.webkitUserSelect='none';" // 不允许长按页面时弹出选择菜单
#define Default_isEditAllow          @"document.documentElement.style.webkitUserSelect='auto';" // 允许长按页面时弹出选择菜单
#define Default_isScroll             @"1" // frame 组是否能够左右滚动
#define Default_isLoop               @"1" // frame 组是否可以循环滑动，滑动到最后返回第一个frame
#define Default_isCheckboxMutable    9   // 最多允许选择九张图片
#define Default_isCheckbox           1   // 默认只支持选择一张图片
#define Default_isPicEditConfuse     @"0" // 默认不支持裁剪
#define Default_isPicEdit            @"1" // 支持裁剪

#define Default_leftZone             @0.3 // 侧滑的手势相应区域
#define Default_leftEdge             @0.6 // 侧滑的sideWin显示的区域大小








#define Default_SoftKeyboardMode     @"auto" // 键盘弹出方式

#endif /* ConfigDefinition_h */
