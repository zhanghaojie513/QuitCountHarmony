# 戒烟有数 HarmonyOS 分阶段执行计划

## Summary

目标是在 `E:\myProject\QuitCount\QuitCountHarmony` 落地 HarmonyOS 手机端首版。共同产品规则、公式、文案原则和验收清单以 `docs/product_spec.md` 为最终产品规则源；本计划只描述 HarmonyOS 的分阶段实施、工程改造、验证门禁和平台适配事项。

每个阶段完成后必须验证 UI 和功能，并生成 `docs/reports/phase_xxx_report.md`。阶段报告必须由用户确认后，才能进入下一阶段。不能用“未验证但继续”跳过阶段门禁。

UI 必须严格按最新原型落地，可做 HarmonyOS 原生适配微调，但整体风格、信息架构、颜色气质、组件密度、页面层级、关键交互不能改变。`390x844` 是对齐当前原型的核心验收基准之一，不是实现时的固定尺寸。

移动端自适应规则：

- Harmony 版必须使用 ArkUI 响应式/自适应布局，不得把主页面、手机壳、内容区固定写死为 `390x844`。
- 页面宽高应根据真实设备、安全区、状态栏、底部手势区自适应。
- 允许使用百分比宽度、约束尺寸、滚动容器、系统安全区适配等方式实现。
- 内容高度超出时必须可滚动，底部主操作不能被系统手势区遮挡。
- 弹窗、Sheet、指标卡片、按钮应使用相对宽度和合理 max width，不写死单一设备宽度。
- 关键文字不能重叠或被截断；窄屏必要时允许说明文字换行。
- 首页健康负债等核心数值要通过布局、字号、单位拆分等方式尽量保证不换行。
- 横屏不是首版重点，但不能白屏、崩溃或出现不可恢复遮挡。
- 阶段 UI 验收必须以 `390x844` 作为原型对齐基准，并覆盖至少一个小屏、一个常规 Harmony/Android 手机尺寸、一个大屏尺寸。
- 阶段报告必须写清楚本阶段验证过哪些尺寸；如果暂时无法多尺寸验证，必须说明原因和补验计划。

优先级基准：

- `docs/product_spec.md`：最终产品规则源，决定功能范围、公式口径、交互规则、通知策略、合规提示、验收标准。
- 修改后的原型文件：UI、布局、页面流程、视觉风格和交互细节参考，负责“长什么样、页面怎么流转、移动端密度如何”。
- Harmony 实施计划：工程执行拆分，负责“按什么阶段开发、每阶段验证什么、报告怎么输出”。
- 二者不冲突时同时遵循产品规格和修改后的原型文件；如发生冲突，以 `docs/product_spec.md` 为准，先修正本计划，再实现。

最新原型参考：

- 原型目录：`C:\Users\haiha\Documents\Codex\2026-06-10\c-users-haiha-documents-codex-2026\work\quit-smoking-prototype-preview`
- 完整验证截图：`qa\screenshots\full-validation`
- 重点截图：`05-add-asset-errors.png`、`17-reset-confirm-modal.png`

## 当前 HarmonyOS 工程状态

- 当前工程是 HarmonyOS/Hvigor 工程，已有 `AppScope/`、`entry/`、`entry/src/main/ets/pages/Index.ets`。
- Phase 1 已替换模板 `Hello World`，当前首页为“戒烟有数”基础首屏。
- `entry/src/main/module.json5` 的 `deviceTypes` 已收敛为 `phone`。
- 当前包名已改为 `com.haiha.quitcount`。
- 已创建 `docs/` 和 `docs/reports/`，本计划作为 HarmonyOS 版本实施基线。

## Phase Gate Rule

- 每阶段完成后生成 `docs/reports/phase_xxx_report.md`。
- 报告生成后立即停止，不继续下一阶段。
- 用户明确确认该阶段报告后，才开始下一阶段。
- 如果 UI 或功能验证未通过，先修复并更新同一阶段报告，再等待用户确认。
- 每阶段报告必须写明验证命令、验证结果、未验证内容和原因。

## Phase Plan

### Step 0：生成计划与报告目录

- 创建 `docs/harmonyos_implementation_plan.md`，写入本计划。
- 创建或更新 `docs/product_spec.md`，作为 Flutter 版与 Harmony 版共同遵循的产品规格基准。
- 创建 `docs/reports/`。
- 当前阶段只做计划文件，不开始 Phase 1 实现。

### Preflight：工具链与模板构建验证

- 在进入 Phase 1 前确认 HarmonyOS 命令行工具与工程版本匹配。
- 固定检查命令：
  - `ohpm --version`
  - `hvigorw --version`
  - `hvigorw tasks --mode module -p module=entry@default -p product=default`
  - `hvigorw assembleHap --mode module -p module=entry@default -p product=default`
- 当前已知阻塞：
  - 已确认正确工具链来自 `F:\DevEco Studio\tools`，SDK 根路径为 `F:\DevEco Studio\sdk`。
  - 已写入 Windows 用户环境变量：`DEVECO_SDK_HOME=F:\DevEco Studio\sdk`，并将 DevEco 的 `node`、`hvigor`、`ohpm` 加入用户 `Path`。
  - `assembleHap` 已通过，详见 `docs/reports/phase_1_project_setup_report.md`。
- Preflight 未通过时，不开始 Phase 1 代码实现；只能维护计划、报告和工具链修复记录。

### Phase 1：HarmonyOS 骨架与设计 Token

- 整理基础工程信息：
  - 更新 `AppScope/app.json5`：正式 `bundleName`、`vendor`、`label`、版本号。
  - 更新 `entry/src/main/module.json5`：首版 `deviceTypes` 只保留 `phone`。
  - 清理模板文案与 `Hello World` 示例。
- 建立 ArkTS 分层目录：
  - `entry/src/main/ets/app`
  - `entry/src/main/ets/core/theme`
  - `entry/src/main/ets/core/utils`
  - `entry/src/main/ets/domain`
  - `entry/src/main/ets/data`
  - `entry/src/main/ets/features/home`
  - `entry/src/main/ets/features/assets`
  - `entry/src/main/ets/features/ledger`
  - `entry/src/main/ets/features/mine`
- 从 Flutter 计划和原型提炼 HarmonyOS 设计 token：
  - 浅绿背景：`#EEF4EE`
  - 深绿主色：`#0F5C50`
  - 珊瑚风险色：`#F07055`
  - 薄荷状态面：`#D7F0E5`
  - 文本主色：`#16211D`
  - 弱文本：`#64706A`
  - 8vp 圆角
  - 34vp 图标按钮
  - 78vp 底部导航高度
  - 紧凑移动端间距层级
- 替换首页为 Phase 1 基础首屏：
  - 应用名“戒烟有数”
  - 副标题“真实成本 A1 · HarmonyOS Phase 1”
  - 肺部负担指数
  - 风险提示：“当日危害警示分用于行为干预，不代表医学诊断。”
  - 真实日耗、健康负债、取出一支按钮
- 接入肺部素材：
  - 将 Flutter 资源 `assets/images/human-lungs-nih.png` 迁移到 HarmonyOS `resources/base/media/`。
  - 用 ArkUI `Image($r('app.media.xxx'))` 渲染。
- UI 验证：
  - 启动基础 App，检查首屏主题、背景、字体层级、资源加载与原型风格一致。
  - 以 `390x844` 作为原型对齐基准验收尺寸，不作为固定实现尺寸。
  - 如本阶段暂不能完成多尺寸验证，报告必须说明原因和补验计划。
- 功能验证：
  - App 可启动。
  - `EntryAbility` 正常进入首页。
  - 无白屏、红屏、异常日志。
- 报告：`docs/reports/phase_1_project_setup_report.md`。
- 门禁：等待用户确认报告后再进入 Phase 2。

### Phase 2：Domain、算法与状态主闭环

- 按 `docs/product_spec.md` 第 11 节实现 `QuitCalculator`，并将更细的 `lungScore`、`dailyHarmScore` 分段固定在代码和测试中。
- 按 `docs/product_spec.md` 第 3、6、7、9、10、15 节建立领域实体：库存资产、账本事件、目标、设置、风险快照、本地同步占位状态。
- 建立状态主闭环：
  - 使用 ArkTS ViewModel 管理页面状态。
  - 页面只触发 action，不直接修改仓储数据。
  - 首版先用内存 Repository 跑通库存、账本、目标、设置、取烟、放回、清空。
- UI 验证：
  - 最小状态展示仍使用 Phase 1 设计 token。
  - 不出现默认模板样式裸露。
- 功能验证：
  - `QuitCalculator` 单元测试。
  - ViewModel action 单元测试。
- 报告：`docs/reports/phase_2_domain_state_report.md`。
- 门禁：等待用户确认报告后再进入 Phase 3。

### Phase 3：核心手机 UI

- 使用 ArkUI 严格复刻原型手机端页面，并以 `docs/product_spec.md` 第 4-8、12、13、17 节作为产品规则基准：
  - `01-home`
  - `02-home-info-modal`
  - `03-take-sheet`
  - `04-assets`
  - `05-add-asset-modal`
  - `05-add-asset-errors`
  - `06-ledger`
  - `07-ledger-info-modal`
  - `08-model`
  - `09-mine`
  - `13-goal-modal`
  - `14-help-modal`
  - `15-help-update-feedback`
  - `16-settings`
  - `18-daily-review-modal`
  - `19-login`
  - `20-mine-synced`
  - `21-login-synced`
- 首版排除手表端截图：
  - `10-watch-status`
  - `11-watch-quick`
  - `12-watch-review`
- 页面结构、底部导航、二级入口、首页指标、资产表单、账本布局、我的页内容均以 `docs/product_spec.md` 为准。
- UI 验证：
  - 逐页对照 full-validation 截图。
  - 允许平台字体、安全区和触摸反馈细微差异。
  - 不允许改变整体风格、布局层级和关键组件位置。
- 功能验证：
  - Tab 切换。
  - 资产表单校验。
  - 默认资产展示。
  - 账本渲染。
- 报告：`docs/reports/phase_3_core_ui_report.md`。
- 门禁：等待用户确认报告后再进入 Phase 4。

### Phase 4：关键交互与产品规则

- 按 `docs/product_spec.md` 第 9、10、13、14 节实现取烟流程、放回规则、严厉危害警示、重置本地数据、小 i 说明弹窗和通知边界；如原型或旧计划残留“严厉危害警示阻止取烟”，以规格为准：不阻止取烟，提交成功后只通过手机系统通知栏三连提醒。
- HarmonyOS 侧用原生 Sheet、Dialog、Notification Kit 能力落地，不照搬 Flutter 控件结构。
- UI 验证：
  - 对照说明弹窗、重置弹窗、模型页、每日复盘弹窗截图。
- 功能验证：
  - 取烟提交。
  - 通知服务调用。
  - 重置取消。
  - 重置确认。
  - 小 i 弹窗。
- 报告：`docs/reports/phase_4_interactions_report.md`。
- 门禁：等待用户确认报告后再进入 Phase 5。

### Phase 5：本地存储、通知、导出、同步占位

- 按 `docs/product_spec.md` 第 14、15 节实现通知、本地数据与导出规则。
- HarmonyOS 本地存储：
  - 使用 HarmonyOS Preferences 存目标、默认资产、设置开关、同步占位状态。
  - 使用 RDB Store 或关系型数据库封装库存、账本、每日记录。
  - 仓储层隐藏具体存储实现，页面只依赖 ViewModel。
- HarmonyOS 通知：
  - 使用 Notification Kit 实现严厉危害三连提醒。
  - 三连提醒只出现在系统通知栏。
  - 使用系统通知实现每日复盘提醒。
  - 打开 APP 后每日复盘只显示单个复盘弹窗。
- HarmonyOS 导出：
  - 生成 CSV 账本内容。
  - 使用系统文件保存能力或分享能力导出。
- 同步占位：
  - 账户与同步页只做模拟登录、关闭同步和状态展示。
  - 不接真实云端服务。
- 权限与异常处理：
  - 通知权限未开启时，在设置页展示状态和引导入口。
  - 导出失败要给出轻量错误反馈。
  - 存储读写失败要保留可恢复提示，不丢当前内存状态。
- UI 验证：
  - 设置页权限状态。
  - 账户与同步页。
  - 导出入口。
  - 复盘弹窗。
- 功能验证：
  - 重启后数据仍在。
  - 系统通知栏收到三连提醒。
  - APP 内无三连提示。
  - CSV 内容正确。
- 报告：`docs/reports/phase_5_services_persistence_report.md`。
- 门禁：等待用户确认报告后再进入 Phase 6。

### Phase 6：测试与验收

- 按 `docs/product_spec.md` 第 17 节完成共同验收与关键测试。
- HarmonyOS 侧补齐：
  - calculator 单元测试。
  - repository 单元测试。
  - ViewModel action 测试。
  - 关键 UI 组件测试。
  - 端到端手工验收记录。
- 验收尺寸必须包含 `390x844` 原型对齐基准，并覆盖至少一个小屏、一个常规 Harmony/Android 手机尺寸、一个大屏尺寸。
- UI 验收：
  - 按 full-validation 截图逐页记录对照结果。
  - 可微调安全区、平台字体和触摸反馈。
  - 不得改变整体视觉风格。
- 报告：`docs/reports/phase_6_testing_acceptance_report.md`。
- 门禁：等待用户确认最终报告后结束首版阶段。

## Report Template

每个阶段报告必须包含：

- 阶段目标
- 已完成内容
- 新增或修改文件
- UI 验证方式与结果
- UI 验证尺寸清单与结果
- 功能验证方式与结果
- 原型截图对照结果
- 验证命令与结果
- 未能验证的内容和原因
- 遗留问题
- 下一阶段注意事项
- 用户确认状态：待确认 / 已确认

## Fixed Product Rules

- 共同产品规则不在本计划重复维护，统一以 `docs/product_spec.md` 为准。
- 本计划只保留 HarmonyOS 平台实施差异、阶段拆分、工具链门禁和报告节奏。
- 如果本计划与 `docs/product_spec.md` 冲突，以 `docs/product_spec.md` 为准，并在同一阶段修订本计划。

## Future Wearable Companion

手表端不进入 HarmonyOS 手机端首版。未来若启用穿戴端，以 `docs/product_spec.md` 第 16 节为产品边界，并单独评估 HarmonyOS wearable module 或独立工程。

## HarmonyOS 技术注意事项

- ArkUI 页面优先组件化拆分，避免单个 `Index.ets` 膨胀。
- 领域算法必须与 Flutter 计划保持一致，避免两个端出现指标差异。
- 通知能力需要真机或可用模拟器验证，不能只做源码级确认。
- RDB/Preferences 接入前先封装 Repository 接口，便于 Phase 2 使用内存实现、Phase 5 替换为持久化实现。
- 若 DevEco Studio 或 HarmonyOS SDK 不在命令行 PATH，阶段报告需明确记录无法编译/运行的原因，并在 SDK 可用后补做验证。
