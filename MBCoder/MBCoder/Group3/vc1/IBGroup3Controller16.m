//
//  IBGroup3Controller16.m
//  MBCoder
//
//  Created by 叶修 on 2026/2/9.
//  Copyright © 2026 inke. All rights reserved.
//

#import "IBGroup3Controller16.h"

@interface IBGroup3Controller16 ()

@end

@implementation IBGroup3Controller16

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end

/*
 OpenSpec 与 SpecKit：AI 时代的规范驱动开发新实践
 https://jimmysong.io/zh/book/ai-handbook/sdd/openspec/
 
 1. 三阶段工作流
 OpenSpec 的核心工作流分为草案、审查/对齐、实施与归档三个阶段
 在实际操作中，用户在 openspec/changes/<change-id>/ 下创建或由 AI 生成以下文件：
 proposal.md：说明为何需要改动、影响范围及验收标准。
 tasks.md：分解后的实现任务清单。
 specs/ 子目录：仅包含 delta（新增/修改/移除/重命名）的规范片段。
 
 经审查并批准后，AI 按 tasks.md 顺序执行实现，并在完成后通过 Archive 命令将 delta 应用回 openspec/specs/，同时将 change 移入归档目录，保证 specs/ 始终代表当前事实。
 
 2. 目录与文件组织
 为了便于团队协作与规范管理，OpenSpec 推荐如下目录结构：

 openspec/
 ├── AGENTS.md            # 与不同 AI 工具约定的根级说明
 ├── project.md           # 项目上下文说明
 ├── specs/               # 当前事实（源）的规范集合
 │   └── capability-name/
 │       ├── spec.md
 │       └── design.md
 └── changes/             # 提案（每个提案一个子目录）
     └── change-name/
         ├── proposal.md
         ├── tasks.md
         └── specs/       # delta specs（只包含变动部分）


 
 
 */
