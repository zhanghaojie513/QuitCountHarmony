# Phase 1 HarmonyOS 骨架与设计 Token 报告

## 阶段目标

- 使用本机 DevEco Studio 自带 HarmonyOS SDK 和命令行工具跑通构建。
- 收敛 HarmonyOS 手机端首版基础工程配置。
- 建立 ArkTS 主题 token 和基础首屏。
- 接入肺部素材。
- 生成 Phase 1 验证报告，并等待用户确认后再进入 Phase 2。

## 已完成内容

- 已定位 DevEco Studio 自带工具链：
  - `DEVECO_SDK_HOME=F:\DevEco Studio\sdk`
  - `ohpm=F:\DevEco Studio\tools\ohpm\bin\ohpm.bat`
  - `hvigorw=F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat`
  - `node=F:\DevEco Studio\tools\node`
- 已写入 Windows 用户环境变量：
  - `DEVECO_SDK_HOME`
  - 用户 `Path` 增加 DevEco 的 `node`、`hvigor`、`ohpm` 路径。
- 已更新基础应用信息：
  - `bundleName`：`com.haiha.quitcount`
  - `vendor`：`haiha`
  - 应用名：`戒烟有数`
- 已将首版设备类型收敛为 `phone`。
- 已替换 `Hello World` 模板页，创建“戒烟有数”Phase 1 基础首屏。
- 已建立基础设计 token：
  - 浅绿背景
  - 深绿主色
  - 珊瑚风险色
  - 薄荷状态面
  - 8vp 圆角
  - 34vp 图标按钮
  - 移动端紧凑间距
- 已迁移肺部素材：
  - `entry/src/main/resources/base/media/human_lungs_nih.png`
- 已生成 HAP：
  - `entry/build/default/outputs/default/entry-default-unsigned.hap`

## 新增或修改文件

- `AppScope/app.json5`
- `AppScope/resources/base/element/string.json`
- `entry/src/main/module.json5`
- `entry/src/main/resources/base/element/string.json`
- `entry/src/main/resources/base/element/color.json`
- `entry/src/main/resources/base/media/human_lungs_nih.png`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/core/theme/AppTheme.ets`
- `entry/src/main/ets/features/home/HomePreview.ets`
- `docs/reports/harmonyos_plan_feasibility_report.md`
- `docs/reports/phase_1_project_setup_report.md`

## UI 验证方式与结果

- 源码核对：
  - 首页展示“戒烟有数”。
  - 首页展示“真实成本 A1 · HarmonyOS Phase 1”。
  - 首页展示“肺部负担指数”。
  - 首页展示风险提示：“当日危害警示分用于行为干预，不代表医学诊断。”
  - 首页展示肺部素材。
  - 首页展示“真实日耗”“健康负债”“取出一支”。
- 资源核对：
  - `human_lungs_nih.png` 已进入 HarmonyOS media 资源目录。
  - 构建生成资源表包含 `media human_lungs_nih`。
- 结果：源码级 UI 验证通过。

## 功能验证方式与结果

- `ohpm --version`
  - 结果：通过，`6.1.2.268`。
- `hvigorw --version`
  - 结果：通过，`6.24.2`。
- `hvigorw tasks --no-daemon --mode module -p module=entry@default -p product=default`
  - 结果：通过，`BUILD SUCCESSFUL`。
- `hvigorw assembleHap --no-daemon --mode module -p module=entry@default -p product=default`
  - 结果：通过，`BUILD SUCCESSFUL`。
- HAP 产物：
  - `entry/build/default/outputs/default/entry-default-unsigned.hap`

## 原型截图对照结果

- Phase 1 只要求基础骨架和设计 token 首屏，不进入完整手机页面复刻。
- 已按产品规格和原型方向建立浅绿背景、深绿主按钮、风险提示、肺部视觉、指标卡和紧凑间距。
- 尚未逐页对照 full-validation 截图；该工作属于 Phase 3 核心手机 UI。

## 验证命令与结果

```powershell
$env:DEVECO_SDK_HOME='F:\DevEco Studio\sdk'
$env:PATH='F:\DevEco Studio\tools\node;F:\DevEco Studio\tools\hvigor\bin;F:\DevEco Studio\tools\ohpm\bin;' + $env:PATH
& 'F:\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleHap --no-daemon --mode module -p module=entry@default -p product=default
```

结果：`BUILD SUCCESSFUL in 46 s 877 ms`。

构建警告：

- 未配置签名，跳过 `hos_hap` 签名。
- 当前产物为 unsigned HAP；Phase 1 可接受，发布或真机安装前需要配置 signingConfigs。

## 未能验证的内容和原因

- 未生成 390x844 模拟器/真机截图。
  - 原因：当前阶段只完成命令行构建；尚未启动设备或模拟器。
- 未验证运行时日志。
  - 原因：尚未安装并启动 HAP。

## 遗留问题

- 后续进入 Phase 2 前需要用户确认本报告。
- 如需真机安装，需要配置签名。
- 当前 Codex 进程可能不会自动继承刚写入的用户环境变量；本轮命令仍显式设置了 `DEVECO_SDK_HOME` 和 DevEco 工具 PATH。新打开的终端应能读取用户环境变量。

## 下一阶段注意事项

- Phase 2 只实现 domain、算法、ViewModel 和内存 repository，不提前展开完整 UI。
- `QuitCalculator` 必须以 `docs/product_spec.md` 第 11 节为基准。
- 所有产品规则冲突均以 `docs/product_spec.md` 为准。

## 用户确认状态

待确认。
