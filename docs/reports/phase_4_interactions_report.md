# Phase 4 关键交互与产品规则报告

生成时间：2026-06-11

## 阶段目标

根据 `docs/product_spec.md` 第 9、10、13、14 节，以及 `docs/harmonyos_implementation_plan.md` 的 Phase 4 要求，补齐首版手机端关键交互边界：

- 取烟提交后不阻止行为。
- 严厉危害警示只通过手机系统通知栏三连提醒。
- APP 内不做严厉危害警示三连提示。
- 设置页展示通知权限/通知发送状态。
- 每日复盘只显示单个 APP 内弹窗，并可跳到账本。
- 重置本地数据继续使用产品内二次确认弹窗。
- 小 i 说明弹窗继续保持产品规格口径。

## 已完成内容

- 新增 HarmonyOS 通知服务封装 `QuitNotificationService`：
  - 使用本机 SDK 中的 `@ohos.notificationManager`。
  - 使用 `notificationManager.isNotificationEnabled()` 读取通知权限状态。
  - 使用 `notificationManager.publish()` 发送三条系统通知栏提醒。
  - 三条提醒间隔约 850ms。
  - 通知文案不羞辱用户，不做医疗恐吓。
  - 通知失败或未授权时，不影响取烟记录成功。
- 首页取烟提交后：
  - 先扣减库存、写入账本并刷新指标。
  - 若达到严厉危害警示干预线，再请求系统通知栏三连提醒。
  - APP 内不显示三连提示。
- 设置页新增：
  - 通知权限状态展示。
  - 严厉危害警示最近结果展示。
- 新增每日复盘弹窗：
  - 本次 App 会话只显示一次。
  - 显示今日取出、库存、当日危害警示分。
  - 可点击“查看账本”跳到账本页。
  - 包含非医学诊断/行为反馈提示。
- 继续保留产品内重置二次确认：
  - 显示“高风险操作”。
  - 显示当前本地记录数和库存支数。
  - 取消不清数据。
  - 确认才重置状态。

## 新增或修改文件

- `entry/src/main/ets/services/NotificationService.ets`
  - 新增通知服务封装。
- `entry/src/main/ets/features/shell/QuitCountShell.ets`
  - 接入严厉危害警示提交后通知调用。
  - 增加通知权限状态与最近通知结果展示。
  - 增加每日复盘弹窗和跳到账本逻辑。
- `docs/product_spec.md`
  - 同步移动端尺寸规则，明确 `390x844` 是验收基准，不是固定实现尺寸。
- `docs/harmonyos_implementation_plan.md`
  - 同步移动端自适应布局规则和多尺寸验收要求。
- `docs/reports/phase_4_interactions_report.md`
  - 新增本阶段报告。

## UI 验证方式与结果

已验证：

- ArkTS 编译通过，说明新增弹窗、设置页状态展示、通知状态文本、事件绑定均可被编译器接受。
- HAP 打包成功，说明新增服务文件、导入路径和 Notification Kit 类型可被当前 SDK 接受。

未完成：

- 尚未在 HarmonyOS 模拟器或真机上截图验证每日复盘弹窗、设置页通知状态、系统通知栏实际展示。
- 尚未完成多尺寸 UI 验收。

## UI 验证尺寸清单与结果

- `390x844`：本阶段未进行设备截图验证；当前只完成编译级验证。
- 小屏尺寸：未验证。
- 常规 Harmony/Android 手机尺寸：未验证。
- 大屏尺寸：未验证。
- 未验证原因：当前回合未启动 HarmonyOS 模拟器/真机，系统通知栏和安全区表现需要设备环境确认。
- 补验计划：Phase 6 统一按 `docs/product_spec.md` 第 17 节和实施计划移动端自适应规则，对 `390x844`、小屏、常规 Harmony/Android、大屏尺寸做截图验收；如 Phase 5 接入持久化和导出后可提前补一轮。

## 功能验证方式与结果

已通过编译级验证：

- `QuitNotificationService` 可编译。
- `notificationManager.isNotificationEnabled()` 和 `notificationManager.publish()` 调用可编译。
- 严厉危害警示触发路径可编译。
- 每日复盘弹窗和跳转账本逻辑可编译。
- 设置页通知状态展示可编译。

源码级确认：

- 取烟记录提交发生在通知调用之前。
- 通知未授权或发送失败只更新状态文本，不回滚库存和账本。
- APP 内没有严厉危害警示三连弹窗。
- 三连提醒只通过 `notificationManager.publish()` 请求系统通知栏。

未完成：

- 未在真机/模拟器确认通知权限弹窗、通知栏实际到达、通知频率限制和后台行为。
- 每日复盘系统通知提醒在 Phase 4 当时尚未实现；后续补丁已接入 ReminderAgent，仍需设备验证实际到达。
- 通知权限引导当前为状态文案，尚未接入系统设置跳转。

## 原型截图对照结果

- 未进行截图对照。
- 本阶段完成的是交互与平台服务接入的编译级验证，视觉对照需在可运行设备上补验。

## 验证命令与结果

### HAP 构建

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- `BUILD SUCCESSFUL in 39 s 288 ms`
- 有签名配置警告：当前项目未配置 signingConfigs，调试阶段可接受。
- 继续需要 `_JAVA_OPTIONS=-Xmx512m` 避免 Java 打包工具堆空间不足。

### UnitTestBuild

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' UnitTestBuild --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- `BUILD SUCCESSFUL in 34 s 169 ms`

### 完整 test

- 本阶段未重新执行完整 `hvigorw test`。
- 原因：Phase 2/3 已记录该任务在 `UnitTestArkTS` 后不退出并超时；本阶段先以 `UnitTestBuild` 作为编译门禁。

## 未能验证的内容和原因

- 系统通知栏三连提醒实际到达：需要 HarmonyOS 模拟器或真机验证。
- 通知权限未授权时的系统行为：需要设备权限状态验证。
- 每日复盘系统通知提醒：Phase 4 当时尚未实现；后续补丁已接入 ReminderAgent，仍需设备验证实际到达。
- 多尺寸 UI：尚未启动设备截图。
- 完整 `hvigorw test`：本地工具链任务仍存在历史不退出问题，需后续单独定位。

## 遗留问题

- 需要接入每日复盘系统通知提醒，当前只有 APP 内单个复盘弹窗。
- 需要补通知权限引导入口，例如跳转系统通知设置。
- 需要在真机/模拟器验证 `notificationManager.publish()` 是否需要额外 manifest 权限或系统授权流程。
- 需要定位完整 `hvigorw test` 不退出问题。
- 需要做多尺寸截图验收，尤其是 `390x844`、小屏、常规 Harmony/Android、大屏。
- Phase 5 仍需落地本地持久化、CSV 文件保存/分享和同步占位细节。

## 下一阶段注意事项

- Phase 5 优先接入本地持久化，替换当前内存仓库。
- 通知权限和通知实际到达必须在设备环境验证，不能只以编译通过作为完成证据。
- 严厉危害警示仍必须遵循产品规格：不阻止取烟，提交成功后只通过系统通知栏三连提醒。
- 移动端布局不得固定 `390x844`，该尺寸只作为原型对齐验收基准之一。

## 用户确认状态

待确认。
