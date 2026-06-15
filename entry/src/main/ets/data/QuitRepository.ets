import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import {
  AppSettings,
  GoalSettings,
  InventoryAsset,
  LedgerEntry,
  QuitState,
  cloneAppSettings,
  cloneGoalSettings,
  cloneInventoryAsset,
  cloneLedgerEntry,
  createInitialQuitState
} from '../domain/models/QuitModels';

const PREFERENCES_NAME = 'quit_count_state';
const STATE_KEY = 'state_json';

export interface QuitRepository {
  getState(): QuitState;
  saveState(state: QuitState): void;
  reset(): QuitState;
}

export class InMemoryQuitRepository implements QuitRepository {
  private state: QuitState = createInitialQuitState();

  getState(): QuitState {
    return cloneState(this.state);
  }

  saveState(state: QuitState): void {
    this.state = cloneState(state);
  }

  reset(): QuitState {
    this.state = createInitialQuitState();
    return this.getState();
  }
}

export class PreferencesQuitRepository implements QuitRepository {
  private store?: preferences.Preferences;
  private fallbackState: QuitState = createInitialQuitState();

  constructor(context: common.Context) {
    try {
      this.store = preferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
    } catch (error) {
      this.store = undefined;
    }
  }

  isPersistentReady(): boolean {
    return this.store !== undefined;
  }

  getState(): QuitState {
    if (!this.store) {
      return cloneState(this.fallbackState);
    }

    try {
      const raw = this.store.getSync(STATE_KEY, '') as string;
      if (raw.length === 0) {
        const initialState = createInitialQuitState();
        this.saveState(initialState);
        return initialState;
      }
      const state = cloneState(JSON.parse(raw) as QuitState);
      this.fallbackState = cloneState(state);
      return state;
    } catch (error) {
      return cloneState(this.fallbackState);
    }
  }

  saveState(state: QuitState): void {
    const snapshot = cloneState(state);
    this.fallbackState = cloneState(snapshot);
    if (!this.store) {
      return;
    }
    try {
      this.store.putSync(STATE_KEY, JSON.stringify(snapshot));
      this.store.flushSync();
    } catch (error) {
      this.store = undefined;
    }
  }

  reset(): QuitState {
    const state = createInitialQuitState();
    this.saveState(state);
    return cloneState(state);
  }
}

export function cloneState(state: QuitState): QuitState {
  return {
    assets: state.assets.map((asset: InventoryAsset): InventoryAsset => cloneInventoryAsset(asset)),
    ledger: state.ledger.map((entry: LedgerEntry): LedgerEntry => cloneLedgerEntry(entry)),
    goal: cloneGoalSettings(state.goal) as GoalSettings,
    settings: cloneAppSettings(state.settings) as AppSettings
  };
}
