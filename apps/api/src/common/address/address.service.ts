import { Injectable, Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class AddressService {
  private readonly logger = new Logger(AddressService.name);
  private provinces: any[] = [];

  constructor() {
    this.loadData();
  }

  private loadData() {
    try {
      const rootPath = process.cwd();
      // Resolve path flexibly for dev (apps/api/src...) and prod (dist/...)
      // The safest way is to go relative to this file, but since nest build might not copy json:
      // In monorepos, running `nest start` executes from `apps/api` usually.
      const jsonPath = rootPath.endsWith('api')
        ? path.join(rootPath, 'src/common/address/provinces.json')
        : path.join(rootPath, 'apps/api/src/common/address/provinces.json');

      if (fs.existsSync(jsonPath)) {
        const rawData = fs.readFileSync(jsonPath, 'utf8');
        this.provinces = JSON.parse(rawData);
        this.logger.log(
          `Loaded ${this.provinces.length} provinces successfully.`,
        );
      } else {
        this.logger.warn(`provinces.json not found at ${jsonPath}`);
      }
    } catch (error) {
      this.logger.error('Error loading provinces JSON:', error);
    }
  }

  getProvinces() {
    return this.provinces.map((p) => ({
      code: p.code.toString(),
      name: p.name,
    }));
  }

  getDistrictsByProvince(provinceCode: string) {
    const province = this.provinces.find(
      (p) => p.code.toString() === provinceCode,
    );
    if (!province || !province.districts) return [];

    return province.districts.map((d) => ({
      code: d.code.toString(),
      name: d.name,
    }));
  }
}
