# Phase 2 Domain、算法与状态主闭环报告

## 阶段目标

- 按 `docs/product_spec.md` 第 11 节实现核心指标公式。
- 建立库存、账本、目标、设置、风险快照等 domain 模型。
- 建立内存 repository 和 ViewModel 状态主闭环。
- 跑通取烟、放回、清空库存、重置本地数据等 Phase 2 范围内的业务动作。
- 补充 calculator / ViewModel 单元测试代码，并完成命令行构建验证。

## 已完成内容

- 新增 domain 模型：
  - `InventoryAsset`
  - `LedgerEntry`
  - `GoalSettings`
  - `AppSettings`
  - `RiskSnapshot`
  - `QuitState`
- 新增 `QuitCalculator`：
  - 今日包年增量：`todayCigarettes / 20 / 365`
  - 库存潜在包年：`stockCount / 20 / 365`
  - 健康折算：`cigarettes * 20`
  - 肺部负担指数：`lungScore`
  - 健康净值：`clamp(100 - lungScore, 0, 100)`
  - 当日危害警示分：按 Phase 计划分段计算
- 新增内存仓储：
  - `QuitRepository`
  - `InMemoryQuitRepository`
- 新增 `QuitHomeViewModel`：
  - `takeSmoke`
  - `returnLastSmoke`
  - `clearStockAndRetire`
  - `resetLocalData`
  - `getHomeSummary`
  - `getRiskSnapshot`
- 首页 Phase 1 预览已改为读取 ViewModel 派生指标：
  - 当日危害警示分
  - 真实日耗
  - 健康负债
  - 今日支数 / 目标支数 / 库存支数 / 健康净值
- 测试模块设备类型已从 `phone + wearable` 收敛为 `phone`。
- 补充 Hypium 单元测试源码，覆盖 calculator、取烟、放回、重置等行为。

## 新增或修改文件

- `entry/src/main/ets/domain/models/QuitModels.ets`
- `entry/src/main/ets/domain/QuitCalculator.ets`
- `entry/src/main/ets/data/QuitRepository.ets`
- `entry/src/main/ets/features/home/QuitHomeViewModel.ets`
- `entry/src/main/ets/features/home/HomePreview.ets`
- `entry/src/test/LocalUnit.test.ets`
- `entry/src/ohosTest/module.json5`
- `docs/reports/phase_2_domain_state_report.md`

## UI 验证方式与结果

- Phase 2 不做完整 UI 复刻，只要求最小状态展示继续使用 Phase 1 设计 token。
- 已确认首页仍使用 Phase 1 的浅绿背景、深绿主按钮、薄荷状态面、风险提示与肺部素材。
- 已确认首页文案不再使用模板 `Hello World`。
- 结果：源码级 UI 验证通过。

## 功能验证方式与结果

- `QuitCalculator` 测试源码覆盖：
  - 健康折算
  - 今日包年增量
  - 库存潜在包年
  - `lungScore`
  - `netHealth`
  - `dailyHarmScore`
- ViewModel 测试源码覆盖：
  - 取烟后库存减少、账本增加、首页摘要更新
  - 放回库存用于撤销最近一次真实成本，并避免今日已取出为负数
  - 重置恢复初始库存和空账本
- `assembleHap` 构建通过，证明 main ArkTS 代码可编译。
- `UnitTestBuild` 构建通过，证明测试 ArkTS 代码可编译。

## 原型截图对照结果

- Phase 2 不进入 full-validation 逐页截图复刻。
- 首页仍保留原型方向的视觉 token 和基础结构。
- 完整页面截图对照留到 Phase 3。

## 验证命令与结果

```powershell
$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'
$env:PATH='F:\DevEco Studio\tools\node;F:\DevEco Studio\tools\hvigor\bin;F:\DevEco Studio\tools\ohpm\bin;' + $env:PATH
& 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default
```

结果：通过，`BUILD SUCCESSFUL in 54 s 273 ms`。

```powershell
$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'
$env:PATH='F:\DevEco Studio\tools\node;F:\DevEco Studio\tools\hvigor\bin;F:\DevEco Studio\tools\ohpm\bin;' + $env:PATH
& 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' UnitTestBuild --no-daemon --mode module -p module=entry@default -p product=default
```

结果：通过，`BUILD SUCCESSFUL in 46 s 45 ms`。

```powershell
$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'
$env:PATH='F:\DevEco Studio\tools\node;F:\DevEco Studio\tools\hvigor\bin;F:\DevEco Studio\tools\ohpm\bin;' + $env:PATH
& 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' test --no-daemon --mode module -p module=entry@default -p product=default
```

结果：未完成，300 秒超时。日志显示 `UnitTestArkTS` 已完成并进入 `GenerateUnitTestResult`，但任务未在超时前退出。

## 未能验证的内容和原因

- 未能拿到 `hvigorw test` 的完整测试结果。
  - 原因：`GenerateUnitTestResult` 阶段超时。
  - 已验证替代项：`UnitTestBuild` 通过，测试 ArkTS 编译通过。
- 未验证模拟器/真机运行时行为。
  - 原因：当前阶段仍以命令行构建和源码级验证为主。

## 遗留问题

- `test` 任务超时原因需要后续继续排查，可能与本地测试结果生成器或运行环境有关。
- 当前仓储仍为内存实现，Phase 5 再替换为 Preferences / RDB Store。
- 当前首页只是最小状态展示，完整手机端 UI 从 Phase 3 开始。
- HAP 仍未配置签名，发布或真机安装前需要配置 signingConfigs。

## 下一阶段注意事项

- Phase 3 进入核心手机 UI，需要严格对照 `qa/screenshots/full-validation`。
- 页面结构、底部导航、二级入口、首页指标、资产表单、账本布局、我的页内容以 `docs/product_spec.md` 为准。
- 如果原型和规格冲突，以 `docs/product_spec.md` 为准，先修计划再实现。

## 用户确认状态

待确认。
