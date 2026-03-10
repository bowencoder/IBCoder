//
//  IBGroup3Controller17.m
//  MBCoder
//
//  Created by 叶修 on 2026/3/10.
//  Copyright © 2026 inke. All rights reserved.
//

#import "IBGroup3Controller17.h"

@interface IBGroup3Controller17 ()

@end

@implementation IBGroup3Controller17

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end

/*
 Openclaw架构是什么？Openclaw架构介绍
 
 OpenClaw 是一个基于 控制平面（Control Plane） 与 执行平面（Execution Plane） 分离设计的自主智能体框架。
 其核心价值在于通过分布式的“网关-节点”架构，实现跨设备、多渠道的 AI 自动化操作。
 
 本文大纲
 🌐 网关层 (Gateway)：系统的“指挥中枢”与路由引擎

 🤖 节点层 (Node/Agent)：分布在终端的“执行肢体”

 🧩 技能与工作区 (Skills & Workspace)：能力扩展与数据隔离

 🔄 闭环工作流：从指令接收到工具调用的全过程

 1. 网关层 (Gateway)：系统的指挥中枢 🌐
 网关是 OpenClaw 架构中的核心控制节点，通常建议部署在 24 小时在线的服务器或云主机上。

 多渠道集成：负责对接 WhatsApp、Telegram、Slack、Discord 及 WebChat 等外部接口。

 路由规则：管理用户指令分发，决定将任务路由至哪一个具体的执行节点（如你的 Mac、公司服务器或手机）。

 状态同步：维护所有连接节点的活跃状态、配置信息及全局上下文。

 关键端口：默认通常占用 18789 (WebSocket 通信) 及 18790 (Web 管理后台)。

 2. 节点层 (Node/Agent)：分布式的执行肢体 🤖
 节点是真正“干活”的进程，安装在用户需要操作的具体设备上。

 环境感应：节点能够获取宿主系统的文件系统、进程列表及 GUI 视觉信息。

 本地执行：根据网关下发的指令，在本地环境运行 Shell 脚本、AppleScript 或 Python 代码。

 安全隔离：支持通过 Docker 或 Sandbox 运行不信任的代码，确保执行过程不损坏宿主系统。

 3. 技能与工作区 (Skills & Workspace) 🧩
 这是 OpenClaw 的能力底座，通过模块化插件实现功能解耦。

 Skills (技能)：基于 MCP (Model Context Protocol) 协议或原生 JSON 定义。每个技能包含“描述、参数 Schema、执行逻辑”三要素，告知模型“我能做什么”。

 Workspaces (工作区)：逻辑上的任务隔离。不同的工作区可以关联不同的模型（如研发用 DeepSeek，文案用 Claude）及特定的文件访问权限。

 Canvas (画布)：可视化交互界面，用于展示 AI 生成的代码、图表或复杂的交互式 UI。

 4. 闭环工作流：架构运行逻辑 🔄
 一个完整的任务在架构中的流转路径如下：

 输入接收：用户通过 Telegram 发送“帮我查一下 CPU 占用”。

 网关路由：网关接收消息，识别用户身份，并将其路由至对应的 Home_Mac 节点。

 模型推理：网关调用配置的 LLM（如 DeepSeek-R1），模型返回工具调用指令：execute_shell("top -n 1")。

 本地执行：Home_Mac 节点执行该 Shell 命令并捕获返回的文本。

 结果反馈：节点将执行结果传回网关 -> 网关传给 LLM -> LLM 总结文字 -> 发回 Telegram。

 总结
 OpenClaw 的架构精髓在于解耦。网关解决了“如何连接 AI”的问题，节点解决了“如何操作本地系统”的问题，而 MCP 协议解决了“如何扩展技能”的问题。这种分层设计使得它既能轻量化运行在树莓派，也能规模化部署在企业私有云。
 
 
 */
