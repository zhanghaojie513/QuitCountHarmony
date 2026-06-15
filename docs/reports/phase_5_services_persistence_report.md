# Phase 5 本地存储、通知、导出、同步占位报告

生成时间：2026-06-11

## 阶段目标

根据 `docs/product_spec.md` 第 14、15、17 节，以及 `docs/harmonyos_implementation_plan.md` Phase 5 要求，推进 HarmonyOS 手机端首版服务能力：

- 本地优先持久化。
- CSV 导出内容与本地文件保存。
- 通知权限/通知调用状态继续展示。
- 同步占位继续保持首版不接真实云端。
- 按新增移动端尺寸规则加固当前 ArkUI 布局。

## 已完成内容

- 新增 `PreferencesQuitRepository`：
  - 使用 HarmonyOS `@ohos.data.preferences`。
  - 将 `QuitState` 序列化为 JSON 保存到 Preferences。
  - 覆盖库存、账本、目标、设置、同步占位状态等当前状态对象。
  - 初始化失败或读写失败时保留内存兜底状态，避免当前会话数据立即丢失。
  - 设置页显示本地存储状态。
- `QuitCountShell` 启动时接入 `PreferencesQuitRepository`：
  - 页面仍只依赖 ViewModel。
  - 页面不直接读写 Preferences。
- 新增 `CsvExportService`：
  - 使用 HarmonyOS `@ohos.file.fs`。
  - 将 `viewModel.exportLedgerCsv()` 生成的 CSV 写入应用文件目录。
  - 导出结果会显示保存状态和路径。
- 导出入口更新：
  - “我的 -> 导出戒烟账本”可预览 CSV。
  - 增加“保存 CSV 文件”按钮。
  - 显示导出成功/失败状态。
- 通知权限引导更新：
  - 设置页新增“申请通知权限”按钮。
  - 使用 `notificationManager.requestEnableNotification(context)` 发起系统通知权限申请。
  - 权限申请失败时保留设置页状态反馈，不影响取烟记录。
- 每日复盘时间设置补充：
  - 设置页新增 `HH:mm` 复盘时间输入和“保存复盘时间”按钮。
  - 默认值仍为 `21:30`。
  - 输入无效时显示错误文案，并保留在设置页。
  - 保存后写入本地设置，并使用该时间调度每日复盘 ReminderAgent。
- 二级入口补充：
  - 设置页“导出戒烟账本”新增可点击入口，可跳转到 CSV 导出面板。
  - 账户与同步页由静态说明升级为占位面板，包含账户状态、同步策略、模拟登录和关闭同步占位。
  - 帮助与关于页新增反馈输入和提交反馈按钮，空反馈会显示错误，提交后显示产品内确认。
  - 模型与证据页补齐健康负债、计算口径、公开模型参考与局限说明。
- 上下文获取更新：
  - 将废弃的 `getContext(this)` 替换为 `this.getUIContext().getHostContext()`。
  - 重新构建后 `getContext` deprecated 警告已消失。
- 移动端适配加固：
  - 没有把页面固定写死为 `390x844`。
  - 将底部导航高度、底部内容留白、内容最大宽度、弹窗最大宽度、肺部视觉高度收敛到 `AppTheme`。
  - 主页面内容继续使用 `Scroll()`，内容超高可滚动。
  - 主内容区增加 `constraintSize({ maxWidth })`，避免大屏横向过度拉伸。
  - Sheet/Dialog 增加最大宽度约束。
  - 底部导航增加额外底部间距，降低被系统手势区遮挡的风险。

## 新增或修改文件

- `entry/src/main/ets/core/theme/AppTheme.ets`
  - 新增底部导航、底部安全间距、页面底部留白、内容最大宽度、弹窗最大宽度、肺部视觉高度等布局 token。
- `entry/src/main/ets/data/QuitRepository.ets`
  - 新增 `PreferencesQuitRepository`。
  - 保留 `InMemoryQuitRepository` 供测试和失败兜底。
- `entry/src/main/ets/features/shell/QuitCountShell.ets`
  - 接入 Preferences 仓库。
  - 接入 CSV 文件保存服务。
  - 接入通知权限申请按钮。
  - 接入每日复盘时间输入、校验、保存和 ReminderAgent 调度。
  - 接入设置页导出跳转、账户与同步占位面板、帮助反馈提交、模型说明补齐。
  - 设置页展示本地存储状态。
  - 导出面板增加保存按钮与状态。
  - 加固主内容区、底部导航、弹窗/Sheet 的响应式约束。
- `entry/src/main/ets/services/NotificationService.ets`
  - 新增通知权限申请方法。
- `entry/src/main/ets/services/CsvExportService.ets`
  - 新增 CSV 文件保存服务。
- `entry/src/main/ets/features/home/QuitHomeViewModel.ets`
  - `updateSettings` 支持更新 `dailyReviewTime`。
- `entry/src/test/LocalUnit.test.ets`
  - 新增复盘时间设置持久化编译级覆盖。
- `docs/reports/phase_5_services_persistence_report.md`
  - 新增本阶段报告。

## UI 验证方式与结果

已验证：

- ArkTS 编译通过，说明新增布局 token、`constraintSize`、导出按钮、存储状态文案等 UI 改动可被当前 SDK 接受。
- HAP 打包成功，说明新增页面引用、服务引用和资源配置未破坏构建。

未完成：

- 尚未在 HarmonyOS 模拟器/真机截图验证。
- 尚未确认底部主操作在不同设备手势区下的实际避让效果。
- 尚未做横屏截图验证。

## UI 验证尺寸清单与结果

- `390x844`：未进行设备截图验证；已完成源码级检查和编译验证。
- 小屏尺寸：未验证。
- 常规 Harmony/Android 手机尺寸：未验证。
- 大屏尺寸：未验证。
- 横屏：未验证。

未验证原因：

- 当前阶段未启动可交互模拟器/真机。
- 多尺寸验收需要真实渲染截图，不应只用源码检查代替。

补验计划：

- Phase 6 启动设备后按 `docs/product_spec.md` 第 17 节执行多尺寸截图验收。
- 重点检查底部导航/主操作是否被手势区遮挡、Sheet/Dialog 是否过宽、健康负债是否换行或截断。

## 功能验证方式与结果

已通过编译级验证：

- Preferences 仓库可编译。
- CSV 文件服务可编译。
- `QuitCountShell` 对 Preferences 和 CSV 服务的调用可编译。
- ViewModel 与页面接口未被破坏。
- 每日复盘时间可从设置页写入 ViewModel 设置状态，并作为 ReminderAgent 调度时间。

源码级确认：

- 库存、账本、目标和设置仍通过 ViewModel action 更新。
- 页面不直接操作底层 Preferences。
- 重置本地数据仍走 ViewModel `resetLocalData()`。
- CSV 包含现有 `exportLedgerCsv()` 输出内容。
- 已导出的 CSV 文件路径独立于重置逻辑，重置不会删除已导出的文件。

未完成：

- 尚未在设备上验证 App 重启后数据仍在。
- 尚未在设备文件目录确认 CSV 文件真实生成。
- 尚未接入系统分享或文件选择器，当前导出保存到应用文件目录。
- 每日复盘系统通知提醒在后续补丁中已接入 ReminderAgent，仍需设备验证实际到达。

## 原型截图对照结果

- 未进行截图对照。
- 本阶段重点是服务能力与适配加固，视觉对照留到 Phase 6 多尺寸验收。

## 验证命令与结果

### HAP 构建

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- 首次结果：`BUILD SUCCESSFUL in 15 s 4 ms`
- 替换 `getContext(this)` 并补充通知权限申请入口后复跑：`BUILD SUCCESSFUL in 33 s 755 ms`
- 补齐每日复盘时间设置链路后复跑：`BUILD SUCCESSFUL in 27 s 675 ms`
- 补齐二级入口交互与模型说明后复跑：`BUILD SUCCESSFUL in 23 s 295 ms`
- 仍有签名配置警告：当前项目未配置 signingConfigs。
- `getContext` 废弃警告已修复。
- 继续需要 `_JAVA_OPTIONS=-Xmx512m` 避免 Java 打包工具堆空间不足。

### UnitTestBuild

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' UnitTestBuild --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- 首次结果：`BUILD SUCCESSFUL in 21 s 896 ms`
- 替换 `getContext(this)` 并补充通知权限申请入口后复跑：`BUILD SUCCESSFUL in 52 s 454 ms`
- 补齐每日复盘时间设置链路和测试后复跑：`BUILD SUCCESSFUL in 25 s 42 ms`
- 补齐二级入口交互与模型说明后复跑：`BUILD SUCCESSFUL in 23 s 237 ms`
- `getContext` 废弃警告已修复。

### 完整 test

- 本阶段未重新执行完整 `hvigorw test`。
- 原因：此前已多次记录该任务在 `UnitTestArkTS` 后不退出并超时；本阶段先以 HAP 构建和 UnitTestBuild 作为可用门禁。

## 未能验证的内容和原因

- App 重启后数据仍在：需要设备安装、操作、重启 App 后验证。
- CSV 文件真实保存到设备文件目录：需要设备运行时验证。
- 系统分享/文件选择器导出：尚未实现。
- 每日复盘系统通知：已接入 ReminderAgent，仍需设备验证实际到达。
- 每日复盘时间设置：已完成编译级验证，仍需设备上验证输入、错误态、保存后调度与通知实际到达。
- 严厉危害警示三连通知实际到达：仍需真机/模拟器通知栏验证。
- 多尺寸 UI：尚未设备截图。
- 完整 `hvigorw test`：本地工具链任务不退出问题仍待定位。

## 遗留问题

- `getContext(this)` 废弃警告已修复，当前使用 `this.getUIContext().getHostContext()`。
- Preferences 当前保存完整 JSON 状态，首版可接受；后续如果账本数据增多，应拆分为 RDB Store 或结构化存储。
- CSV 当前保存到应用文件目录，尚未接入系统文件保存/分享。
- 通知权限引导已补充系统授权申请按钮，但仍需真机/模拟器验证系统弹窗和授权结果。
- 多尺寸实际渲染验收未完成。
- 横屏不是首版重点，但仍需验证不能白屏、崩溃或出现不可恢复遮挡。

## 下一阶段注意事项

- Phase 6 应优先做设备级验收：
  - App 重启持久化。
  - CSV 文件真实生成。
  - 系统通知栏三连提醒。
  - 多尺寸截图。
- 对 `390x844` 只作为原型对齐基准，不得回退成固定实现尺寸。
- 如果账本规模增长，优先将 ledger 从 Preferences JSON 迁移到 RDB。
- 实现系统分享/文件选择器前，不要宣称 CSV 已完成面向用户的完整导出体验。

## 用户确认状态

待确认。
