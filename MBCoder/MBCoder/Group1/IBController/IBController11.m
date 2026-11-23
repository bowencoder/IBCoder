//
//  IBController11.m
//  IBCoder1
//
//  Created by Bowen on 2018/5/8.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBController11.h"
#import "UIView+Ext.h"

/*
 ============================================================
 事件传递与响应 面试题总结
 ============================================================


 一、核心概念

 UIResponder：UIView / UIViewController / UIWindow / UIApplication；AppDelegate 需继承 UIResponder 才是响应者

 响应者链：nextResponder 串成的单向链表，事件向上冒泡时使用
 View →（普通 view 到 superview，控制器根 view 到 VC）→ … → Window → … → Application → nil
 AppDelegate 满足条件时可加入链路；使用 Scene 时还涉及 UIWindowScene，具体以 nextResponder 为准。

 First Responder：
 - 触摸 FR：Hit-Test 命中的最前方分支中最深层 view；命中不等于 becomeFirstResponder
 - 键盘 FR：becomeFirstResponder 成功对象（如 UITextField），与触摸 FR 可不同

 两个方向（必考）：
 - 事件传递：自顶向下 Hit-Testing，touch 开始时确定接收者（不保证 hitTest 只调用一次），定「谁收」
 - 事件响应：自底向上沿响应者链冒泡，定「不处理时交给谁」，未处理时调 [super touches...] 交给父类实现；父类可能处理，也可能继续向上转交

 二、事件流程（概念示意，不表示内部方法的严格调用顺序）

 触摸屏 → 系统将事件交给应用主线程（底层进程与 RunLoop Source 类型不是公开 API 保证）
 → UIApplication sendEvent: → UIWindow sendEvent:
 → Hit-Testing（自顶向下 hitTest:）→ 得到 hitView
 → 手势与视图参与同一触摸序列（手势先获得处理机会，并非多线程并行）：
     ① hitView 及父链上的 UIGestureRecognizer 识别
     ② hitView 的 touchesBegan / Moved / Ended / Cancelled（可被手势延迟或取消）
 → touches 调 super → 父类未处理时沿响应者链向上转交


 三、Hit-Testing（hitTest:withEvent:）

 ① 前置：允许交互、未隐藏且透明度足够（下方自定义实现用 alpha>0.01；不作为系统边界值保证）
 ② pointInside:withEvent:（默认 bounds 内；IBViewD 可扩大热区）
 ③ 倒序遍历 subviews，convertPoint:toView: 后递归子 view hitTest
 ④ 子 view 均 nil → return self

 四、四种事件处理路径（关系总览）

 四者不是独立模块：Hit-Test 确定 hitView，手势与 touches 参与同一触摸序列；
 UIControl 的 tracking 和控件事件建立在触摸处理之上。

        手指按下
            ↓
     Hit-Test（向下）→ hitView
            ↓ 手势先获得处理机会
     ┌──────┴──────────┐
     ↓                 ↓
  touches        GestureRecognizer
  原始流，可转交    识别序列语义
     ↓（控件）         ↓
  UIControl tracking   手势 target-action
     ↓
  控件 target-action（target 为 nil 时可沿响应者链查找）

 Hit-Test：系统自顶向下调 hitTest:，找最前方可命中分支中的最深 view；手势成功不会为同一 UITouch 重新选择 hitView。

 touches：原始触摸数据，各阶段（Began/Moved/Ended/Cancelled）按分发规则交给视图；
   未处理时调 [super touches...] 可向上转交；包含坐标、阶段、时间等，不直接提供手势语义。

 GestureRecognizer：与 touches 交错处理触摸序列，识别语义（单击/滑动）；
   识别成功调 action（参数 GestureRecognizer*），不走响应者链；
   cancelsTouchesInView=YES（默认）→ 取消已交给视图的触摸，丢弃待交付触摸；不保证视图先收到 Began。

 UIControl：通过 tracking 跟踪触摸，在相应阶段发 ControlEvent，不是统一等到 endTracking 后才发；
   控件仍处理 touches；自定义跟踪优先重写 tracking 方法，父视图通常收不到被控件消费的触摸。

 三种场景时序（正常完成的触摸；按钮示例假设在内部抬起并注册了 TouchUpInside action）
 · 普通 UIView（无手势）：  按下→Hit-Test→touchesBegan→[未处理时可经 super 转交]→touchesEnded
 · UIView 挂 Tap 手势：    按下→Hit-Test→Tap:Possible+touchesBegan→识别成功→action 与取消触摸
   （普通 UIView、默认配置的常见情况；不依赖 action 与 touchesCancelled 的相对顺序）
 · UIButton：              按下→Hit-Test→TouchDown→TouchUpInside→onClick

 关键属性（手势影响 touches）
 · cancelsTouchesInView=YES — 手势成功 cancel touches（默认）
 · cancelsTouchesInView=NO  — 不因手势成功取消视图触摸，不保证按钮 action 必定触发
 · delaysTouchesBegan=YES   — 暂缓交付开始阶段，等待手势判断；默认 NO

 UIButton vs UIGestureRecognizer 优先级与冲突
 没有统一的“手势优先级更高”：结果取决于控件默认行为、手势类型及安装位置。

 典型冲突：单击手势直接挂在 Button 自身上
   （父视图的单指单击手势通常让位于 UIButton 的默认单击，不能与直接挂在按钮上混为一谈）
   Hit-Test → hitView = UIButton
   手势参与识别；按钮是否已收到 TouchDown 取决于触摸延迟配置
   手指抬起 → TapGesture 识别成功 → onTap: 触发
   cancelsTouchesInView=YES → 已交付的触摸被取消，待交付的触摸被丢弃 → 本次 TouchUpInside 不触发

 解决方法：
 ① cancelsTouchesInView=NO — 允许 Button 继续接收触摸；若两者都触发，需处理重复响应
 ② 父视图手势的 delegate shouldReceiveTouch: — 排除 UIControl 区域（不适用于希望在按钮自身识别的手势）：
      - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gr shouldReceiveTouch:(UITouch *)touch {
          for (UIView *view = touch.view; view; view = view.superview) {
              if ([view isKindOfClass:[UIControl class]]) return NO;
          }
          return YES; // 同时排除控件内部可交互子视图
      }


 五、常见应用场景

 1. 扩大热区 — IBViewD 重写 pointInside:
 2. 子 view 超出父 bounds — 父 view 重写 pointInside/hitTest，并确保祖先路径允许命中；
    clipsToBounds=NO 只影响绘制裁剪，不会扩大触摸响应范围
 3. ScrollView 留边分页 — 父 view hitTest 把留边交给 scrollView
 4. 事件穿透 — hitTest 某区域 return nil
 5. 全局监听 — 子类 UIApplication 重写 sendEvent:
 6. 调试链 — IBViewD touchesBegan 遍历 nextResponder


 六、常见面试问答

 Q：Hit-Testing 和响应者链方向？
 A：Hit-Test 向下找 FR；响应者链从 FR 向上 nextResponder 冒泡。

 Q：Hit-Test、touches、手势、Target-Action 关系？
 A：Hit-Test 定 hitView → 手势先获得处理机会，按配置延迟/取消 touches；未处理的 touches 可向上转交；
    UIControl 在 tracking 的相应阶段产生控件事件（如 TouchDown、TouchUpInside）→对应 target-action。

 Q：手势识别后还向下传吗？
 A：不会因识别成功为同一 UITouch 重选 hitView；是否继续向视图交付触摸取决于取消、延迟配置。
    默认取消视图触摸；cancelsTouchesInView=NO 时可继续交付，手势识别本身不沿响应者链转交。

 Q：superview userInteractionEnabled=NO？
 A：默认 hitTest 在该视图处返回 nil，整棵子树不能成为新触摸的命中目标。

 Q：touchesEnded 没来？
 A：可能被手势或系统取消、view 被 remove，或因 delaysTouchesEnded 暂缓交付；检查取消回调和延迟配置。

 Q：UIButton vs UIView touchesBegan？
 A：Button 也处理 touches，并在此基础上 tracking、发送控件事件；UIView 可处理 touches 或挂手势。

 Q：A→B→C，手势加在 B（或 C）上，C 是 UIControl，点击后 TouchUpInside 为何不触发？如何解决？
 A：仅添加手势不会改变默认命中规则；以下假设本次触摸已命中 C（hitView = C）。
    若手势成功且 cancelsTouchesInView=YES，已开始的 tracking 可被取消，TouchUpInside 不触发。
    但安装位置不能混为一谈：C 为 UIButton 时，B 上的单指单击手势通常让位于按钮默认单击；
    直接装在 C 上的手势可优先处理；自定义 UIControl 或其他手势需看具体行为。
    解决：
    · 手势在父 view → delegate shouldReceiveTouch: 检查 touch.view 及其祖先是否为 UIControl，让手势放行
    · 手势在 C 自身 → cancelsTouchesInView=NO，或直接不加手势（UIControl 自带事件已够用）

 Q：两种 FR 区别？
 A：触摸 FR 由 Hit-Test 定；键盘 FR 由 becomeFirstResponder 定。
 */
@interface IBViewA : UIView

@end

@implementation IBViewA

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);

    // 1.判断下自己能否接收事件
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    
    // 2.判断下点在不在当前控件上
    if ([self pointInside:point withEvent:event] == NO) return  nil; // 点不在当前控件
    
    // 3.从后往前遍历自己的子控件，UIKit 中后添加的视图显示在前面，应优先检测
    int count = (int)self.subviews.count;
    for (int i = count - 1; i >= 0; i--) {
        // 获取子控件
        UIView *childView = self.subviews[i];
        
        // 把当前坐标系上的点转换成子控件上的点
        CGPoint childP =  [self convertPoint:point toView:childView];
        
        UIView *hitView = [childView hitTest:childP withEvent:event];
        
        if (hitView) {
            return hitView;
        }
        
    }
    // 4.如果没有比自己合适的子控件,最合适的view就是自己
    return self;
}

//此方法内使用bouds判断是否在本视图范围内
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
    
    return CGRectContainsPoint(self.bounds, point);
}

@end

@interface IBViewB : UIView

@end

@implementation IBViewB

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

@end

@interface IBViewC : UIView

@end

@implementation IBViewC

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

@end


@interface IBViewD : UIView

@end

@implementation IBViewD

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UIResponder *next = self; next; next = [next nextResponder]) {
        NSLog(@"响应者——>%@", next.class);
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
    return [super hitTest:point withEvent:event];
}
//扩大响应范围
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    CGRect rect = CGRectMake(self.bounds.origin.x - 100, self.bounds.origin.y, self.width + 200, self.height);
    return CGRectContainsPoint(rect, point);
}

@end


@interface IBController11 ()

@end

@implementation IBController11

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    IBViewA *viewA = [[IBViewA alloc] initWithFrame:CGRectMake(20, 100, self.view.width - 40, 300)];
    [self.view addSubview:viewA];
    IBViewB *viewB = [[IBViewB alloc] initWithFrame:CGRectMake(20, 50, viewA.width - 40, 200)];
    [viewA addSubview:viewB];
    IBViewC *viewC = [[IBViewC alloc] initWithFrame:CGRectMake(20, 50, viewB.width - 40, 100)];
    [viewB addSubview:viewC];
//    viewB.userInteractionEnabled = NO;
    
    IBViewD *viewD = [[IBViewD alloc] initWithFrame:CGRectMake(100, 500, self.view.width - 200, 80)];
    [self.view addSubview:viewD];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s",__func__);
}

@end
