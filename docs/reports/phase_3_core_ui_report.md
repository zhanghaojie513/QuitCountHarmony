# Phase 3 核心 UI 与交互骨架报告

生成时间：2026-06-11

## 阶段目标

根据 `docs/product_spec.md` 和 `docs/harmonyos_implementation_plan.md`，在 HarmonyOS ArkTS / ArkUI 工程中推进手机端首版核心 UI 骨架，重点覆盖：

- 首页、资产、账本、我的四个底部导航。
- 首页取烟主流程 Sheet。
- 添加资产表单错误态。
- 我的页二级入口骨架。
- 设置、目标、模型与证据、帮助关于、导出、重置确认等核心产品规则入口。

## 已完成内容

- 首页主动作“取出一支”已由直接记账改为打开取烟 Sheet。
- 取烟 Sheet 已包含资产选择、场景、备注常驻选填和“记录取出”提交。
- 取消取烟 Sheet 不会改变库存、不写账本。
- 提交取烟后会扣减库存、写入账本，并刷新首页、资产页和账本页指标。
- “放回库存”继续走 ViewModel 的撤销逻辑，避免出现负数。
- 我的页二级入口已接入可交互弹层：
  - 戒烟目标
  - 模型与证据
  - 设置
  - 账户与同步
  - 帮助与关于
  - 导出戒烟账本
  - 手表端说明
- 设置页骨架已包含：
  - 严厉危害警示
  - 取烟反馈
  - 每日复盘提醒
  - 隐私优先/本地优先
  - 跨设备同步入口
  - 导出戒烟账本
  - 本地数据记录数
  - 重置本地数据
- 重置本地数据已使用产品内二次确认弹窗，不依赖浏览器或平台默认确认。
- 重置确认弹窗已展示“高风险操作”、当前记录数、库存支数和影响说明。
- 帮助与关于中“检查更新”首版模拟为“当前已是最新版本”。
- 模型与证据页骨架已展示产品规格要求的关键公式和非医学诊断提示。
- ViewModel 新增目标更新、设置更新和 CSV 内容生成能力。
- 后续补充：首页健康净值、健康负债已增加小 i 说明入口，说明公式口径、局限性和非医学诊断提示。
- 后续补充：资产列表已由普通列表文案升级为资产卡片，默认取烟标识改为品牌标题旁的小标签，风险标签单独展示，避免与默认标识抢同一视觉位置。
- 后续补充：取烟 Sheet 的资产选择按默认资产优先排序。
- 修正了单测中与业务事实相反的断言：
  - 取出一支后 `todayTaken` 应为 1。
  - 放回撤销后 `todayTaken` 应回到 0。

## 新增或修改文件

- `entry/src/main/ets/features/shell/QuitCountShell.ets`
  - 扩展四 Tab UI 与二级弹层。
  - 增加取烟 Sheet、设置弹层、目标编辑、模型说明、帮助关于、导出预览、重置确认。
  - 后续补充首页健康净值/健康负债说明入口、资产卡片默认标识和风险标签分离。
- `entry/src/main/ets/features/home/QuitHomeViewModel.ets`
  - 新增 `updateGoal`。
  - 新增 `updateSettings`。
  - 新增 `exportLedgerCsv`。
- `entry/src/test/LocalUnit.test.ets`
  - 修正取烟和放回相关断言。
- `docs/reports/phase_3_core_ui_report.md`
  - 新增本阶段报告。

## UI 验证方式与结果

已验证：

- ArkTS 编译通过，说明新增 ArkUI 组件结构、Builder、状态变量和事件绑定均可被编译器接受。
- HAP 打包成功，说明核心 UI 资源、页面入口和模块配置可生成安装包。
- 后续补充后的 HAP 构建仍通过，说明健康净值/健康负债说明卡、资产卡片与默认资产排序可编译。

未完成：

- 尚未在 HarmonyOS 模拟器或真机上进行截图验收。
- 尚未按 `390x844` 原型对齐验收基准进行视觉密度、文字不换行和弹层遮挡检查。
- 尚未做真实点击流截图验证。

## 功能验证方式与结果

已通过编译级验证：

- 首页、资产、账本、我的四个 Tab 入口存在。
- 取烟 Sheet、添加资产弹窗、信息说明弹窗、二级功能弹层、重置确认弹窗均可编译。
- ViewModel 目标、设置、CSV 导出接口可编译。
- 单测代码可完成 UnitTestBuild。

逻辑层已覆盖：

- 取烟更新库存、账本、健康折算、风险快照。
- 放回库存避免负数。
- 添加资产业务校验。
- 重置本地数据恢复初始状态。
- 健康净值公式仍使用 `100 - lungScore`。

未完成：

- 历史遗留项的当前状态见 Phase 5/Phase 6 报告：本地 Preferences 持久化、通知服务、每日复盘 ReminderAgent、CSV 应用目录保存均已接入，但仍需设备/模拟器验证。

## 验证命令与结果

### HAP 构建

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- `BUILD SUCCESSFUL in 7 s 413 ms`
- 输出 `entry-default-unsigned.hap`。
- 有签名配置警告：当前项目未配置 signingConfigs，调试阶段可接受。

备注：

- 不设置 `_JAVA_OPTIONS=-Xmx512m` 时，HAP 打包阶段的 Java 工具曾报：
  - `Could not reserve enough space for object heap`
- 加入 `_JAVA_OPTIONS=-Xmx512m` 后打包成功。

### UnitTestBuild

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' UnitTestBuild --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- `BUILD SUCCESSFUL in 34 s 12 ms`

### 完整 test

命令：

```powershell
rtk powershell -NoProfile -Command "`$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'; `$env:_JAVA_OPTIONS='-Xmx512m'; & 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' test --no-daemon --mode module -p module=entry@default -p product=default"
```

结果：

- 90 秒超时。
- 输出停在 `Windows_NT` 之后。
- `UnitTestArkTS` 已完成，但完整 test 任务没有正常退出。

## 未能验证的内容和原因

- 未能完成完整 `hvigorw test`：命令在 `UnitTestArkTS` 后未退出，90 秒超时。
- 未能完成模拟器/真机 UI 验证：当前回合只完成编译与打包验证，尚未启动设备运行。
- 未能验证系统通知栏提醒：通知能力尚未实现。
- 未能验证真实文件导出：当前阶段只生成 CSV 内容，尚未保存文件。
- 未能验证本地持久化重启恢复：当前仍使用内存仓库。

## 遗留问题

- 需要引入 HarmonyOS 原生持久化实现，替换 `InMemoryQuitRepository`。
- 需要接入 HarmonyOS 通知权限状态、每日复盘提醒和严厉危害警示三连本地通知。
- 需要将二级弹层进一步拆成可维护的 feature 页面或组件。
- 需要进行 `390x844` 原型对齐基准、小屏、常规 Harmony/Android、大屏等多尺寸 UI 截图验收，检查文字换行、健康负债不换行、小 i 关闭按钮视觉居中。
- 需要定位 `hvigorw test` 不退出的问题，确认是本地工具链任务退出问题还是测试配置问题。
- 需要接入 CSV 文件保存/分享能力。

当前状态补充：

- 本地持久化、通知服务、每日复盘系统提醒和 CSV 应用目录保存已在后续阶段接入。
- 仍需设备/模拟器验证 UI 截图、多尺寸、安全区、系统通知、每日提醒、CSV 真实文件和重启持久化。
- CSV 目前保存到应用文件目录，系统文件选择器或分享仍是后续增强项。

## 下一阶段注意事项

- Phase 4 建议优先做本地持久化与数据导出落地，因为这是产品规格中“本地优先”的核心。
- 实现通知前先补权限状态展示，避免记录成功但通知权限缺失时没有可见解释。
- UI 后续仍以 `docs/product_spec.md` 为产品规则源，修改后的原型只作为布局和视觉参考。
- 严厉危害警示不得阻止取烟，后续实现通知时只在提交成功后触发手机系统通知栏提醒。
