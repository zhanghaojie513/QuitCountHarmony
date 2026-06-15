export type LedgerAction = 'take' | 'return' | 'retire';

export interface InventoryAsset {
  id: string;
  brand: string;
  tarMg: number;
  nicotineMg: number;
  stockCount: number;
  packPrice: number;
  isDefault: boolean;
}

export interface LedgerEntry {
  id: string;
  assetId: string;
  action: LedgerAction;
  cigarettes: number;
  timestamp: number;
  scene: string;
  note: string;
  tarMg: number;
  cost: number;
  healthMinutes: number;
  riskSnapshot: RiskSnapshot;
}

export interface GoalSettings {
  dailyTarget: number;
  interventionLine: number;
}

export interface AppSettings {
  strictRiskAlertEnabled: boolean;
  smokeFeedbackEnabled: boolean;
  dailyReviewEnabled: boolean;
  dailyReviewTime: string;
  localFirstEnabled: boolean;
  syncEnabled: boolean;
}

export interface RiskSnapshot {
  todayTaken: number;
  stockCount: number;
  todayPackYearIncrement: number;
  stockPotentialPackYears: number;
  lungScore: number;
  netHealth: number;
  dailyHarmScore: number;
  todayHealthDebtMinutes: number;
  stockHealthDebtMinutes: number;
}

export interface QuitState {
  assets: InventoryAsset[];
  ledger: LedgerEntry[];
  goal: GoalSettings;
  settings: AppSettings;
}

export interface TakeSmokeInput {
  assetId?: string;
  scene?: string;
  note?: string;
  timestamp?: number;
}

export const DEFAULT_GOAL: GoalSettings = {
  dailyTarget: 5,
  interventionLine: 4
};

export const DEFAULT_SETTINGS: AppSettings = {
  strictRiskAlertEnabled: true,
  smokeFeedbackEnabled: true,
  dailyReviewEnabled: true,
  dailyReviewTime: '21:30',
  localFirstEnabled: true,
  syncEnabled: false
};

export const DEFAULT_ASSET: InventoryAsset = {
  id: 'default-asset',
  brand: '默认库存',
  tarMg: 10,
  nicotineMg: 1.0,
  stockCount: 20,
  packPrice: 60,
  isDefault: true
};

export function createInitialQuitState(): QuitState {
  return {
    assets: [cloneInventoryAsset(DEFAULT_ASSET)],
    ledger: [],
    goal: cloneGoalSettings(DEFAULT_GOAL),
    settings: cloneAppSettings(DEFAULT_SETTINGS)
  };
}

export function cloneInventoryAsset(asset: InventoryAsset): InventoryAsset {
  return {
    id: asset.id,
    brand: asset.brand,
    tarMg: asset.tarMg,
    nicotineMg: asset.nicotineMg,
    stockCount: asset.stockCount,
    packPrice: asset.packPrice,
    isDefault: asset.isDefault
  };
}

export function cloneGoalSettings(goal: GoalSettings): GoalSettings {
  return {
    dailyTarget: goal.dailyTarget,
    interventionLine: goal.interventionLine
  };
}

export function cloneAppSettings(settings: AppSettings): AppSettings {
  return {
    strictRiskAlertEnabled: settings.strictRiskAlertEnabled,
    smokeFeedbackEnabled: settings.smokeFeedbackEnabled,
    dailyReviewEnabled: settings.dailyReviewEnabled,
    dailyReviewTime: settings.dailyReviewTime,
    localFirstEnabled: settings.localFirstEnabled,
    syncEnabled: settings.syncEnabled
  };
}

export function cloneRiskSnapshot(risk: RiskSnapshot): RiskSnapshot {
  return {
    todayTaken: risk.todayTaken,
    stockCount: risk.stockCount,
    todayPackYearIncrement: risk.todayPackYearIncrement,
    stockPotentialPackYears: risk.stockPotentialPackYears,
    lungScore: risk.lungScore,
    netHealth: risk.netHealth,
    dailyHarmScore: risk.dailyHarmScore,
    todayHealthDebtMinutes: risk.todayHealthDebtMinutes,
    stockHealthDebtMinutes: risk.stockHealthDebtMinutes
  };
}

export function cloneLedgerEntry(entry: LedgerEntry): LedgerEntry {
  return {
    id: entry.id,
    assetId: entry.assetId,
    action: entry.action,
    cigarettes: entry.cigarettes,
    timestamp: entry.timestamp,
    scene: entry.scene,
    note: entry.note,
    tarMg: entry.tarMg,
    cost: entry.cost,
    healthMinutes: entry.healthMinutes,
    riskSnapshot: cloneRiskSnapshot(entry.riskSnapshot)
  };
}
