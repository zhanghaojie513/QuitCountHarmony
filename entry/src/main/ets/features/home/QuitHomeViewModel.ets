import { InMemoryQuitRepository, QuitRepository } from '../../data/QuitRepository';
import { QuitCalculator } from '../../domain/QuitCalculator';
import {
  InventoryAsset,
  LedgerEntry,
  QuitState,
  RiskSnapshot,
  TakeSmokeInput,
  cloneAppSettings,
  cloneGoalSettings,
  cloneInventoryAsset,
  cloneLedgerEntry
} from '../../domain/models/QuitModels';
import { ParsedAssetForm } from '../../domain/AssetValidator';

export interface HomeSummary {
  todayTaken: number;
  dailyTarget: number;
  stockCount: number;
  realDailyCost: number;
  netHealth: number;
  healthDebtMinutes: number;
  dailyHarmScore: number;
  shouldTriggerStrictAlert: boolean;
}

export class QuitHomeViewModel {
  private repository: QuitRepository;
  private state: QuitState;

  constructor(repository?: QuitRepository) {
    this.repository = repository ?? new InMemoryQuitRepository();
    this.state = this.repository.getState();
  }

  getState(): QuitState {
    return {
      assets: this.state.assets.map((asset: InventoryAsset): InventoryAsset => cloneInventoryAsset(asset)),
      ledger: this.state.ledger.map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry)),
      goal: cloneGoalSettings(this.state.goal),
      settings: cloneAppSettings(this.state.settings)
    };
  }

  getDefaultAsset(): InventoryAsset {
    return this.state.assets.find((asset: InventoryAsset): boolean => asset.isDefault) ?? this.state.assets[0];
  }

  getTodayTaken(referenceTime: number = Date.now()): number {
    const taken = this.getTodayLedgerEntries(referenceTime)
      .filter((entry: LedgerEntry): boolean => entry.action === 'take')
      .reduce((sum: number, entry: LedgerEntry): number => sum + entry.cigarettes, 0);
    const returned = this.getTodayLedgerEntries(referenceTime)
      .filter((entry: LedgerEntry): boolean => entry.action === 'return')
      .reduce((sum: number, entry: LedgerEntry): number => sum + entry.cigarettes, 0);
    return Math.max(taken - returned, 0);
  }

  getTodayLedgerEntries(referenceTime: number = Date.now()): LedgerEntry[] {
    return this.state.ledger
      .filter((entry: LedgerEntry): boolean => this.isSameLocalDay(entry.timestamp, referenceTime))
      .map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry));
  }

  getStockCount(): number {
    return this.state.assets.reduce((sum: number, asset: InventoryAsset): number => sum + asset.stockCount, 0);
  }

  getRiskSnapshot(): RiskSnapshot {
    return QuitCalculator.riskSnapshot(this.getTodayTaken(), this.getStockCount());
  }

  getHomeSummary(): HomeSummary {
    const todayTaken = this.getTodayTaken();
    const stockCount = this.getStockCount();
    const risk = QuitCalculator.riskSnapshot(todayTaken, stockCount);
    return {
      todayTaken,
      dailyTarget: this.state.goal.dailyTarget,
      stockCount,
      realDailyCost: this.calculateRealDailyCost(),
      netHealth: risk.netHealth,
      healthDebtMinutes: risk.todayHealthDebtMinutes,
      dailyHarmScore: risk.dailyHarmScore,
      shouldTriggerStrictAlert: this.shouldTriggerStrictAlert()
    };
  }

  takeSmoke(input: TakeSmokeInput = {}): LedgerEntry | undefined {
    const assetIndex = this.resolveAssetIndex(input.assetId);
    if (assetIndex < 0) {
      return undefined;
    }

    const asset = this.state.assets[assetIndex];
    if (asset.stockCount <= 0) {
      return undefined;
    }

    const updatedAsset: InventoryAsset = {
      id: asset.id,
      brand: asset.brand,
      tarMg: asset.tarMg,
      nicotineMg: asset.nicotineMg,
      stockCount: asset.stockCount - 1,
      packPrice: asset.packPrice,
      isDefault: asset.isDefault
    };
    const nextAssets = this.state.assets.slice();
    nextAssets[assetIndex] = updatedAsset;

    const timestamp = input.timestamp ?? Date.now();
    const todayTakenAfter = this.getTodayTaken(timestamp) + 1;
    const stockAfter = this.getStockCount() - 1;
    const entry: LedgerEntry = {
      id: `take-${timestamp}-${this.state.ledger.length + 1}`,
      assetId: asset.id,
      action: 'take',
      cigarettes: 1,
      timestamp,
      scene: input.scene ?? '',
      note: input.note ?? '',
      tarMg: asset.tarMg,
      cost: asset.packPrice / 20,
      healthMinutes: QuitCalculator.healthMinutes(1),
      riskSnapshot: QuitCalculator.riskSnapshot(todayTakenAfter, stockAfter)
    };

    this.state = {
      assets: nextAssets,
      ledger: this.state.ledger.concat([entry]),
      goal: cloneGoalSettings(this.state.goal),
      settings: cloneAppSettings(this.state.settings)
    };
    this.persist();
    return entry;
  }

  addAsset(form: ParsedAssetForm): InventoryAsset {
    const asset: InventoryAsset = {
      id: `asset-${Date.now()}-${this.state.assets.length + 1}`,
      brand: form.brand,
      tarMg: form.tarMg,
      nicotineMg: form.nicotineMg,
      stockCount: form.stockCount,
      packPrice: form.packPrice,
      isDefault: this.state.assets.length === 0
    };

    this.state = {
      assets: this.state.assets.concat([asset]),
      ledger: this.state.ledger.map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry)),
      goal: cloneGoalSettings(this.state.goal),
      settings: cloneAppSettings(this.state.settings)
    };
    this.persist();
    return asset;
  }

  updateGoal(dailyTarget: number, interventionLine: number): void {
    this.state = {
      assets: this.state.assets.map((asset: InventoryAsset): InventoryAsset => cloneInventoryAsset(asset)),
      ledger: this.state.ledger.map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry)),
      goal: {
        dailyTarget,
        interventionLine
      },
      settings: cloneAppSettings(this.state.settings)
    };
    this.persist();
  }

  updateSettings(
    strictRiskAlertEnabled: boolean,
    smokeFeedbackEnabled: boolean,
    dailyReviewEnabled: boolean,
    localFirstEnabled: boolean,
    syncEnabled: boolean,
    dailyReviewTime: string = this.state.settings.dailyReviewTime
  ): void {
    this.state = {
      assets: this.state.assets.map((asset: InventoryAsset): InventoryAsset => cloneInventoryAsset(asset)),
      ledger: this.state.ledger.map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry)),
      goal: cloneGoalSettings(this.state.goal),
      settings: {
        strictRiskAlertEnabled,
        smokeFeedbackEnabled,
        dailyReviewEnabled,
        dailyReviewTime,
        localFirstEnabled,
        syncEnabled
      }
    };
    this.persist();
  }

  returnLastSmoke(timestamp: number = Date.now()): LedgerEntry | undefined {
    if (this.getTodayTaken(timestamp) <= 0) {
      return undefined;
    }

    const returnTarget = this.findLatestUnreturnedTakeForDay(timestamp);
    if (!returnTarget) {
      return undefined;
    }

    const assetIndex = this.resolveAssetIndex(returnTarget.assetId);
    if (assetIndex < 0) {
      return undefined;
    }

    const asset = this.state.assets[assetIndex];
    const nextAssets = this.state.assets.slice();
    nextAssets[assetIndex] = {
      id: asset.id,
      brand: asset.brand,
      tarMg: asset.tarMg,
      nicotineMg: asset.nicotineMg,
      stockCount: asset.stockCount + 1,
      packPrice: asset.packPrice,
      isDefault: asset.isDefault
    };

    const todayTakenAfter = Math.max(this.getTodayTaken(timestamp) - 1, 0);
    const stockAfter = this.getStockCount() + 1;
    const entry: LedgerEntry = {
      id: `return-${timestamp}-${this.state.ledger.length + 1}`,
      assetId: asset.id,
      action: 'return',
      cigarettes: 1,
      timestamp,
      scene: '',
      note: '撤销最近一次真实成本',
      tarMg: returnTarget.tarMg,
      cost: -(asset.packPrice / 20),
      healthMinutes: -QuitCalculator.healthMinutes(1),
      riskSnapshot: QuitCalculator.riskSnapshot(todayTakenAfter, stockAfter)
    };

    this.state = {
      assets: nextAssets,
      ledger: this.state.ledger.concat([entry]),
      goal: cloneGoalSettings(this.state.goal),
      settings: cloneAppSettings(this.state.settings)
    };
    this.persist();
    return entry;
  }

  clearStockAndRetire(timestamp: number = Date.now()): LedgerEntry | undefined {
    const totalStock = this.getStockCount();
    if (totalStock <= 0) {
      return undefined;
    }

    const defaultAsset = this.getDefaultAsset();
    const nextAssets = this.state.assets.map((asset: InventoryAsset): InventoryAsset => {
      return {
        id: asset.id,
        brand: asset.brand,
        tarMg: asset.tarMg,
        nicotineMg: asset.nicotineMg,
        stockCount: 0,
        packPrice: asset.packPrice,
        isDefault: asset.isDefault
      };
    });
    const entry: LedgerEntry = {
      id: `retire-${timestamp}-${this.state.ledger.length + 1}`,
      assetId: defaultAsset.id,
      action: 'retire',
      cigarettes: totalStock,
      timestamp,
      scene: '',
      note: '清空库存并记录退役',
      tarMg: defaultAsset.tarMg,
      cost: 0,
      healthMinutes: QuitCalculator.healthMinutes(totalStock),
      riskSnapshot: QuitCalculator.riskSnapshot(this.getTodayTaken(), 0)
    };

    this.state = {
      assets: nextAssets,
      ledger: this.state.ledger.concat([entry]),
      goal: cloneGoalSettings(this.state.goal),
      settings: cloneAppSettings(this.state.settings)
    };
    this.persist();
    return entry;
  }

  resetLocalData(): QuitState {
    this.state = this.repository.reset();
    return this.getState();
  }

  exportLedgerCsv(): string {
    const header = 'time,action,brand,tarMg,cost,healthMinutes,note';
    const rows = this.state.ledger.map((entry: LedgerEntry): string => {
      const asset = this.state.assets.find((item: InventoryAsset): boolean => item.id === entry.assetId);
      const brand = asset ? asset.brand : '';
      return [
        `${entry.timestamp}`,
        entry.action,
        brand,
        `${entry.tarMg}`,
        entry.cost.toFixed(2),
        `${entry.healthMinutes}`,
        entry.note
      ].map((value: string): string => this.escapeCsvValue(value)).join(',');
    });
    return [header].concat(rows).join('\n');
  }

  private escapeCsvValue(value: string): string {
    const escaped = value.replace(/"/g, '""');
    if (escaped.indexOf(',') >= 0 || escaped.indexOf('\n') >= 0 || escaped.indexOf('"') >= 0) {
      return `"${escaped}"`;
    }
    return escaped;
  }

  private calculateRealDailyCost(): number {
    return this.getTodayLedgerEntries()
      .filter((entry: LedgerEntry): boolean => entry.action === 'take' || entry.action === 'return')
      .reduce((sum: number, entry: LedgerEntry): number => sum + entry.cost, 0);
  }

  private shouldTriggerStrictAlert(): boolean {
    return this.state.settings.strictRiskAlertEnabled && this.getTodayTaken() >= this.state.goal.interventionLine;
  }

  private findLatestUnreturnedTakeForDay(referenceTime: number): LedgerEntry | undefined {
    const unresolvedTakes: LedgerEntry[] = [];
    this.state.ledger
      .filter((entry: LedgerEntry): boolean => this.isSameLocalDay(entry.timestamp, referenceTime))
      .sort((left: LedgerEntry, right: LedgerEntry): number => left.timestamp - right.timestamp)
      .forEach((entry: LedgerEntry) => {
        if (entry.action === 'take') {
          unresolvedTakes.push(entry);
          return;
        }
        if (entry.action === 'return' && unresolvedTakes.length > 0) {
          unresolvedTakes.pop();
        }
      });
    const target = unresolvedTakes.pop();
    return target ? cloneLedgerEntry(target) : undefined;
  }

  private isSameLocalDay(leftTimestamp: number, rightTimestamp: number): boolean {
    const left = new Date(leftTimestamp);
    const right = new Date(rightTimestamp);
    return left.getFullYear() === right.getFullYear()
      && left.getMonth() === right.getMonth()
      && left.getDate() === right.getDate();
  }

  private resolveAssetIndex(assetId?: string): number {
    if (assetId) {
      return this.state.assets.findIndex((asset: InventoryAsset): boolean => asset.id === assetId);
    }
    const defaultAsset = this.getDefaultAsset();
    return this.state.assets.findIndex((asset: InventoryAsset): boolean => asset.id === defaultAsset.id);
  }

  private persist(): void {
    this.repository.saveState(this.state);
  }
}
