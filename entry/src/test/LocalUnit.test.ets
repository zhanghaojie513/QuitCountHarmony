import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { QuitCalculator } from '../main/ets/domain/QuitCalculator';
import { InMemoryQuitRepository } from '../main/ets/data/QuitRepository';
import { QuitHomeViewModel } from '../main/ets/features/home/QuitHomeViewModel';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('calculatorUsesProductSpecFormulas', 0, () => {
      expect(QuitCalculator.healthMinutes(3)).assertEqual(60);
      expect(QuitCalculator.todayPackYearIncrement(20)).assertEqual(1 / 365);
      expect(QuitCalculator.stockPotentialPackYears(20)).assertEqual(1 / 365);
      expect(QuitCalculator.lungScore(0)).assertEqual(0);
      expect(QuitCalculator.lungScore(1)).assertEqual(50);
      expect(QuitCalculator.netHealthFromLungScore(50)).assertEqual(50);
      expect(QuitCalculator.dailyHarmScore(1)).assertEqual(50);
      expect(QuitCalculator.dailyHarmScore(4)).assertEqual(68);
      expect(QuitCalculator.dailyHarmScore(5)).assertEqual(68);
      expect(QuitCalculator.dailyHarmScore(9)).assertEqual(80);
      expect(QuitCalculator.dailyHarmScore(20)).assertEqual(100);
    });

    it('viewModelTakeSmokeUpdatesStockLedgerAndSummary', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      const now = Date.now();
      const entry = viewModel.takeSmoke({ scene: '测试', note: '备注', timestamp: now });
      const summary = viewModel.getHomeSummary();

      expect(entry !== undefined).assertTrue();
      expect(summary.todayTaken).assertEqual(1);
      expect(summary.stockCount).assertEqual(19);
      expect(summary.realDailyCost).assertEqual(3);
      expect(summary.healthDebtMinutes).assertEqual(20);
      expect(summary.netHealth).assertEqual(50);
      expect(viewModel.getState().ledger.length).assertEqual(1);
    });

    it('viewModelReturnSmokeAvoidsNegativeCounts', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      expect(viewModel.returnLastSmoke() === undefined).assertTrue();

      const now = Date.now();
      viewModel.takeSmoke({ timestamp: now });
      const returned = viewModel.returnLastSmoke(now + 1000);
      const summary = viewModel.getHomeSummary();

      expect(returned !== undefined).assertTrue();
      expect(summary.todayTaken).assertEqual(0);
      expect(summary.stockCount).assertEqual(20);
      expect(summary.realDailyCost).assertEqual(0);
      expect(viewModel.getState().ledger.length).assertEqual(2);
    });

    it('repositoryResetRestoresInitialState', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      const now = Date.now();
      viewModel.takeSmoke({ timestamp: now });
      viewModel.clearStockAndRetire(now + 1000);

      const resetState = viewModel.resetLocalData();
      const summary = viewModel.getHomeSummary();

      expect(resetState.assets[0].stockCount).assertEqual(20);
      expect(resetState.ledger.length).assertEqual(0);
      expect(summary.stockCount).assertEqual(20);
      expect(summary.todayTaken).assertEqual(0);
    });

    it('viewModelClearStockAndRetireRecordsLedgerEvent', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      const entry = viewModel.clearStockAndRetire(3000);
      const state = viewModel.getState();
      const summary = viewModel.getHomeSummary();

      expect(entry !== undefined).assertTrue();
      expect(entry?.action).assertEqual('retire');
      expect(entry?.cigarettes).assertEqual(20);
      expect(summary.stockCount).assertEqual(0);
      expect(state.ledger.length).assertEqual(1);
      expect(state.ledger[0].note).assertEqual('清空库存并记录退役');
    });

    it('viewModelExportLedgerCsvEscapesTextFields', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      viewModel.takeSmoke({ timestamp: Date.now(), note: '饭后,想抽"一口"' });
      const csv = viewModel.exportLedgerCsv();

      expect(csv.includes('"饭后,想抽""一口"""')).assertTrue();
    });

    it('viewModelTodayMetricsIgnorePreviousDays', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      const now = Date.now();
      const oldDay = now - 2 * 24 * 60 * 60 * 1000;

      viewModel.takeSmoke({ timestamp: oldDay });
      viewModel.takeSmoke({ timestamp: now });
      const summary = viewModel.getHomeSummary();

      expect(summary.todayTaken).assertEqual(1);
      expect(summary.realDailyCost).assertEqual(3);
      expect(viewModel.getTodayLedgerEntries().length).assertEqual(1);
    });

    it('viewModelUpdateSettingsPersistsDailyReviewTime', 0, () => {
      const viewModel = new QuitHomeViewModel(new InMemoryQuitRepository());
      viewModel.updateSettings(true, true, true, true, false, '22:15');

      expect(viewModel.getState().settings.dailyReviewTime).assertEqual('22:15');
    });
  });
}
