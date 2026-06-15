import { RiskSnapshot } from './models/QuitModels';

export class QuitCalculator {
  static clamp(value: number, min: number, max: number): number {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  static todayPackYearIncrement(todayCigarettes: number): number {
    return todayCigarettes / 20 / 365;
  }

  static stockPotentialPackYears(stockCount: number): number {
    return stockCount / 20 / 365;
  }

  static healthMinutes(cigarettes: number): number {
    return cigarettes * 20;
  }

  static lungScore(todayTaken: number): number {
    if (todayTaken <= 0) {
      return 0;
    }
    return QuitCalculator.clamp(50 + (todayTaken - 1) * (50 / 19), 0, 100);
  }

  static netHealthFromLungScore(lungScore: number): number {
    return QuitCalculator.clamp(100 - lungScore, 0, 100);
  }

  static dailyHarmScore(todayTaken: number): number {
    if (todayTaken <= 0) {
      return 0;
    }
    if (todayTaken === 1) {
      return 50;
    }
    if (todayTaken <= 4) {
      return 50 + (todayTaken - 1) * 6;
    }
    if (todayTaken <= 9) {
      return 68 + (todayTaken - 5) * 3;
    }
    if (todayTaken <= 19) {
      return 82 + (todayTaken - 10) * 1.9;
    }
    return 100;
  }

  static riskSnapshot(todayTaken: number, stockCount: number): RiskSnapshot {
    const lungScore = QuitCalculator.lungScore(todayTaken);
    return {
      todayTaken,
      stockCount,
      todayPackYearIncrement: QuitCalculator.todayPackYearIncrement(todayTaken),
      stockPotentialPackYears: QuitCalculator.stockPotentialPackYears(stockCount),
      lungScore,
      netHealth: QuitCalculator.netHealthFromLungScore(lungScore),
      dailyHarmScore: QuitCalculator.dailyHarmScore(todayTaken),
      todayHealthDebtMinutes: QuitCalculator.healthMinutes(todayTaken),
      stockHealthDebtMinutes: QuitCalculator.healthMinutes(stockCount)
    };
  }
}
