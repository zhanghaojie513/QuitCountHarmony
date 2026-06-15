# Phase 6 测试与验收报告

生成时间：2026-06-11

## 阶段目标

根据 `docs/product_spec.md` 第 17 节和 `docs/harmonyos_implementation_plan.md` Phase 6 要求，对当前 HarmonyOS 手机端实现做首轮验收：

- 构建产物验证。
- 单测编译验证。
- 产品规则源码级核对。
- 移动端尺寸规则源码级核对。
- 设备/模拟器可用性检查。
- 明确未能完成的设备级验收项和补验计划。

## 已完成内容

- 确认 DevEco SDK 中 `hdc.exe` 可用：
  - `F:\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe`
- 确认当前无已连接 HarmonyOS 设备/模拟器：
  - `hdc list targets` 输出 `[Empty]`
- 确认 HAP 产物存在：
  - `entry\build\default\outputs\default\entry-default-unsigned.hap`
- 重新执行 HAP 构建并通过。
- 重新执行 UnitTestBuild 并通过。
- 源码级检查关键产品规则：
  - 健康净值使用 `100 - lungScore`。
  - 未发现 `100 - dailyHarmScore` 作为健康净值公式。
  - 严厉危害警示不阻止取烟，提交成功后触发系统通知栏三连提醒。
  - 首页、资产、账本、我的四 Tab 入口存在。
  - 资产页已补齐“清空库存并记录退役”入口和确认弹窗。
  - 首页健康净值已增加小 i 说明入口，口径为 `netHealth = clamp(100 - lungScore, 0, 100)`。
  - 首页健康负债已增加小 i 说明入口，明确首页口径按今日已取出支数折算。
  - 资产列表已改为资产卡片，默认取烟标识位于品牌标题旁的小标签位置，风险标签单独展示。
  - 取烟 Sheet 的资产选择已按默认资产优先排序。
  - 账本事件行已补充品牌、时间、焦油、成本、健康折算、备注。
  - 本地持久化仓库、CSV 导出服务、通知服务均已接入。
  - 每日复盘系统提醒已接入 `@ohos.reminderAgentManager`。
  - 设置页每日复盘时间已支持 `HH:mm` 输入、错误提示、保存和 ReminderAgent 调度，默认值为 `21:30`。
  - 设置页“导出戒烟账本”已补充跳转入口。
  - 账户与同步页已补充模拟登录、关闭同步占位和本地优先说明。
  - 帮助与关于页已补充反馈输入、空反馈错误态和提交确认。
  - 模型与证据页已补齐健康负债、计算口径、公开模型参考与局限。
  - 已声明 `ohos.permission.PUBLISH_AGENT_REMINDER`。
  - CSV 导出已补充文本字段转义。
  - 手表端仅保留未来入口说明，没有实现完整复杂手表端。
- 源码级检查移动端尺寸规则：
  - 未发现将页面固定写死为 `390x844` 的实现。
  - `390x844` 在产品规格和实施计划中作为原型对齐验收基准，不作为固定实现尺寸。
  - 主内容区、弹窗/Sheet 已使用百分比宽度和 `constraintSize` 最大宽度约束。
- 修正旧 Phase 3 报告中“固定尺寸”的历史表述，改为 `390x844` 原型对齐验收基准。

## 新增或修改文件

- `docs/reports/phase_3_core_ui_report.md`
  - 修正历史报告中的 `390x844` 表述。
- `docs/reports/phase_6_testing_acceptance_report.md`
  - 新增本阶段验收报告。

- `entry/src/main/ets/features/shell/QuitCountShell.ets`
  - 补齐“清空库存并记录退役”入口、确认弹窗和成功/空库存反馈。
  - 补齐首页健康净值/健康负债小 i 说明入口。
  - 资产列表改为资产卡片，分离默认取烟标识与风险标签。
  - 取烟资产选择按默认资产优先排序。
  - 设置页新增每日复盘时间输入、校验、保存和按设置时间调度。
  - 设置页新增导出跳转按钮。
  - 账户与同步页由静态说明升级为占位面板。
  - 帮助与关于页新增反馈提交交互。
  - 模型与证据页补齐规格要求的说明项。
  - 账本事件行补充品牌、时间、焦油、成本、健康折算、备注。
- `entry/src/test/LocalUnit.test.ets`
  - 新增 `viewModelClearStockAndRetireRecordsLedgerEvent` 编译级覆盖。
  - 新增 `viewModelExportLedgerCsvEscapesTextFields` 编译级覆盖。
- `entry/src/main/ets/services/NotificationService.ets`
  - 新增每日复盘系统提醒调度/取消。
- `entry/src/main/module.json5`
  - 声明 `ohos.permission.PUBLISH_AGENT_REMINDER`。
- `entry/src/main/ets/features/home/QuitHomeViewModel.ets`
  - CSV 导出增加逗号、换行、引号转义。
  - 设置更新支持写入 `dailyReviewTime`。
- `entry/src/test/LocalUnit.test.ets`
  - 新增每日复盘时间设置持久化编译级覆盖。

## UI 验证方式与结果

已完成：

- 源码级检查没有固定 `390x844` 页面实现。
- 源码级确认页面使用 `Scroll()`、百分比宽度、`constraintSize`、底部留白 token 等方式适配。
- 源码级确认首页健康负债值使用单行指标值展示，资产卡片使用相对宽度并允许说明文字换行。
- 源码级确认资产默认标识比风险标签更小，且不与风险标签抢同一视觉位置。
- HAP 构建通过，说明 UI 代码可编译打包。

未完成：

- 未完成真实截图验收。
- 未完成原型截图逐页对照。
- 未完成安全区、状态栏、底部手势区实际遮挡验证。
- 未完成横屏实际验证。

## UI 验证尺寸清单与结果

- `390x844`：未完成设备截图；已完成源码级检查和构建验证。
- 小屏尺寸：未完成设备截图。
- 常规 Harmony/Android 手机尺寸：未完成设备截图。
- 大屏尺寸：未完成设备截图。
- 横屏：未完成设备截图。

未验证原因：

- `hdc list targets` 输出 `[Empty]`，当前没有可安装运行的 HarmonyOS 设备或模拟器。
- 多尺寸验收必须基于真实渲染截图，不能只用源码检查替代。

补验计划：

- 连接 HarmonyOS 真机或启动 DevEco 模拟器后执行：
  - 安装 HAP。
  - 打开首页、资产、账本、我的、设置、模型、帮助、导出、取烟 Sheet、添加资产弹窗、每日复盘弹窗、重置弹窗。
  - 分别在 `390x844`、小屏、常规 Harmony/Android、大屏尺寸截图。
  - 检查健康负债不换行、底部主操作不被手势区遮挡、小 i 关闭按钮居中、弹窗不遮挡核心内容。

## 功能验证方式与结果

已完成：

- HAP 构建通过。
- UnitTestBuild 通过。
- 源码级确认关键规则和服务接入。
- 源码级确认首页健康净值、首页健康负债具备小 i 说明入口。
- 源码级确认资产默认标识和风险标签已分离展示。
- 源码级确认每日复盘时间输入无效时留在设置页并显示错误，保存后写入设置并按该时间调度。
- 源码级确认设置页导出入口可跳到导出面板。
- 源码级确认账户与同步页保留占位，不做真实云同步。
- 源码级确认帮助与关于页可提交反馈并显示错误态/确认反馈。
- `clearStockAndRetire` 退役库存逻辑已新增测试用例并通过 UnitTestBuild 编译。
- CSV 文本字段转义已新增测试用例并通过 UnitTestBuild 编译。
- 每日复盘时间设置持久化已新增测试用例并通过 UnitTestBuild 编译。

未完成：

- 未完成 App 安装运行。
- 未完成取烟真实点击流验证。
- 未完成添加资产错误态真实 UI 验证。
- 未完成重置取消/确认真实 UI 验证。
- 未完成 App 重启后数据仍在验证。
- 未完成 CSV 文件真实生成验证。
- 未完成系统通知栏三连提醒实际到达验证。
- 未完成通知权限申请系统弹窗验证。

## 逻辑/算法验证

已有覆盖：

- `QuitCalculator.healthMinutes`
- `todayPackYearIncrement`
- `stockPotentialPackYears`
- `lungScore`
- `netHealthFromLungScore`
- `dailyHarmScore`
- `takeSmoke`
- `returnLastSmoke`
- `resetLocalData`

当前状态：

- UnitTestBuild 通过，说明测试代码可编译。
- 完整 `hvigorw test` 仍未作为通过证据，因为此前多次在 `UnitTestArkTS` 后不退出并超时。

## 原型截图对照结果

- 未完成截图对照。
- 原因：当前无可用设备/模拟器。

## 验证命令与结果

### HDC 设备检查

命令：

```powershell
rtk cmd.exe /c "F:\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" list targets
```

结果：

```text
[Empty]
```

结论：

- 当前没有可用 HarmonyOS 真机或模拟器。

### HAP 产物检查

命令：

```powershell
rtk cmd.exe /c dir /s /b entry\build\default\outputs\default\*.hap
```

结果：

```text
E:\myProject\QuitCount\QuitCountHarmony\entry\build\default\outputs\default\entry-default-unsigned.hap
```

### HAP 构建

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- `BUILD SUCCESSFUL in 34 s 875 ms`
- 接入每日复盘 ReminderAgent、CSV 转义和权限声明后复跑：`BUILD SUCCESSFUL in 28 s 566 ms`
- 补齐首页指标说明入口、资产卡片和默认资产排序后复跑：`BUILD SUCCESSFUL in 29 s 400 ms`
- 补齐每日复盘时间设置链路后复跑：`BUILD SUCCESSFUL in 27 s 675 ms`
- 补齐二级入口交互与模型说明后复跑：`BUILD SUCCESSFUL in 23 s 295 ms`
- 仍有签名配置警告：当前项目未配置 signingConfigs。
- 继续需要 `_JAVA_OPTIONS=-Xmx512m` 避免 Java 打包工具堆空间不足。
- SDK 仍提示 ReminderAgent API 需要 `ohos.permission.PUBLISH_AGENT_REMINDER`；当前已在 `module.json5` 声明，仍需设备验证授权/提醒实际行为。

### UnitTestBuild

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' UnitTestBuild --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- 首次结果：`BUILD SUCCESSFUL in 24 s 986 ms`
- 补齐退役库存交互和测试后复跑：`BUILD SUCCESSFUL in 29 s 56 ms`
- 接入每日复盘 ReminderAgent、CSV 转义测试后复跑：`BUILD SUCCESSFUL in 22 s 335 ms`
- 补齐首页指标说明入口、资产卡片和默认资产排序后复跑：`BUILD SUCCESSFUL in 24 s 561 ms`
- 补齐每日复盘时间设置链路和测试后复跑：`BUILD SUCCESSFUL in 25 s 42 ms`
- 补齐二级入口交互与模型说明后复跑：`BUILD SUCCESSFUL in 23 s 237 ms`

### 源码规则检查

命令：

```powershell
rtk powershell -NoProfile -Command "[Console]::OutputEncoding=[Text.UTF8Encoding]::UTF8; rg -n '390|844|dailyHarmScore|netHealthFromLungScore|100 - lungScore|requestEnableNotification|publishStrictRiskTriple|PreferencesQuitRepository|CsvExportService|resetLocalData|returnLastSmoke' entry/src/main/ets entry/src/test docs/product_spec.md docs/harmonyos_implementation_plan.md"
```

结果摘要：

- `QuitCalculator` 中 `netHealthFromLungScore` 使用 `100 - lungScore`。
- `NotificationService` 中存在 `publishStrictRiskTriple` 和 `requestEnableNotification`。
- `PreferencesQuitRepository` 和 `CsvExportService` 已接入。
- 文档中 `390x844` 均作为验收基准，不是固定实现尺寸。

## 未能验证的内容和原因

- App 设备运行：无连接设备/模拟器。
- UI 截图与原型对照：无连接设备/模拟器。
- 多尺寸验收：无连接设备/模拟器。
- 通知栏三连实际到达：无连接设备/模拟器。
- 每日复盘系统提醒实际到达：无连接设备/模拟器。
- 每日复盘时间设置真实 UI 输入、错误态和保存后提醒重调度：无连接设备/模拟器。
- 账户与同步、帮助反馈、设置导出跳转的真实点击流：无连接设备/模拟器。
- 通知权限系统弹窗：无连接设备/模拟器。
- 重启后持久化：无连接设备/模拟器。
- CSV 文件真实保存：无连接设备/模拟器。
- 完整 `hvigorw test`：历史记录显示该任务在本地工具链中不退出并超时，本阶段未作为通过证据。

## 遗留问题

- 需要连接 HarmonyOS 真机或启动 DevEco 模拟器后完成真实设备验收。
- 当前 HAP 未配置正式签名，调试阶段可构建，发布前必须配置 signingConfigs。
- `_JAVA_OPTIONS=-Xmx512m` 仍是当前命令行打包的必要环境变量。
- Preferences 当前保存完整 JSON 状态，首版可接受；后续账本规模增大时建议迁移 ledger 到 RDB。
- CSV 当前保存到应用文件目录，尚未接入系统文件选择器或分享。
- 完整 `hvigorw test` 不退出问题仍待定位。

## 下一阶段注意事项

- 优先启动 DevEco 模拟器或连接真机，执行设备补验。
- 设备补验通过前，不能把首版目标标记为完全完成。
- 多尺寸验收必须覆盖：
  - `390x844` 原型对齐基准
  - 小屏
  - 常规 Harmony/Android 手机尺寸
  - 大屏
- 重点验证：
  - 取烟流程
  - 放回库存
  - 添加资产错误态
  - 重置取消/确认
  - 每日复盘跳账本
  - 每日复盘系统提醒
  - 通知权限申请
  - 系统通知栏三连提醒
  - App 重启后数据仍在
  - CSV 文件真实生成

## 用户确认状态

待确认。
