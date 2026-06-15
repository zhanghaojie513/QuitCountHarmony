import { AppColors, AppSpacing, AppText } from '../../core/theme/AppTheme';
import { PreferencesQuitRepository } from '../../data/QuitRepository';
import { AddAssetErrors, AddAssetForm, AssetValidator } from '../../domain/AssetValidator';
import { AppSettings, GoalSettings, InventoryAsset, LedgerEntry } from '../../domain/models/QuitModels';
import { CsvExportResult, CsvExportService } from '../../services/CsvExportService';
import { NotificationResult, QuitNotificationService } from '../../services/NotificationService';
import { HomeSummary, QuitHomeViewModel } from '../home/QuitHomeViewModel';
import common from '@ohos.app.ability.common';

interface AssetCardState {
  id: string;
  brand: string;
  isDefault: boolean;
  riskLabel: string;
  stockCount: number;
  tarMg: number;
  nicotineMg: number;
  stockValue: string;
}

@Component
export struct QuitCountShell {
  private viewModel: QuitHomeViewModel = new QuitHomeViewModel();
  private notificationService: QuitNotificationService = new QuitNotificationService();
  private csvExportService: CsvExportService = new CsvExportService();

  @State private currentTab: number = 0;
  @State private showAddAsset: boolean = false;
  @State private showTakeSmoke: boolean = false;
  @State private showInfo: boolean = false;
  @State private showResetConfirm: boolean = false;
  @State private showRetireConfirm: boolean = false;
  @State private showDailyReview: boolean = false;
  @State private hasShownDailyReview: boolean = false;
  @State private activePanel: string = '';
  @State private infoTitle: string = '';
  @State private infoBody: string = '';
  @State private selectedAssetId: string = '';
  @State private smokeScene: string = '日常';
  @State private smokeNote: string = '';
  @State private brand: string = '';
  @State private tarMgText: string = '';
  @State private nicotineMgText: string = '';
  @State private stockCountText: string = '';
  @State private packPriceText: string = '';
  @State private brandError: string = '';
  @State private tarMgError: string = '';
  @State private nicotineMgError: string = '';
  @State private stockCountError: string = '';
  @State private packPriceError: string = '';
  @State private errorSummary: string = '';
  @State private todayTaken: number = 0;
  @State private dailyTarget: number = 0;
  @State private stockCount: number = 0;
  @State private realDailyCost: number = 0;
  @State private netHealth: number = 0;
  @State private healthDebtMinutes: number = 0;
  @State private dailyHarmScore: number = 0;
  @State private strictAlert: boolean = false;
  @State private goalDailyTargetText: string = '';
  @State private goalInterventionLineText: string = '';
  @State private goalError: string = '';
  @State private strictRiskAlertEnabled: boolean = true;
  @State private smokeFeedbackEnabled: boolean = true;
  @State private dailyReviewEnabled: boolean = true;
  @State private dailyReviewTime: string = '21:30';
  @State private dailyReviewTimeText: string = '21:30';
  @State private dailyReviewTimeError: string = '';
  @State private localFirstEnabled: boolean = true;
  @State private syncEnabled: boolean = false;
  @State private notificationStatusText: string = '通知权限状态待检测';
  @State private lastStrictNotificationText: string = '尚未触发严厉危害警示';
  @State private dailyReviewReminderText: string = '每日复盘系统提醒待同步';
  @State private storageStatusText: string = '本地存储待初始化';
  @State private exportStatusText: string = '尚未导出 CSV';
  @State private accountStatusText: string = '未登录；首版仅保留账户与同步占位，本地数据优先。';
  @State private feedbackText: string = '';
  @State private feedbackError: string = '';
  @State private ledgerRows: string[] = [];
  @State private assetRows: string[] = [];
  @State private assetCards: AssetCardState[] = [];
  @State private assetIds: string[] = [];
  @State private assetLabels: string[] = [];

  aboutToAppear() {
    this.installPersistentRepository();
    this.refresh();
    this.refreshNotificationStatus();
    this.syncDailyReviewReminder();
    this.maybeShowDailyReview();
  }

  build() {
    Stack() {
      Column() {
        if (this.currentTab === 0) {
          this.HomeTab()
        } else if (this.currentTab === 1) {
          this.AssetsTab()
        } else if (this.currentTab === 2) {
          this.LedgerTab()
        } else {
          this.MineTab()
        }

        this.BottomNavigation()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.pageBase)

      if (this.showAddAsset) {
        this.AddAssetDialog()
      }

      if (this.showTakeSmoke) {
        this.TakeSmokeDialog()
      }

      if (this.activePanel.length > 0) {
        this.PanelDialog()
      }

      if (this.showResetConfirm) {
        this.ResetConfirmDialog()
      }

      if (this.showRetireConfirm) {
        this.RetireStockDialog()
      }

      if (this.showDailyReview) {
        this.DailyReviewDialog()
      }

      if (this.showInfo) {
        this.InfoDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private HomeTab() {
    Scroll() {
      Column() {
        this.PageHeader('戒烟有数', '看见库存、当日危害与健康负债')

        Row() {
          Text('当日危害')
            .fontSize(AppText.labelSize)
            .fontColor(AppColors.muted)
            .fontWeight(FontWeight.Medium)
          Blank()
          this.InfoButton('当日危害', '当日危害警示分表示今天行为风险，不等同于长期健康净值。非医学诊断，仅用于行为反馈/自我管理。')
        }
        .width('100%')
        .margin({ top: AppSpacing.lg })

        Row() {
          Text(this.dailyHarmScore.toFixed(0))
            .fontSize(AppText.metricSize)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
          Text('/100')
            .fontSize(AppText.bodySize)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.ink)
            .margin({ left: AppSpacing.xs, bottom: 12 })
        }
        .alignItems(VerticalAlign.Bottom)
        .width('100%')

        Image($r('app.media.human_lungs_nih'))
          .objectFit(ImageFit.Contain)
          .height(AppSpacing.lungVisualHeight)
          .width('100%')
          .margin({ top: AppSpacing.md })

        Row() {
          this.MetricCard('今日已取出', `${this.todayTaken}/${this.dailyTarget} 支`)
          Blank().width(AppSpacing.sm)
          this.MetricCard('库存支数', `${this.stockCount} 支`)
        }
        .width('100%')
        .margin({ top: AppSpacing.md })

        Row() {
          this.MetricCard('真实日耗', `¥${this.realDailyCost.toFixed(1)}`)
          Blank().width(AppSpacing.sm)
          this.MetricInfoCard('健康净值', this.netHealth.toFixed(0), '健康净值',
            '健康净值 = clamp(100 - lungScore, 0, 100)。lungScore 是综合负担指数，不等同于当日危害警示分。')
        }
        .width('100%')
        .margin({ top: AppSpacing.sm })

        Row() {
          this.MetricInfoCard('健康负债', `${(this.healthDebtMinutes / 60).toFixed(1)}小时`, '健康负债',
            '首页健康负债按今日已取出支数折算：healthMinutes = cigarettes * 20，可显示为分钟或小时。库存健康负债在资产页单独展示。')
          Blank().width(AppSpacing.sm)
          this.MetricCard('健康折算', `${this.healthDebtMinutes}分钟`)
        }
        .width('100%')
        .margin({ top: AppSpacing.sm })

        if (this.strictAlert) {
          this.WarningStrip('已达到干预线：记录成功后仅通过系统通知栏提醒，不阻止取烟。')
        } else {
          this.WarningStrip('所有指标均非医学诊断，仅用于行为反馈/自我管理。')
        }

        Button('取出一支')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(52)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.primary)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.openTakeSmoke();
          })

        Button('放回库存')
          .fontSize(15)
          .fontColor(AppColors.primary)
          .height(46)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.surfaceMint)
          .margin({ top: AppSpacing.sm })
          .onClick(() => {
            this.viewModel.returnLastSmoke();
            this.refresh();
          })
      }
      .padding({ left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.pageBottomPadding })
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.contentMaxWidth })
    }
    .layoutWeight(1)
  }

  @Builder
  private AssetsTab() {
    Scroll() {
      Column() {
        this.PageHeader('资产', '库存不是存量，是潜在健康负债')

        Row() {
          this.MetricCard('香烟库存净值', `¥${(this.stockCount * 3).toFixed(0)}`)
          Blank().width(AppSpacing.sm)
          this.MetricCard('库存健康负债', `${(this.stockCount * 20 / 60).toFixed(1)}小时`)
        }
        .width('100%')
        .margin({ top: AppSpacing.lg })

        Button('添加资产')
          .fontSize(16)
          .fontColor(Color.White)
          .height(48)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.primary)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.openAddAsset();
          })

        Button('清空库存并记录退役')
          .fontSize(16)
          .fontColor(AppColors.danger)
          .height(46)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.riskSoft)
          .margin({ top: AppSpacing.sm })
          .onClick(() => {
            this.openRetireConfirm();
          })

        ForEach(this.assetCards, (asset: AssetCardState) => {
          this.AssetCard(asset)
        }, (asset: AssetCardState) => asset.id)
      }
      .padding({ left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.pageBottomPadding })
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.contentMaxWidth })
    }
    .layoutWeight(1)
  }

  @Builder
  private LedgerTab() {
    Scroll() {
      Column() {
        this.PageHeader('账本', '今日流转，用记录复盘行为')

        Row() {
          Column() {
            Text('当日危害警示分')
              .fontSize(AppText.labelSize)
              .fontColor(AppColors.muted)
            Text(this.dailyHarmScore.toFixed(0))
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.ink)
              .margin({ top: AppSpacing.xs })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          this.InfoButton('当日危害警示分', '该分数只表示当日行为风险，用于提醒和复盘，不代表医学诊断。')
        }
        .padding(AppSpacing.md)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surface)
        .margin({ top: AppSpacing.lg })

        if (this.ledgerRows.length === 0) {
          this.EmptyState('今天还没有账本记录。点击首页“取出一支”开始记录。')
        } else {
          ForEach(this.ledgerRows, (row: string) => {
            this.ListCard(row, '包含品牌、时间、焦油、成本、健康折算与备注')
          }, (row: string) => row)
        }
      }
      .padding({ left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.pageBottomPadding })
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.contentMaxWidth })
    }
    .layoutWeight(1)
  }

  @Builder
  private MineTab() {
    Scroll() {
      Column() {
        this.PageHeader('我的', '目标、模型、设置与本地优先')
        this.MineItem('戒烟目标', `每日目标 ${this.dailyTarget} 支`, 'goal')
        this.MineItem('模型与证据', '查看公式口径、公开参考与局限', 'model')
        this.MineItem('设置', '严厉危害警示、每日复盘、本地优先', 'settings')
        this.MineItem('账户与同步', '首版为模拟登录与状态展示', 'account')
        this.MineItem('帮助与关于', '当前已是最新版本 · 可提交反馈', 'help')
        this.MineItem('导出戒烟账本', 'CSV 导出入口', 'export')
        this.MineItem('手表端说明', '未来只做轻量状态、快记与撤销', 'watch')
      }
      .padding({ left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.pageBottomPadding })
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.contentMaxWidth })
    }
    .layoutWeight(1)
  }

  @Builder
  private BottomNavigation() {
    Row() {
      this.TabButton(0, '首页')
      this.TabButton(1, '资产')
      this.TabButton(2, '账本')
      this.TabButton(3, '我的')
    }
    .height(AppSpacing.bottomNavHeight + AppSpacing.bottomSafeGap)
    .width('100%')
    .padding({ left: AppSpacing.md, right: AppSpacing.md, bottom: AppSpacing.bottomSafeGap })
    .backgroundColor(AppColors.surface)
  }

  @Builder
  private AddAssetDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Text('添加资产')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
            .layoutWeight(1)
          this.CloseButton(() => {
            this.showAddAsset = false;
          })
        }
        .width('100%')

        this.InputField('品牌', this.brand, this.brandError, (value: string) => {
          this.brand = value;
        })
        this.InputField('焦油 mg', this.tarMgText, this.tarMgError, (value: string) => {
          this.tarMgText = value;
        })
        this.InputField('尼古丁 mg', this.nicotineMgText, this.nicotineMgError, (value: string) => {
          this.nicotineMgText = value;
        })
        this.InputField('库存支数', this.stockCountText, this.stockCountError, (value: string) => {
          this.stockCountText = value;
        })
        this.InputField('整包价格 元', this.packPriceText, this.packPriceError, (value: string) => {
          this.packPriceText = value;
        })

        if (this.errorSummary.length > 0) {
          Text(this.errorSummary)
            .fontSize(AppText.labelSize)
            .fontColor(AppColors.danger)
            .width('100%')
            .margin({ top: AppSpacing.sm })
        }

        Button('保存资产')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(48)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.primary)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.submitAssetForm();
          })
      }
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private TakeSmokeDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Text('取出一支')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
            .layoutWeight(1)
          this.CloseButton(() => {
            this.showTakeSmoke = false;
          })
        }
        .width('100%')

        Text('默认资产排第一，可选择资产、场景和备注。')
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.sm })
          .width('100%')

        ForEach(this.assetLabels, (label: string) => {
          Button(this.takeAssetButtonLabel(label))
            .fontSize(15)
            .fontColor(this.selectedAssetId === this.assetIdForLabel(label) ? Color.White : AppColors.primary)
            .height(44)
            .width('100%')
            .borderRadius(AppSpacing.radius)
            .backgroundColor(this.selectedAssetId === this.assetIdForLabel(label) ? AppColors.primary : AppColors.surfaceMint)
            .margin({ top: AppSpacing.sm })
            .onClick(() => {
              this.selectedAssetId = this.assetIdForLabel(label);
            })
        }, (label: string) => label)

        TextInput({ text: this.smokeScene, placeholder: '场景，例如：饭后、加班、社交' })
          .height(44)
          .width('100%')
          .fontSize(15)
          .backgroundColor(AppColors.pageBase)
          .borderRadius(AppSpacing.radius)
          .margin({ top: AppSpacing.md })
          .onChange((value: string) => {
            this.smokeScene = value;
          })

        TextInput({ text: this.smokeNote, placeholder: '备注（选填，常驻显示）' })
          .height(44)
          .width('100%')
          .fontSize(15)
          .backgroundColor(AppColors.pageBase)
          .borderRadius(AppSpacing.radius)
          .margin({ top: AppSpacing.sm })
          .onChange((value: string) => {
            this.smokeNote = value;
          })

        Button('记录取出')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(48)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.primary)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.submitTakeSmoke();
          })
      }
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private PanelDialog() {
    Column() {
      Column() {
        Row() {
          Text(this.panelTitle())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
            .layoutWeight(1)
          this.CloseButton(() => {
            this.activePanel = '';
          })
        }
        .width('100%')

        if (this.activePanel === 'goal') {
          this.GoalPanel()
        } else if (this.activePanel === 'settings') {
          this.SettingsPanel()
        } else if (this.activePanel === 'model') {
          this.ModelPanel()
        } else if (this.activePanel === 'account') {
          this.AccountPanel()
        } else if (this.activePanel === 'help') {
          this.HelpPanel()
        } else if (this.activePanel === 'export') {
          this.ExportPanel()
        } else if (this.activePanel === 'watch') {
          this.StaticPanel('手表端说明', '手机端首版不实现完整手表端。未来只保留今日状态、快记一支、长按撤销、复盘入口和跳转手机端账本或同步状态。')
        }
      }
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.contentMaxWidth })
      .height('100%')
      .backgroundColor(AppColors.pageBase)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.pageBase)
  }

  @Builder
  private GoalPanel() {
    Column() {
      TextInput({ text: this.goalDailyTargetText, placeholder: '每日目标支数' })
        .height(44)
        .width('100%')
        .fontSize(15)
        .backgroundColor(AppColors.surface)
        .borderRadius(AppSpacing.radius)
        .margin({ top: AppSpacing.md })
        .onChange((value: string) => {
          this.goalDailyTargetText = value;
        })
      TextInput({ text: this.goalInterventionLineText, placeholder: '干预线支数' })
        .height(44)
        .width('100%')
        .fontSize(15)
        .backgroundColor(AppColors.surface)
        .borderRadius(AppSpacing.radius)
        .margin({ top: AppSpacing.sm })
        .onChange((value: string) => {
          this.goalInterventionLineText = value;
        })
      if (this.goalError.length > 0) {
        Text(this.goalError)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.danger)
          .margin({ top: AppSpacing.sm })
      }
      Button('保存戒烟目标')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(48)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.primary)
        .margin({ top: AppSpacing.md })
        .onClick(() => {
          this.submitGoal();
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  private SettingsPanel() {
    Column() {
      this.SettingToggle('严厉危害警示', '达到干预线后不阻止取烟，提交成功后通过手机系统通知栏提醒。', this.strictRiskAlertEnabled, 'strict')
      this.SettingToggle('取烟反馈', '记录成功后更新库存、账本和首页指标。', this.smokeFeedbackEnabled, 'feedback')
      this.SettingToggle('每日复盘提醒', `当前 ${this.dailyReviewTime} 通过系统通知提醒，打开 APP 后显示单个复盘弹窗。`, this.dailyReviewEnabled, 'review')
      this.InputField('每日复盘时间 HH:mm', this.dailyReviewTimeText, this.dailyReviewTimeError, (value: string) => {
        this.dailyReviewTimeText = value;
        this.dailyReviewTimeError = '';
      })
      Button('保存复盘时间')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.submitDailyReviewTime();
        })
      this.SettingToggle('隐私优先/本地优先', '库存、目标、设置和账本优先保存在本地。', this.localFirstEnabled, 'local')
      this.SettingToggle('跨设备同步入口', '首版只展示占位状态，不进行真实云同步。', this.syncEnabled, 'sync')
      this.ListCard('本地存储状态', this.storageStatusText)
      this.ListCard('通知权限状态', this.notificationStatusText)
      Button('申请通知权限')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.requestNotificationPermission();
        })
      this.ListCard('严厉危害警示最近结果', this.lastStrictNotificationText)
      this.ListCard('每日复盘系统提醒', this.dailyReviewReminderText)
      this.ListCard('导出戒烟账本', 'CSV 包含时间、动作、品牌、焦油、成本、健康折算、备注')
      Button('打开导出入口')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.openPanel('export');
        })
      this.ListCard('本地数据记录数', `${this.ledgerRows.length} 条账本记录 · ${this.stockCount} 支库存`)
      Button('重置本地数据')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(48)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.danger)
        .margin({ top: AppSpacing.md })
        .onClick(() => {
          this.showResetConfirm = true;
        })
    }
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private ModelPanel() {
    Column() {
      this.ListCard('今日包年增量', 'todayPackYearIncrement = todayCigarettes / 20 / 365')
      this.ListCard('健康折算', 'healthMinutes = cigarettes * 20，可显示为分钟或小时')
      this.ListCard('库存潜在包年', 'stockPotentialPackYears = stockCount / 20 / 365')
      this.ListCard('健康净值', 'netHealth = clamp(100 - lungScore, 0, 100)，不得使用 100 - dailyHarmScore')
      this.ListCard('当日危害警示分', 'dailyHarmScore 表示当日行为风险，用于警示和复盘')
      this.ListCard('健康负债', '首页按今日已取出支数折算；库存健康负债 = stockCount * 20 分钟')
      this.ListCard('计算口径', '所有指标来自本地账本、库存和目标设置；页面展示分钟或小时只是单位换算')
      this.ListCard('公开模型参考与局限', '包年、焦油/尼古丁和行为风险只用于自我管理反馈，不能替代医生评估或治疗建议')
      this.ListCard('合规提示', '所有指标均非医学诊断，仅用于行为反馈/自我管理')
    }
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private HelpPanel() {
    Column() {
      this.ListCard('当前版本', '戒烟有数 Harmony 原型实现 0.1.0')
      Button('检查更新')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.infoTitle = '检查更新';
          this.infoBody = '当前已是最新版本。';
          this.showInfo = true;
        })
      TextInput({ text: this.feedbackText, placeholder: '提交反馈（选填联系方式或问题描述）' })
        .height(44)
        .width('100%')
        .fontSize(15)
        .backgroundColor(AppColors.surface)
        .borderRadius(AppSpacing.radius)
        .margin({ top: AppSpacing.md })
        .onChange((value: string) => {
          this.feedbackText = value;
          this.feedbackError = '';
        })
      if (this.feedbackError.length > 0) {
        Text(this.feedbackError)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.danger)
          .margin({ top: AppSpacing.xs })
      }
      Button('提交反馈')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.submitFeedback();
        })
    }
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private AccountPanel() {
    Column() {
      this.ListCard('账户状态', this.accountStatusText)
      this.ListCard('同步策略', this.syncEnabled ? '同步入口已开启：首版仍不上传云端，仅展示未来状态。' : '同步入口已关闭：库存、账本、目标和设置保持本地优先。')
      Button('模拟登录')
        .fontSize(16)
        .fontColor(AppColors.primary)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.surfaceMint)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.accountStatusText = '已模拟登录；首版不进行真实云同步，数据仍保存在本地。';
        })
      Button('关闭同步占位')
        .fontSize(16)
        .fontColor(AppColors.danger)
        .height(44)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.riskSoft)
        .margin({ top: AppSpacing.sm })
        .onClick(() => {
          this.syncEnabled = false;
          this.accountStatusText = '同步占位已关闭；本地数据不受影响。';
          this.viewModel.updateSettings(
            this.strictRiskAlertEnabled,
            this.smokeFeedbackEnabled,
            this.dailyReviewEnabled,
            this.localFirstEnabled,
            false,
            this.dailyReviewTime
          );
          this.refresh();
        })
      Text('首版不包含真正云同步，不会上传库存、账本或目标。')
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.md })
    }
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private ExportPanel() {
    Column() {
      this.ListCard('CSV 导出预览', this.viewModel.exportLedgerCsv())
      Button('保存 CSV 文件')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(48)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.primary)
        .margin({ top: AppSpacing.md })
        .onClick(() => {
          this.exportLedgerCsv();
        })
      Text(this.exportStatusText)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.ink)
        .margin({ top: AppSpacing.sm })
      Text('已导出的文件不受重置本地数据影响。当前阶段保存到应用文件目录，后续可接入系统分享或文件选择器。')
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.sm })
    }
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private StaticPanel(title: string, body: string) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.ink)
      Text(body)
        .fontSize(AppText.bodySize)
        .fontColor(AppColors.ink)
        .lineHeight(22)
        .margin({ top: AppSpacing.sm })
      Text('非医学诊断，仅用于行为反馈/自我管理。')
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.md })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private ResetConfirmDialog() {
    Column() {
      Blank()
      Column() {
        Text('高风险操作')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.danger)
        Text(`当前本地记录数 ${this.ledgerRows.length} 条，库存 ${this.stockCount} 支。`)
          .fontSize(AppText.bodySize)
          .fontColor(AppColors.ink)
          .margin({ top: AppSpacing.sm })
        Text('确认后会恢复初始库存、清空当前同步状态，并重置账本、目标和设置；不会影响已导出的文件。')
          .fontSize(AppText.bodySize)
          .fontColor(AppColors.ink)
          .lineHeight(22)
          .margin({ top: AppSpacing.sm })
        Button('取消')
          .fontSize(16)
          .fontColor(AppColors.primary)
          .height(44)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.surfaceMint)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.showResetConfirm = false;
          })
        Button('确认重置')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(44)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.danger)
          .margin({ top: AppSpacing.sm })
          .onClick(() => {
            this.viewModel.resetLocalData();
            this.showResetConfirm = false;
            this.activePanel = '';
            this.refresh();
          })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private RetireStockDialog() {
    Column() {
      Blank()
      Column() {
        Text('清空库存并记录退役')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.ink)
        Text(`当前库存 ${this.stockCount} 支。确认后库存会归零，并在账本中记录一次退役事件。`)
          .fontSize(AppText.bodySize)
          .fontColor(AppColors.ink)
          .lineHeight(22)
          .margin({ top: AppSpacing.sm })
        Text('不会重置戒烟目标、设置、同步状态，也不会影响已导出的 CSV 文件。')
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.sm })
        Button('取消')
          .fontSize(16)
          .fontColor(AppColors.primary)
          .height(44)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.surfaceMint)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.showRetireConfirm = false;
          })
        Button('确认退役库存')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(44)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.danger)
          .margin({ top: AppSpacing.sm })
          .onClick(() => {
            this.confirmRetireStock();
          })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private DailyReviewDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Text('每日复盘')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
            .layoutWeight(1)
          this.CloseButton(() => {
            this.showDailyReview = false;
          })
        }
        .width('100%')
        Text(`今天已取出 ${this.todayTaken} 支，库存 ${this.stockCount} 支，当日危害警示分 ${this.dailyHarmScore.toFixed(0)}。`)
          .fontSize(AppText.bodySize)
          .fontColor(AppColors.ink)
          .lineHeight(22)
          .margin({ top: AppSpacing.sm })
        Text('复盘只帮助看见行为，不做医学诊断或治疗建议。')
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.sm })
        Button('查看账本')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .height(48)
          .width('100%')
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.primary)
          .margin({ top: AppSpacing.md })
          .onClick(() => {
            this.showDailyReview = false;
            this.currentTab = 2;
          })
      }
      .alignItems(HorizontalAlign.Start)
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private InfoDialog() {
    Column() {
      Blank()
      Column() {
        Row() {
          Text(this.infoTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
            .layoutWeight(1)
          this.CloseButton(() => {
            this.showInfo = false;
          })
        }
        .width('100%')
        Text(this.infoBody)
          .fontSize(AppText.bodySize)
          .fontColor(AppColors.ink)
          .lineHeight(22)
          .margin({ top: AppSpacing.md })
        Text('非医学诊断，仅用于行为反馈/自我管理。')
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.md })
      }
      .padding(AppSpacing.lg)
      .width('100%')
      .constraintSize({ maxWidth: AppSpacing.dialogMaxWidth })
      .borderRadius({ topLeft: 18, topRight: 18 })
      .backgroundColor(AppColors.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#66000000')
  }

  @Builder
  private PageHeader(title: string, subtitle: string) {
    Column() {
      Text(title)
        .fontSize(AppText.titleSize)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.ink)
      Text(subtitle)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.xs })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  private MetricCard(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
      Text(value)
        .fontSize(AppText.bodySize)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.ink)
        .maxLines(1)
        .margin({ top: AppSpacing.xs })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(AppSpacing.sm)
    .layoutWeight(1)
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surfaceMint)
  }

  @Builder
  private MetricInfoCard(label: string, value: string, infoTitle: string, infoBody: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .layoutWeight(1)
        this.TinyInfoButton(infoTitle, infoBody)
      }
      .width('100%')
      Text(value)
        .fontSize(AppText.bodySize)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.ink)
        .maxLines(1)
        .margin({ top: AppSpacing.xs })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(AppSpacing.sm)
    .layoutWeight(1)
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surfaceMint)
  }

  @Builder
  private AssetCard(asset: AssetCardState) {
    Column() {
      Row() {
        Text(asset.brand)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.ink)
          .layoutWeight(1)
        if (asset.isDefault) {
          this.LabelPill('默认取烟', AppColors.primary, AppColors.surfaceMint, 10)
        }
      }
      .width('100%')

      Text(`库存 ${asset.stockCount} 支 · 焦油 ${asset.tarMg}mg · 尼古丁 ${asset.nicotineMg}mg · ${asset.stockValue}`)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.xs })

      Row() {
        Text('风险标签')
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .layoutWeight(1)
        this.LabelPill(asset.riskLabel, AppColors.danger, AppColors.riskSoft, 12)
      }
      .width('100%')
      .margin({ top: AppSpacing.sm })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(AppSpacing.md)
    .width('100%')
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surface)
    .margin({ top: AppSpacing.sm })
  }

  @Builder
  private ListCard(title: string, subtitle: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.ink)
      Text(subtitle)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.xs })
    }
    .alignItems(HorizontalAlign.Start)
    .padding(AppSpacing.md)
    .width('100%')
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surface)
    .margin({ top: AppSpacing.sm })
  }

  @Builder
  private MineItem(title: string, subtitle: string, panel: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.ink)
        Text(subtitle)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.xs })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('›')
        .fontSize(24)
        .fontColor(AppColors.muted)
    }
    .padding(AppSpacing.md)
    .width('100%')
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surface)
    .margin({ top: AppSpacing.sm })
    .onClick(() => {
      this.openPanel(panel);
    })
  }

  @Builder
  private SettingToggle(title: string, subtitle: string, enabled: boolean, key: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.ink)
        Text(subtitle)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.muted)
          .margin({ top: AppSpacing.xs })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Button(enabled ? '开' : '关')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(enabled ? Color.White : AppColors.primary)
        .height(34)
        .width(54)
        .borderRadius(AppSpacing.radius)
        .backgroundColor(enabled ? AppColors.primary : AppColors.surfaceMint)
        .onClick(() => {
          this.toggleSetting(key);
        })
    }
    .padding(AppSpacing.md)
    .width('100%')
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.surface)
    .margin({ top: AppSpacing.sm })
  }

  @Builder
  private WarningStrip(text: string) {
    Row() {
      Text('!')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.danger)
      Text(text)
        .fontSize(AppText.bodySize)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.ink)
        .layoutWeight(1)
        .margin({ left: AppSpacing.sm })
    }
    .padding(AppSpacing.sm)
    .width('100%')
    .borderRadius(AppSpacing.radius)
    .backgroundColor(AppColors.riskSoft)
    .border({ width: 1, color: AppColors.risk })
    .margin({ top: AppSpacing.md })
  }

  @Builder
  private EmptyState(text: string) {
    Text(text)
      .fontSize(AppText.bodySize)
      .fontColor(AppColors.muted)
      .textAlign(TextAlign.Center)
      .padding(AppSpacing.lg)
      .width('100%')
      .borderRadius(AppSpacing.radius)
      .backgroundColor(AppColors.surface)
      .margin({ top: AppSpacing.md })
  }

  @Builder
  private TabButton(index: number, label: string) {
    Button(label)
      .fontSize(14)
      .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.currentTab === index ? Color.White : AppColors.primary)
      .height(44)
      .layoutWeight(1)
      .borderRadius(AppSpacing.radius)
      .backgroundColor(this.currentTab === index ? AppColors.primary : AppColors.surfaceMint)
      .margin({ left: 3, right: 3 })
      .onClick(() => {
        this.currentTab = index;
      })
  }

  @Builder
  private InfoButton(title: string, body: string) {
    Button('i')
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppColors.primary)
      .width(AppSpacing.iconButton)
      .height(AppSpacing.iconButton)
      .borderRadius(AppSpacing.radius)
      .backgroundColor(AppColors.surfaceMint)
      .onClick(() => {
        this.infoTitle = title;
        this.infoBody = body;
        this.showInfo = true;
      })
  }

  @Builder
  private TinyInfoButton(title: string, body: string) {
    Button('i')
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppColors.primary)
      .width(26)
      .height(26)
      .borderRadius(AppSpacing.radius)
      .backgroundColor(AppColors.surface)
      .onClick(() => {
        this.infoTitle = title;
        this.infoBody = body;
        this.showInfo = true;
      })
  }

  @Builder
  private LabelPill(label: string, color: string, backgroundColor: string, fontSize: number) {
    Text(label)
      .fontSize(fontSize)
      .fontWeight(FontWeight.Bold)
      .fontColor(color)
      .padding({ left: AppSpacing.xs, right: AppSpacing.xs, top: 3, bottom: 3 })
      .borderRadius(AppSpacing.radius)
      .backgroundColor(backgroundColor)
  }

  @Builder
  private CloseButton(action: () => void) {
    Button('×')
      .fontSize(20)
      .fontColor(AppColors.primary)
      .width(AppSpacing.iconButton)
      .height(AppSpacing.iconButton)
      .borderRadius(AppSpacing.radius)
      .backgroundColor(AppColors.surfaceMint)
      .onClick(action)
  }

  @Builder
  private InputField(label: string, value: string, error: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
      TextInput({ text: value, placeholder: label })
        .height(44)
        .width('100%')
        .fontSize(15)
        .fontColor(AppColors.ink)
        .backgroundColor(AppColors.pageBase)
        .borderRadius(AppSpacing.radius)
        .border({ width: error.length > 0 ? 1 : 0, color: error.length > 0 ? AppColors.danger : AppColors.border })
        .margin({ top: AppSpacing.xs })
        .onChange(onChange)
      if (error.length > 0) {
        Text(error)
          .fontSize(AppText.labelSize)
          .fontColor(AppColors.danger)
          .margin({ top: 4 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ top: AppSpacing.sm })
  }

  private openAddAsset(): void {
    this.brand = '';
    this.tarMgText = '';
    this.nicotineMgText = '';
    this.stockCountText = '';
    this.packPriceText = '';
    this.applyErrors(AssetValidator.emptyErrors());
    this.showAddAsset = true;
  }

  private installPersistentRepository(): void {
    try {
      const context = this.getAbilityContext();
      if (!context) {
        this.viewModel = new QuitHomeViewModel();
        this.storageStatusText = '本地存储初始化失败，当前会话暂用内存状态。';
        return;
      }
      const repository = new PreferencesQuitRepository(context);
      this.viewModel = new QuitHomeViewModel(repository);
      this.storageStatusText = repository.isPersistentReady()
        ? '本地优先已启用：库存、账本、目标和设置会写入 HarmonyOS Preferences。'
        : '本地存储初始化失败，当前会话暂用内存状态。';
    } catch (error) {
      this.viewModel = new QuitHomeViewModel();
      this.storageStatusText = '本地存储初始化失败，当前会话暂用内存状态。';
    }
  }

  private openTakeSmoke(): void {
    const state = this.viewModel.getState();
    const defaultAsset = state.assets.find((asset: InventoryAsset): boolean => asset.isDefault) ?? state.assets[0];
    this.selectedAssetId = defaultAsset.id;
    this.smokeScene = '日常';
    this.smokeNote = '';
    this.showTakeSmoke = true;
  }

  private openRetireConfirm(): void {
    if (this.stockCount <= 0) {
      this.infoTitle = '无需清空';
      this.infoBody = '当前库存已经是 0 支，没有写入退役事件。';
      this.showInfo = true;
      return;
    }
    this.showRetireConfirm = true;
  }

  private confirmRetireStock(): void {
    const entry = this.viewModel.clearStockAndRetire();
    this.showRetireConfirm = false;
    this.refresh();
    if (!entry) {
      this.infoTitle = '无需清空';
      this.infoBody = '当前库存已经是 0 支，没有写入退役事件。';
      this.showInfo = true;
      return;
    }
    this.infoTitle = '已记录退役';
    this.infoBody = '库存已清空，账本已记录退役事件。';
    this.showInfo = true;
  }

  private submitTakeSmoke(): void {
    const entry = this.viewModel.takeSmoke({
      assetId: this.selectedAssetId,
      scene: this.smokeScene,
      note: this.smokeNote
    });
    this.showTakeSmoke = false;
    this.refresh();
    if (!entry) {
      this.infoTitle = '无法取出';
      this.infoBody = '当前资产库存不足，未写入账本。';
      this.showInfo = true;
      return;
    }
    if (this.strictAlert) {
      this.scheduleStrictRiskNotifications();
    }
  }

  private openPanel(panel: string): void {
    const state = this.viewModel.getState();
    this.goalDailyTargetText = `${state.goal.dailyTarget}`;
    this.goalInterventionLineText = `${state.goal.interventionLine}`;
    this.goalError = '';
    this.activePanel = panel;
  }

  private submitAssetForm(): void {
    const form: AddAssetForm = {
      brand: this.brand,
      tarMgText: this.tarMgText,
      nicotineMgText: this.nicotineMgText,
      stockCountText: this.stockCountText,
      packPriceText: this.packPriceText
    };
    const errors = AssetValidator.validate(form);
    this.applyErrors(errors);
    if (AssetValidator.hasErrors(errors)) {
      return;
    }
    this.viewModel.addAsset(AssetValidator.parse(form));
    this.showAddAsset = false;
    this.refresh();
  }

  private submitGoal(): void {
    const dailyTarget = Number(this.goalDailyTargetText);
    const interventionLine = Number(this.goalInterventionLineText);
    if (dailyTarget !== dailyTarget || interventionLine !== interventionLine || dailyTarget < 0 || dailyTarget > 60 || interventionLine < 1 || interventionLine > 60) {
      this.goalError = '目标需为 0-60 支，干预线需为 1-60 支。';
      return;
    }
    this.viewModel.updateGoal(Math.floor(dailyTarget), Math.floor(interventionLine));
    this.activePanel = '';
    this.refresh();
  }

  private toggleSetting(key: string): void {
    if (key === 'strict') {
      this.strictRiskAlertEnabled = !this.strictRiskAlertEnabled;
    } else if (key === 'feedback') {
      this.smokeFeedbackEnabled = !this.smokeFeedbackEnabled;
    } else if (key === 'review') {
      this.dailyReviewEnabled = !this.dailyReviewEnabled;
    } else if (key === 'local') {
      this.localFirstEnabled = !this.localFirstEnabled;
    } else if (key === 'sync') {
      this.syncEnabled = !this.syncEnabled;
    }
    this.viewModel.updateSettings(
      this.strictRiskAlertEnabled,
      this.smokeFeedbackEnabled,
      this.dailyReviewEnabled,
      this.localFirstEnabled,
      this.syncEnabled,
      this.dailyReviewTime
    );
    this.refresh();
    this.refreshNotificationStatus();
    this.syncDailyReviewReminder();
    this.maybeShowDailyReview();
  }

  private exportLedgerCsv(): void {
    const context = this.getAbilityContext();
    if (!context) {
      this.exportStatusText = 'CSV 导出失败：无法获取应用文件目录。';
      return;
    }
    const result: CsvExportResult = this.csvExportService.saveLedgerCsv(context, this.viewModel.exportLedgerCsv());
    this.exportStatusText = result.success ? `${result.message}；路径：${result.path}` : result.message;
  }

  private submitFeedback(): void {
    if (this.feedbackText.trim().length === 0) {
      this.feedbackError = '请先输入反馈内容。';
      return;
    }
    this.feedbackError = '';
    this.feedbackText = '';
    this.infoTitle = '反馈已记录';
    this.infoBody = '感谢反馈。首版先在 App 内完成提交确认，后续可接入系统分享或邮件能力。';
    this.showInfo = true;
  }

  private requestNotificationPermission(): void {
    const context = this.getAbilityContext();
    if (!context) {
      this.notificationStatusText = '无法获取应用上下文，请稍后重试或在系统设置中开启通知权限。';
      return;
    }
    this.notificationService.requestPermission(context)
      .then((result: NotificationResult) => {
        this.notificationStatusText = result.message;
        this.refreshNotificationStatus();
      })
      .catch(() => {
        this.notificationStatusText = '无法发起通知权限申请，请在系统设置中检查通知权限。';
      });
  }

  private syncDailyReviewReminder(): void {
    if (this.dailyReviewEnabled) {
      this.notificationService.scheduleDailyReview(this.dailyReviewTime)
        .then((result: NotificationResult) => {
          this.dailyReviewReminderText = result.message;
        })
        .catch(() => {
          this.dailyReviewReminderText = '每日复盘系统提醒设置失败，请检查提醒/通知权限。';
        });
      return;
    }

    this.notificationService.cancelDailyReview()
      .then((result: NotificationResult) => {
        this.dailyReviewReminderText = result.message;
      })
      .catch(() => {
        this.dailyReviewReminderText = '每日复盘系统提醒关闭失败，请稍后重试。';
      });
  }

  private getAbilityContext(): common.UIAbilityContext | undefined {
    return this.getUIContext().getHostContext() as common.UIAbilityContext | undefined;
  }

  private applyErrors(errors: AddAssetErrors): void {
    this.brandError = errors.brand;
    this.tarMgError = errors.tarMg;
    this.nicotineMgError = errors.nicotineMg;
    this.stockCountError = errors.stockCount;
    this.packPriceError = errors.packPrice;
    this.errorSummary = errors.summary;
  }

  private panelTitle(): string {
    if (this.activePanel === 'goal') {
      return '戒烟目标';
    }
    if (this.activePanel === 'model') {
      return '模型与证据';
    }
    if (this.activePanel === 'settings') {
      return '设置';
    }
    if (this.activePanel === 'account') {
      return '账户与同步';
    }
    if (this.activePanel === 'help') {
      return '帮助与关于';
    }
    if (this.activePanel === 'export') {
      return '导出戒烟账本';
    }
    if (this.activePanel === 'watch') {
      return '手表端说明';
    }
    return '';
  }

  private takeAssetButtonLabel(label: string): string {
    if (this.selectedAssetId === this.assetIdForLabel(label)) {
      return `已选 · ${label}`;
    }
    return label;
  }

  private assetIdForLabel(label: string): string {
    const index = this.assetLabels.indexOf(label);
    if (index < 0 || index >= this.assetIds.length) {
      return '';
    }
    return this.assetIds[index];
  }

  private scheduleStrictRiskNotifications(): void {
    this.lastStrictNotificationText = '记录已成功，正在请求系统通知栏三连提醒。';
    this.notificationService.publishStrictRiskTriple()
      .then((result: NotificationResult) => {
        this.lastStrictNotificationText = result.message;
        this.refreshNotificationStatus();
      })
      .catch(() => {
        this.lastStrictNotificationText = '系统通知发送失败，记录已成功保留。';
        this.refreshNotificationStatus();
      });
  }

  private refreshNotificationStatus(): void {
    this.notificationService.isEnabled()
      .then((enabled: boolean) => {
        this.notificationStatusText = enabled ? '通知权限已授权' : '通知权限未授权，取烟记录仍会成功保存。';
      })
      .catch(() => {
        this.notificationStatusText = '通知权限状态无法读取，取烟记录仍会成功保存。';
      });
  }

  private maybeShowDailyReview(): void {
    if (!this.dailyReviewEnabled || this.hasShownDailyReview) {
      return;
    }
    this.hasShownDailyReview = true;
    this.showDailyReview = true;
  }

  private refresh(): void {
    const summary: HomeSummary = this.viewModel.getHomeSummary();
    const state = this.viewModel.getState();
    const goal: GoalSettings = state.goal;
    const settings: AppSettings = state.settings;
    this.todayTaken = summary.todayTaken;
    this.dailyTarget = goal.dailyTarget;
    this.stockCount = summary.stockCount;
    this.realDailyCost = summary.realDailyCost;
    this.netHealth = summary.netHealth;
    this.healthDebtMinutes = summary.healthDebtMinutes;
    this.dailyHarmScore = summary.dailyHarmScore;
    this.strictAlert = summary.shouldTriggerStrictAlert;
    this.strictRiskAlertEnabled = settings.strictRiskAlertEnabled;
    this.smokeFeedbackEnabled = settings.smokeFeedbackEnabled;
    this.dailyReviewEnabled = settings.dailyReviewEnabled;
    this.dailyReviewTime = settings.dailyReviewTime;
    this.dailyReviewTimeText = settings.dailyReviewTime;
    this.localFirstEnabled = settings.localFirstEnabled;
    this.syncEnabled = settings.syncEnabled;
    const orderedAssets: InventoryAsset[] = state.assets.slice().sort((left: InventoryAsset, right: InventoryAsset): number => {
      if (left.isDefault === right.isDefault) {
        return 0;
      }
      return left.isDefault ? -1 : 1;
    });
    this.assetRows = orderedAssets.map((asset: InventoryAsset): string => {
      const defaultLabel = asset.isDefault ? '默认取烟 · ' : '';
      return `${asset.brand} · ${defaultLabel}${asset.stockCount}支 · 焦油${asset.tarMg}mg · ¥${asset.packPrice}`;
    });
    this.assetCards = orderedAssets.map((asset: InventoryAsset): AssetCardState => {
      return {
        id: asset.id,
        brand: asset.brand,
        isDefault: asset.isDefault,
        riskLabel: this.riskLabelForAsset(asset),
        stockCount: asset.stockCount,
        tarMg: asset.tarMg,
        nicotineMg: asset.nicotineMg,
        stockValue: `库存净值约 ¥${(asset.stockCount * asset.packPrice / 20).toFixed(1)}`
      };
    });
    this.assetIds = orderedAssets.map((asset: InventoryAsset): string => asset.id);
    this.assetLabels = orderedAssets.map((asset: InventoryAsset): string => {
      const defaultLabel = asset.isDefault ? '默认取烟 · ' : '';
      return `${defaultLabel}${asset.brand} · ${asset.stockCount}支 · 焦油${asset.tarMg}mg`;
    });
    this.ledgerRows = this.viewModel.getTodayLedgerEntries().map((entry: LedgerEntry): string => {
      const action = entry.action === 'take' ? '取出' : entry.action === 'return' ? '放回' : '退役';
      const asset = state.assets.find((item: InventoryAsset): boolean => item.id === entry.assetId);
      const brand = asset ? asset.brand : '未知品牌';
      const note = entry.note.length > 0 ? entry.note : '无备注';
      return `${action} ${entry.cigarettes}支 · ${brand} · ${this.formatLedgerTime(entry.timestamp)} · 焦油${entry.tarMg}mg · ¥${entry.cost.toFixed(1)} · 健康折算${entry.healthMinutes}分钟 · ${note}`;
    }).reverse();
  }

  private formatLedgerTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = `${date.getHours()}`.padStart(2, '0');
    const minutes = `${date.getMinutes()}`.padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  private submitDailyReviewTime(): void {
    const normalized = this.normalizeReviewTime(this.dailyReviewTimeText);
    if (normalized.length === 0) {
      this.dailyReviewTimeError = '请输入 00:00-23:59 之间的时间，例如 21:30。';
      return;
    }
    this.dailyReviewTimeError = '';
    this.dailyReviewTime = normalized;
    this.dailyReviewTimeText = normalized;
    this.viewModel.updateSettings(
      this.strictRiskAlertEnabled,
      this.smokeFeedbackEnabled,
      this.dailyReviewEnabled,
      this.localFirstEnabled,
      this.syncEnabled,
      normalized
    );
    this.refresh();
    this.syncDailyReviewReminder();
  }

  private normalizeReviewTime(value: string): string {
    const parts = value.trim().split(':');
    if (parts.length !== 2) {
      return '';
    }
    if (parts[0].trim().length === 0 || parts[1].trim().length === 0) {
      return '';
    }
    const hour = Number(parts[0]);
    const minute = Number(parts[1]);
    if (hour !== hour || minute !== minute || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return '';
    }
    if (Math.floor(hour) !== hour || Math.floor(minute) !== minute) {
      return '';
    }
    return `${`${hour}`.padStart(2, '0')}:${`${minute}`.padStart(2, '0')}`;
  }

  private riskLabelForAsset(asset: InventoryAsset): string {
    if (asset.stockCount <= 5) {
      return '低库存';
    }
    if (asset.tarMg >= 12) {
      return '偏高';
    }
    if (asset.tarMg <= 6) {
      return '偏低';
    }
    return '偏中';
  }
}
