import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

export interface CsvExportResult {
  success: boolean;
  message: string;
  path: string;
}

export class CsvExportService {
  saveLedgerCsv(context: common.Context, csv: string): CsvExportResult {
    const fileName = `quit_count_ledger_${Date.now()}.csv`;
    const path = `${context.filesDir}/${fileName}`;
    let file: fs.File | undefined = undefined;

    try {
      file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, csv);
      return {
        success: true,
        message: `CSV 已保存到应用文件目录：${fileName}`,
        path
      };
    } catch (error) {
      return {
        success: false,
        message: 'CSV 导出失败，请稍后重试。',
        path: ''
      };
    } finally {
      if (file) {
        try {
          fs.closeSync(file);
        } catch (error) {
        }
      }
    }
  }
}
