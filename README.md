# CET4词汇记忆 — 应用文档

## 一、应用概述

CET4词汇记忆是一款基于 HarmonyOS NEXT (ArkUI) 开发的英语四级词汇记忆应用。应用内置 4700+ 条 CET4 核心词汇，通过四选一选择题的交互方式帮助大学生高效记忆单词。应用采用 MVVM 分层架构，支持手机、平板、2in1 设备和穿戴设备多端部署，具备完整的响应式自适应布局、设备迁移、分布式数据同步和深色模式等能力。

---

## 二、功能详解

### 2.1 词汇答题

词汇答题是应用的核心功能，系统从词库中随机生成四选一题目，用户通过选择正确释义来记忆单词。

**出题策略：**
- 优先从"待学习"（LEARNING）词汇池中随机抽取目标单词
- 当所有词汇均已掌握后，从"已掌握"（MASTERED）词汇池中出题进行巩固复习
- 从全词库中随机选取 3 个不重复的干扰释义，与正确释义一起打乱排列

**答题反馈：**
- 选择后即时判断对错，答对显示绿色确认，答错显示红色提示并展示正确释义
- 每次答题结果自动记录到 `answer_record` 表，用于统计今日答题数据

**掌握判定：**
- 连续答对 3 次（`consecutiveCorrectCount >= 3`），词汇自动标记为"已掌握"（MASTERED）
- 答错一次即重置连续正确计数为 0，词汇状态回退为"待学习"（LEARNING）
- 正确计数和错误计数独立累计，不受连续计数重置影响

**答题会话：**
- 每次进入答题页自动创建新的答题会话（QuizSession），记录会话 ID、开始时间、已答题数和正确数
- 会话状态通过 Preferences 持久化存储，应用中断后可在下次启动时恢复未完成的会话
- 会话正常结束后自动清除持久化数据

### 2.2 生词本

生词本功能帮助用户收集和回顾较难的词汇。

**收藏操作：**
- 答题页面中，单词旁显示收藏按钮，点击即可将当前词汇添加到生词本
- 收藏状态通过 `is_favorite` 字段标记，收藏时间记录在 `favorite_time` 字段
- 支持切换收藏状态（toggleFavorite），已收藏可取消，未收藏可添加

**生词本浏览：**
- 生词本页面按收藏时间倒序展示所有已收藏词汇
- 每个词汇卡片显示单词、释义、词性和掌握状态
- 支持在生词本中直接取消收藏

### 2.3 学习进度

学习进度页面提供全局学习情况的概览和详细浏览。

**进度概览：**
- 显示总词汇数、已掌握数量、待学习数量
- 计算并展示总体正确率（正确数 / 总答题数 × 100%）

**分组浏览：**
- 支持按掌握状态（已掌握 / 待学习）分组浏览词汇列表
- 每个词汇项显示单词、释义、词性、正确/错误计数

### 2.4 学习统计

学习统计页面以卡片网格形式展示 6 项关键学习指标：

| 指标 | 说明 |
|------|------|
| 总词汇数 | 词库中的词汇总量 |
| 已掌握 | 掌握状态为 MASTERED 的词汇数 |
| 待学习 | 掌握状态为 LEARNING 的词汇数 |
| 总体正确率 | 历史答题正确数 / 总答题数 |
| 今日答题数 | 当日 0 点至今的答题总数 |
| 今日正确率 | 当日答题正确数 / 当日答题总数 |

今日数据的计算基于 `answer_record` 表的 `answer_time` 字段，以当日零点为起始时间进行筛选统计。

### 2.5 词汇浏览

词汇浏览页面提供全词库的浏览和检索功能。

**筛选功能：**
- 支持按掌握状态筛选：全部 / 已掌握 / 待学习

**搜索功能：**
- 支持前缀搜索，输入关键词后实时过滤匹配的词汇
- 搜索不区分大小写，匹配单词的开头部分

### 2.6 数据管理

**数据库设计：**

应用使用 RDB 关系型数据库（`cet4_vocab.db`，安全级别 S1），包含两张核心表：

`vocab_progress` 表 — 词汇进度：

| 字段 | 类型 | 说明 |
|------|------|------|
| word | TEXT PRIMARY KEY | 单词（主键） |
| meaning | TEXT | 释义 |
| pos | TEXT | 词性 |
| correct_count | INTEGER | 累计正确次数 |
| wrong_count | INTEGER | 累计错误次数 |
| consecutive_correct_count | INTEGER | 连续正确次数 |
| mastery_status | TEXT | 掌握状态（LEARNING / MASTERED） |
| is_favorite | INTEGER | 是否收藏（0 / 1） |
| favorite_time | INTEGER | 收藏时间戳 |
| last_modified_time | INTEGER | 最后修改时间戳 |

`answer_record` 表 — 答题记录：

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| target_word | TEXT | 目标单词 |
| selected_option | INTEGER | 用户选择的选项索引 |
| correct_option | INTEGER | 正确选项索引 |
| is_correct | INTEGER | 是否正确（0 / 1） |
| answer_time | INTEGER | 答题时间戳 |

**索引：** `idx_answer_time`、`idx_favorite_status`、`idx_favorite_time`、`idx_last_modified_time`

**数据初始化：** 首次启动时从 `rawfile/cet4_words.json` 批量导入词汇数据，所有词汇初始状态为 LEARNING，计数归零。

**数据库升级：** 应用通过 `ALTER TABLE` 增量升级方式添加 `is_favorite`、`favorite_time`、`last_modified_time` 字段及对应索引，兼容已有数据。

### 2.7 深色模式

应用提供完整的亮色 / 深色主题颜色体系：
- 亮色主题定义在 `resources/base/element/color.json`
- 深色主题定义在 `resources/dark/element/color.json`
- 应用启动时设置 `COLOR_MODE_NOT_SET`，跟随系统主题自动切换

---

## 三、多端部署

### 3.1 支持设备类型

应用在 `module.json5` 中声明支持以下四种设备类型：

| 设备类型 | 标识 | 典型形态 |
|---------|------|---------|
| 手机 | phone | 华为手机 |
| 平板 | tablet | 华为 MatePad |
| 二合一设备 | 2in1 | 华为 MateBook（触屏模式） |
| 穿戴设备 | wearable | 华为手表 |

### 3.2 响应式断点体系

应用基于 4 级断点系统实现自适应布局。`BreakpointService` 在应用启动时根据窗口尺寸计算初始断点，运行时通过监听 `windowSizeChange` 事件动态切换断点。

**断点定义：**

| 断点 | 宽度范围 | 典型设备 | 导航模式 | 列数 | 答题布局 | 统计详情级别 |
|------|---------|---------|---------|------|---------|------------|
| XS | < 220vp | 穿戴设备 | TOP_TAB（顶部导航） | 1列 | VERTICAL（竖向排列） | MINIMAL（最小化） |
| SM | 220–600vp | 手机 | BOTTOM_TAB（底部导航） | 1列 | VERTICAL（竖向排列） | SIMPLE（简单） |
| MD | 600–840vp | 平板 | SIDE_NAV（侧边导航） | 2列 | HORIZONTAL_SPLIT（水平分屏） | DETAILED（详细） |
| LG | > 840vp | 2in1 设备 | SIDE_NAV_PERMANENT（永久侧边导航） | 3列 | HORIZONTAL_SPLIT（水平分屏） | DETAILED（详细） |

**断点切换机制：**

1. **初始化**：`EntryAbility.onWindowStageCreate` 中获取主窗口尺寸，调用 `BreakpointService.init(width, height)` 计算初始断点
2. **运行时监听**：注册 `mainWindow.on('windowSizeChange')` 回调，窗口尺寸变化时调用 `BreakpointService.updateFromWindowSize(width, height)`
3. **防抖处理**：断点切换使用 200ms 防抖机制，避免窗口调整过程中频繁触发布局重算
4. **状态同步**：当前断点通过 `AppStorage.setOrCreate('currentBreakpoint', ...)` 全局共享，各组件通过 `@StorageLink` 响应变化

**穿戴设备特殊处理：**
- 通过 `deviceInfo.deviceType === 'wearable'` 检测穿戴设备
- 穿戴设备强制使用 XS 断点，忽略窗口尺寸变化对断点的影响
- 自动识别圆形屏幕（`isRoundScreen`），为圆形表盘提供额外的边距和圆角适配

### 3.3 布局策略

`BreakpointService.getLayoutStrategy()` 根据当前断点返回完整的布局策略对象 `LayoutStrategy`，包含：

| 属性 | 说明 | XS | SM | MD | LG |
|------|------|----|----|----|----|
| columnCount | 内容区列数 | 1 | 1 | 2 | 3 |
| navMode | 导航模式 | TOP_TAB | BOTTOM_TAB | SIDE_NAV | SIDE_NAV_PERMANENT |
| quizLayout | 答题布局 | VERTICAL | VERTICAL | HORIZONTAL_SPLIT | HORIZONTAL_SPLIT |
| statsDetailLevel | 统计详情级别 | MINIMAL | SIMPLE | DETAILED | DETAILED |
| supportHover | 支持悬停交互 | 否 | 否 | 否 | 是（2in1设备） |

### 3.4 响应式配置参数

每个断点对应一套完整的 UI 配置参数（`BreakpointConfig`），涵盖间距、字号、尺寸、圆角、阴影等 40+ 项参数，确保各设备形态下的视觉一致性和交互体验。关键配置对比：

| 配置项 | XS | SM | MD | LG |
|-------|----|----|----|----|
| 页面内边距 (padding) | 10vp | 20vp | 32vp | 48vp |
| 答题单词字号 (quizWordFontSize) | 24fp | 28fp | 48fp | 48fp |
| 统计数值字号 (statValueFontSize) | 18fp | 24fp | 32fp | 32fp |
| 标题字号 (titleFontSize) | 16fp | 20fp | 24fp | 24fp |
| 按钮最小宽度 (buttonMinWidth) | 100vp | 200vp | 240vp | 240vp |
| 选项最小高度 (optionMinHeight) | 24vp | 44vp | 48vp | 48vp |
| 统计网格列数 (gridColumns) | 1 | 1 | 2 | 3 |
| 内容最大宽度 (contentMaxWidth) | 无限制 | 400vp | 无限制 | 1200vp |
| 最小触控目标 (minTouchTarget) | 40vp | 44vp | 44vp | 44vp |

**圆形屏幕适配：** 穿戴设备为圆形表盘时，额外增加 14vp 水平内边距，卡片圆角调整为 20vp，按钮圆角调整为 22vp。

### 3.5 自适应导航

应用导航结构根据断点自动切换形态：

- **XS（穿戴设备）**：顶部 Tab 导航，节省纵向空间，适配小屏圆形表盘
- **SM（手机）**：底部 Tab 导航，符合手机单手操作习惯
- **MD（平板）**：可折叠侧边导航栏，充分利用横向空间
- **LG（2in1 设备）**：永久侧边导航栏，始终可见，支持鼠标悬停交互

### 3.6 自适应答题布局

答题页面的布局根据断点自动调整：

- **XS / SM（小屏）**：竖向排列，单词和选项自上而下依次展示，适合单手滑动操作
- **MD / LG（大屏）**：水平分屏布局，左侧展示题目区（单词 + 释义），右侧展示选项区，充分利用横向空间

### 3.7 自适应统计展示

统计页面的展示密度根据断点自动调整：

- **XS（穿戴设备）**：最小化展示，仅显示核心指标，单列排列
- **SM（手机）**：简单展示，2 列网格展示 6 项指标
- **MD / LG（大屏）**：详细展示，2-3 列网格展示完整 6 项指标，卡片尺寸更大

### 3.8 跨设备能力

#### 设备迁移

应用支持 HarmonyOS 设备迁移能力（Ability Continuation），可在设备间无缝转移学习数据。

**迁移流程：**

1. **数据序列化（onContinue）**：源设备调用 `MigrationService.serializeMigrationDataSync()`，将以下数据序列化为 JSON：
   - 所有词汇的进度数据（正确/错误计数、连续正确计数、掌握状态、最后修改时间）
   - 收藏列表（单词、收藏状态、收藏时间）
   - 当前答题会话（已答题数、正确数）
   - 当前页面状态（所在页面）

2. **数据恢复（onRestoreData）**：目标设备调用 `MigrationService.deserializeMigrationData()`，解析 JSON 并写入本地数据库：
   - 逐条比对 `lastModifiedTime`，仅更新比本地更新的记录（基于时间戳的冲突解决策略）
   - 版本号校验，确保数据格式兼容

3. **后台缓存**：应用进入后台时（`onBackground`）提前执行异步序列化，确保迁移时数据已就绪

**迁移配置：**
- `EntryAbility` 声明 `continuable: true`，启用系统级迁移能力
- 迁移超时时间：10 秒
- 迁移状态机：IDLE → PREPARING → MIGRATING → COMPLETED / FAILED / CANCELLED

#### 分布式数据同步

应用预留了分布式数据同步能力，声明了 `ohos.permission.DISTRIBUTED_DATASYNC` 权限（使用场景：inuse）。

**同步架构（预留）：**
- `SyncService` 定义了同步状态机（IDLE → SYNCING → SYNCED / FAILED）
- 支持三种同步变更类型：进度更新（PROGRESS_UPDATE）、添加收藏（FAVORITE_ADD）、移除收藏（FAVORITE_REMOVE）
- 当前因 SDK 限制为 stub 实现，待 `distributedDataObject` API 可用后启用

#### 数据备份恢复

应用集成了 `BackupExtensionAbility`（`EntryBackupAbility`），支持 HarmonyOS 系统级数据备份与恢复，确保用户更换设备或重装应用后学习数据不丢失。

---

## 四、技术架构

### 4.1 技术栈

| 类别 | 技术 | 版本/说明 |
|------|------|----------|
| UI 框架 | ArkUI 声明式开发范式 | @Component、@Builder、@State、@StorageLink |
| 开发语言 | ArkTS | TypeScript 超集 |
| 目标 SDK | HarmonyOS NEXT | API 12+（SDK 6.0.2） |
| 最低兼容 | HarmonyOS NEXT | API 12（SDK 5.0.0） |
| 数据持久化 | RDB 关系型数据库 | @kit.ArkData / relationalStore |
| 轻量存储 | Preferences | @kit.ArkData / preferences |
| 构建工具 | Hvigor | 6.0.2 |
| 测试框架 | @ohos/hypium + @ohos/hamock | 1.0.25 / 1.0.0 |
| 架构模式 | MVVM | Page → ViewModel → Service |

### 4.2 HarmonyOS Kit 依赖

| Kit | 用途 |
|-----|------|
| @kit.ArkData | RDB 数据库、Preferences 轻量存储 |
| @kit.ArkUI | UI 组件、router 导航、window 窗口管理 |
| @kit.AbilityKit | UIAbility、AbilityConstant、Want |
| @kit.PerformanceAnalysisKit | hilog 日志 |
| @kit.CoreFileKit | 备份恢复（BackupExtensionAbility） |

### 4.3 项目结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets            # 应用入口 Ability（生命周期、迁移、断点初始化）
├── entrybackupability/
│   └── EntryBackupAbility.ets      # 备份恢复扩展
├── pages/                           # 页面层
│   ├── Index.ets                    # 首页（导航容器）
│   ├── QuizPage.ets                 # 答题页
│   ├── ProgressPage.ets             # 学习进度页
│   ├── StatsPage.ets                # 学习统计页
│   ├── VocabListPage.ets            # 词汇浏览页
│   └── FavoritePage.ets             # 生词本页
├── components/                      # UI 组件层
│   ├── BreakpointContainer.ets      # 断点响应式容器
│   ├── ResponsiveNavContainer.ets   # 响应式导航容器
│   ├── ResponsiveScaffold.ets       # 响应式脚手架
│   ├── QuizOption.ets               # 答题选项组件
│   ├── FavoriteButton.ets           # 收藏按钮组件
│   ├── VocabCard.ets                # 词汇卡片组件
│   ├── StatCard.ets                 # 统计卡片组件
│   ├── MigrationPanel.ets           # 迁移面板组件
│   ├── DeviceListDialog.ets         # 设备列表弹窗组件
│   └── SyncStatusIndicator.ets      # 同步状态指示器组件
├── service/                         # 数据服务层
│   ├── VocabDbService.ets           # 数据库服务（RDB CRUD）
│   ├── QuizService.ets              # 答题服务（出题、判题、会话管理）
│   ├── FavoriteService.ets          # 收藏服务（添加/移除/查询）
│   ├── ProgressService.ets          # 进度服务（记录答题、统计、搜索）
│   ├── BreakpointService.ets        # 断点服务（断点计算、布局策略、防抖切换）
│   ├── MigrationService.ets         # 迁移服务（序列化/反序列化、状态管理）
│   └── SyncService.ets              # 同步服务（分布式数据同步，预留）
├── viewmodel/                       # 视图模型层
│   ├── HomeViewModel.ets
│   ├── QuizViewModel.ets
│   ├── ProgressViewModel.ets
│   ├── StatsViewModel.ets
│   ├── VocabListViewModel.ets
│   ├── FavoriteViewModel.ets
│   ├── MigrationViewModel.ets
│   └── SyncViewModel.ets
├── model/                           # 数据模型层
│   ├── VocabItem.ets                # 词汇项
│   ├── QuizQuestion.ets             # 答题题目
│   ├── QuizSession.ets              # 答题会话
│   ├── AnswerRecord.ets             # 答题记录
│   ├── StatsModels.ets              # 统计模型
│   ├── Enums.ets                    # 枚举定义
│   ├── BreakpointConfig.ets         # 断点配置
│   ├── NavigationConfig.ets         # 导航配置
│   ├── ResponsiveSpacing.ets        # 响应式间距
│   ├── MigrationData.ets            # 迁移数据
│   ├── SyncChange.ets               # 同步变更
│   └── DeviceInfo.ets               # 设备信息
└── common/
    ├── constants/
    │   ├── AppConstants.ets         # 应用常量
    │   ├── DbConstants.ets          # 数据库常量
    │   ├── LayoutConstants.ets      # 布局常量
    │   ├── LayoutHelper.ets         # 布局辅助
    │   ├── ClarityHelper.ets        # 清晰度辅助
    │   └── BeautifyHelper.ets       # 美化辅助
    ├── log/
    │   └── Logger.ets               # 日志封装
    └── utils/
        └── RandomUtil.ets           # 随机工具
```

### 4.4 数据流

```
用户操作 → Page（@State 响应式更新）
              ↓
         ViewModel（业务逻辑编排）
              ↓
         Service（数据读写、状态管理）
              ↓
    RDB / Preferences（持久化存储）
```

- Page 层通过 `@StorageLink` 绑定全局状态（断点、设备形态等），实现跨组件响应式更新
- ViewModel 层封装业务逻辑，协调多个 Service 完成复杂操作
- Service 层采用单例模式，封装数据访问逻辑，对上层屏蔽存储细节


<img width="236" height="517" alt="屏幕截图 2026-05-19 190057" src="https://github.com/user-attachments/assets/b316d41e-c105-496e-98ec-9734e0d39677" />
<img width="232" height="499" alt="屏幕截图 2026-05-19 185948" src="https://github.com/user-attachments/assets/66dd8f64-475a-43fd-9d9b-6982e8bcc964" />
<img width="226" height="504" alt="屏幕截图 2026-05-19 190017" src="https://github.com/user-attachments/assets/8949429c-3d29-4726-800f-bf12c08ce216" />
<img width="251" height="266" alt="image" src="https://github.com/user-attachments/assets/abf28ce1-03ed-4c9a-ad42-3ee593cab9c4" />
<img width="251" height="257" alt="image" src="https://github.com/user-attachments/assets/22aa375f-61c5-4561-8263-d1eb9b13c10f" />
