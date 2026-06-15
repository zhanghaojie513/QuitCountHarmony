export interface AddAssetForm {
  brand: string;
  tarMgText: string;
  nicotineMgText: string;
  stockCountText: string;
  packPriceText: string;
}

export interface AddAssetErrors {
  brand: string;
  tarMg: string;
  nicotineMg: string;
  stockCount: string;
  packPrice: string;
  summary: string;
}

export interface ParsedAssetForm {
  brand: string;
  tarMg: number;
  nicotineMg: number;
  stockCount: number;
  packPrice: number;
}

export class AssetValidator {
  static emptyErrors(): AddAssetErrors {
    return {
      brand: '',
      tarMg: '',
      nicotineMg: '',
      stockCount: '',
      packPrice: '',
      summary: ''
    };
  }

  static validate(form: AddAssetForm): AddAssetErrors {
    const errors = AssetValidator.emptyErrors();
    const brand = form.brand.trim();
    const tarMg = Number(form.tarMgText);
    const nicotineMg = Number(form.nicotineMgText);
    const stockCount = Number(form.stockCountText);
    const packPrice = Number(form.packPriceText);

    if (brand.length <= 0) {
      errors.brand = '品牌必填';
    } else if (brand.length > 16) {
      errors.brand = '品牌最多 16 字';
    }

    if (!Number.isFinite(tarMg) || tarMg < 1 || tarMg > 20) {
      errors.tarMg = '焦油量需为 1-20mg';
    }

    if (!Number.isFinite(nicotineMg) || nicotineMg < 0.1 || nicotineMg > 3) {
      errors.nicotineMg = '尼古丁需为 0.1-3mg';
    }

    if (!Number.isInteger(stockCount) || stockCount < 1 || stockCount > 200) {
      errors.stockCount = '库存需为 1-200 支整数';
    }

    if (!Number.isFinite(packPrice) || packPrice < 1 || packPrice > 200) {
      errors.packPrice = '整包价格需为 1-200 元';
    }

    if (AssetValidator.hasErrors(errors)) {
      errors.summary = '请修正红色字段后再保存资产';
    }

    return errors;
  }

  static hasErrors(errors: AddAssetErrors): boolean {
    return errors.brand.length > 0 || errors.tarMg.length > 0 || errors.nicotineMg.length > 0 ||
      errors.stockCount.length > 0 || errors.packPrice.length > 0;
  }

  static parse(form: AddAssetForm): ParsedAssetForm {
    return {
      brand: form.brand.trim(),
      tarMg: Number(form.tarMgText),
      nicotineMg: Number(form.nicotineMgText),
      stockCount: Number(form.stockCountText),
      packPrice: Number(form.packPriceText)
    };
  }
}
