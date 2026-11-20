// 标签数据结构
export interface Tag {
  name: string
}

// data数组元素对象
export interface DataItem {
  id: string,
  housePicture: string,
  tags: Array<Tag>,
  houseTitle: string,
  address: string,
  rentPriceUnit: string,
  rentPriceListing: string,
  rentArea: string
}

export interface HouseResult {
  code: number,
  message: string,
  data: Array<DataItem>
}
