  # CET4词汇记忆
  
- 基于HarmonyOS NEXT (ArkUI) 开发的英语四级词汇记忆应用，通过四选一选择题帮助大学生高效记忆四级单词。
+ 基于 HarmonyOS NEXT (ArkUI) 开发的英语四级词汇记忆应用，通过四选一选择题帮助大学生高效记忆四级单词。支持手机、平板、2in1 设备和穿戴设备多端部署，自适应响应式布局。
  
  ## 功能介绍
  
  ### 词汇答题
- - 系统从词库中随机生成四选一题目，展示一个单词及四个候选释义
+ - 系统从 4700+ 词库中随机生成四选一题目，展示一个单词及四个候选释义
  - 优先出待学习词汇，全部掌握后从已掌握词汇中出题
  - 选择后即时反馈对错，答错显示正确释义
- - 连续答对3次自动标记为"已掌握"，答错则重置
+ - 连续答对 3 次自动标记为"已掌握"，答错则重置连续计数
+ - 答题会话自动持久化，中断后可恢复上次进度
  
  ### 生词本
  - 答题时点击单词旁的收藏按钮，将较难词汇添加到生词本
  - 生词本页面按收藏时间倒序展示所有已收藏词汇
  - 支持在生词本中取消收藏
  
  ### 学习进度
  - 查看已掌握/待学习词汇数量及总体正确率
  - 按掌握状态分组浏览词汇列表
  
  ### 学习统计
- - 2×3网格展示6项指标：总词汇数、已掌握、待学习、总体正确率、今日答题数、今日正确率
+ - 2×3 网格展示 6 项指标：总词汇数、已掌握、待学习、总体正确率、今日答题数、今日正确率
  
  ### 词汇浏览
  - 浏览全部四级词汇，支持按掌握状态筛选
  - 支持前缀搜索快速查找单词
  
+ ## 多端部署
+ 
+ ### 支持设备类型
+ 
+ | 设备类型 | 说明 |
+ |---------|------|
+ | phone | 手机 |
+ | tablet | 平板 |
+ | 2in1 | 二合一设备 |
+ | wearable | 穿戴设备（手表） |
+ 
+ ### 响应式断点体系
+ 
+ 应用基于 4 级断点系统实现自适应布局，根据屏幕宽度自动切换界面形态：
+ 
+ | 断点 | 宽度范围 | 典型设备 | 导航方式 | 布局策略 |
+ |------|---------|---------|---------|---------|
+ | XS | < 220vp | 穿戴设备 | 顶部导航 | 单列布局、竖向答题、最小化统计 |
+ | SM | 220–600vp | 手机 | 底部导航 | 单列布局、竖向答题、简单统计 |
+ | MD | 600–840vp | 平板 | 侧边导航 | 双列布局、水平分屏答题、详细统计 |
+ | LG | > 840vp | 2in1 设备 | 永久侧边导航 | 三列布局、水平分屏答题、详细统计 |
+ 
+ ### 多端适配特性
+ 
+ - **自适应导航**：手机底部 Tab 导航 → 平板侧边导航栏 → 2in1 永久侧边栏
+ - **自适应答题**：小屏竖向排列 → 大屏左右分屏（题目区 + 选项区）
+ - **自适应统计**：小屏精简指标 → 大屏完整 6 项指标网格
+ - **穿戴设备强制适配**：检测 `wearable` 设备类型，强制使用 XS 断点布局
+ - **窗口尺寸监听**：运行时动态响应窗口大小变化，实时切换断点（200ms 防抖）
+ - **深色模式**：完整的亮色/深色主题颜色体系，跟随系统切换
+ 
+ ### 跨设备能力
+ 
+ - **设备迁移**：支持 HarmonyOS 无缝迁移（`continuable: true`），答题进度、收藏、学习数据完整迁移到目标设备
+ - **分布式数据同步**：预留分布式数据同步能力（`ohos.permission.DISTRIBUTED_DATASYNC`），跨设备学习进度同步
+ - **数据备份恢复**：集成 `BackupExtensionAbility`，支持系统级数据备份与恢复
+ 
  ## 技术栈
  
- - **UI框架**：ArkUI (HarmonyOS NEXT API 12+)
- - **数据持久化**：RDB关系型数据库 + Preferences轻量存储
- - **词库规模**：4700+条CET4核心词汇
- - **特性**：纯本地应用、深色模式适配、答题会话中断恢复
+ | 类别 | 技术 |
+ |------|------|
+ | UI 框架 | ArkUI 声明式开发范式 |
+ | 开发语言 | ArkTS |
+ | 目标 API | HarmonyOS NEXT API 12+（SDK 6.0.2） |
+ | 数据持久化 | RDB 关系型数据库 + Preferences 轻量存储 |
+ | 构建工具 | Hvigor 6.0.2 |
+ | 架构模式 | MVVM（Page → ViewModel → Service） |
+ 
+ ### 使用的 HarmonyOS Kit
+ 
+ - `@kit.ArkData` — RDB 数据库、Preferences
+ - `@kit.ArkUI` — UI 组件、router 导航、window 窗口管理
+ - `@kit.AbilityKit` — UIAbility、AbilityConstant、Want
+ - `@kit.PerformanceAnalysisKit` — hilog 日志
+ - `@kit.CoreFileKit` — 备份恢复
+ 
+ ## 项目结构
+ 
+ ```
+ entry/src/main/ets/
+ ├── entryability/          # 应用入口 Ability
+ ├── entrybackupability/    # 备份恢复扩展
+ ├── pages/                 # 页面（6 个）
+ │   ├── Index.ets          # 首页
+ │   ├── QuizPage.ets       # 答题页
+ │   ├── ProgressPage.ets   # 学习进度页
+ │   ├── StatsPage.ets      # 学习统计页
+ │   ├── VocabListPage.ets  # 词汇浏览页
+ │   └── FavoritePage.ets   # 生词本页
+ ├── components/            # UI 组件（9 个）
+ ├── service/               # 数据服务（7 个）
+ ├── viewmodel/             # 视图模型（8 个）
+ ├── model/                 # 数据模型（12 个）
+ └── common/                # 常量、日志、工具



<img width="236" height="517" alt="屏幕截图 2026-05-19 190057" src="https://github.com/user-attachments/assets/b316d41e-c105-496e-98ec-9734e0d39677" />
<img width="232" height="499" alt="屏幕截图 2026-05-19 185948" src="https://github.com/user-attachments/assets/66dd8f64-475a-43fd-9d9b-6982e8bcc964" />
<img width="226" height="504" alt="屏幕截图 2026-05-19 190017" src="https://github.com/user-attachments/assets/8949429c-3d29-4726-800f-bf12c08ce216" />
<img width="251" height="266" alt="image" src="https://github.com/user-attachments/assets/abf28ce1-03ed-4c9a-ad42-3ee593cab9c4" />
<img width="251" height="257" alt="image" src="https://github.com/user-attachments/assets/22aa375f-61c5-4561-8263-d1eb9b13c10f" />
