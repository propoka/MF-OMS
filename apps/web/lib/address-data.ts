export interface LocationData {
  code: string;
  name: string;
}

// Giả lập dữ liệu Tỉnh/Thành & Quận/Huyện do giới hạn kích thước
// Trong thực tế, có thể import từ file JSON địa giới hành chính VN
export const MOCK_PROVINCES: LocationData[] = [
  { code: '01', name: 'Thành phố Hà Nội' },
  { code: '79', name: 'Thành phố Hồ Chí Minh' },
  { code: '48', name: 'Thành phố Đà Nẵng' },
  { code: '91', name: 'Tỉnh Kiên Giang' },
  { code: '68', name: 'Tỉnh Lâm Đồng' },
];

export const MOCK_WARDS: Record<string, LocationData[]> = {
  '01': [
    { code: '001', name: 'Quận Ba Đình' },
    { code: '002', name: 'Quận Hoàn Kiếm' },
    { code: '003', name: 'Quận Tây Hồ' },
  ],
  '79': [
    { code: '760', name: 'Quận 1' },
    { code: '761', name: 'Quận 12' },
    { code: '764', name: 'Quận Gò Vấp' },
  ],
  '48': [
    { code: '490', name: 'Quận Liên Chiểu' },
    { code: '491', name: 'Quận Thanh Khê' },
    { code: '492', name: 'Quận Hải Châu' },
  ],
  '68': [
    { code: '672', name: 'Thành phố Đà Lạt' },
    { code: '673', name: 'Thành phố Bảo Lộc' },
  ],
};
