import { AppColors, AppSpacing, AppText } from '../../core/theme/AppTheme';
import { HomeSummary, QuitHomeViewModel } from './QuitHomeViewModel';

@Component
export struct HomePreview {
  private viewModel: QuitHomeViewModel = new QuitHomeViewModel();
  private summary: HomeSummary = this.viewModel.getHomeSummary();

  build() {
    Column() {
      Row() {
        Column() {
          Text('戒烟有数')
            .fontSize(AppText.titleSize)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.ink)
          Text('真实成本 A1 · HarmonyOS Phase 1')
            .fontSize(AppText.labelSize)
            .fontColor(AppColors.muted)
            .margin({ top: AppSpacing.xs })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('i')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.primary)
          .textAlign(TextAlign.Center)
          .width(AppSpacing.iconButton)
          .height(AppSpacing.iconButton)
          .borderRadius(AppSpacing.radius)
          .backgroundColor(AppColors.surfaceMint)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text('肺部负担指数')
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 26 })
        .width('100%')

      Row() {
        Text(this.summary.dailyHarmScore.toFixed(0))
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

      Row() {
        Text('!')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.danger)
          .width(24)
          .textAlign(TextAlign.Center)
        Text('当日危害警示分用于行为干预，不代表医学诊断。')
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
      .margin({ top: AppSpacing.sm })

      Image($r('app.media.human_lungs_nih'))
        .objectFit(ImageFit.Contain)
        .height(230)
        .width('100%')
        .margin({ top: 26 })

      Blank()

      Row() {
        MetricTile({ label: '真实日耗', value: `¥${this.summary.realDailyCost.toFixed(1)}` })
        Blank().width(AppSpacing.sm)
        MetricTile({ label: '健康负债', value: `${(this.summary.healthDebtMinutes / 60).toFixed(1)}小时` })
      }
      .width('100%')

      Button('取出一支')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(52)
        .width('100%')
        .borderRadius(AppSpacing.radius)
        .backgroundColor(AppColors.primary)
        .margin({ top: AppSpacing.md })

      Text(`今日 ${this.summary.todayTaken}/${this.summary.dailyTarget} 支 · 库存 ${this.summary.stockCount} 支 · 健康净值 ${this.summary.netHealth.toFixed(0)}`)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
        .margin({ top: AppSpacing.sm })
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .padding({ left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.xl, bottom: AppSpacing.lg })
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.pageBase)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct MetricTile {
  label: string = '';
  value: string = '';

  build() {
    Column() {
      Text(this.label)
        .fontSize(AppText.labelSize)
        .fontColor(AppColors.muted)
      Text(this.value)
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
}
