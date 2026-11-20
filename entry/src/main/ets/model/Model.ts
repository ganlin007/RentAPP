// 统一响应
export interface Result<T> {
  code: number,
  message: string,
  data: T
}

export interface Banner {
  imageURL: string
}

// nav数据结构
export interface Nav {
  id: number,
  title: string,
  imageURL: string
}

// tile数据结构
export interface Tile {
  id: number,
  title: string,
  imageURL: string,
  sub_title: string
}

// plan数据结构
export interface Plan {
  id: number,
  imageURL: string
}

// 首页数据
export interface HomeItem {
  bannerList: Array<Banner>,
  navList: Array<Nav>,
  tileList: Array<Tile>,
  planList: Array<Plan>,
  adPicture: string
}

// 标签数据结构
export interface Tag {
  name: string
}

// 附近房源
export interface HouseItem {
  id: string,
  housePicture: string,
  tags: Array<Tag>,
  houseTitle: string,
  address: string,
  rentPriceUnit: string,
  rentPriceListing: string,
  rentArea: string
}

// 登录数据结构
// token数据结构
export interface Token {
  token: string
}

// 个人信息数据模型
export interface UserInfo {
  id: string,
  nickname: string,
  avatar: string
}

// 房屋详情
export interface houseDetail {
  houseTitle: string,
  address: string,
  rentPriceUnit: string,
  housePicture: Array<housePictureItem>,
  tags: Array<Tag>,
  rentPriceUnitListing: string,
  distanceInfo: string | null,
  rentTerm: rentTermItem,
  metaInfo: Array<metaInfoItem>,
  discounts: Array<discountItem>,
  householdItem: Array<household>,
  support: Array<supportItem>,
  rentInfo: Array<rentInfoItem>,
  id: string,
  rentArea: string
}

// 房屋图片
export interface housePictureItem {
  spaceName: string,
  picList: Array<string>
}

// 租期
export interface rentTermItem {
  checkInTime: string,
  term: string,
  kitchen: string,
  lift: string,
  seeTime: string,
  year: string,
  renovation: string,
  grounding: string,
  heating: string,
  green: string,
  protection: string,
  house: string
}

// 面积/朝向/户型/楼层
export interface metaInfoItem {
  name: string,
  desc: string
}

// 打折
export interface discountItem {
  tagTxtBgAroundColor: string,
  image: string,
  txt: string,
  tagTxt: string,
  tagTxtColor: string
}

// householdItem数据模型定义
export interface itemListItem {
  icon: string,
  value: string
}

export interface household {
  name: string,
  itemList: Array<itemListItem>
}

export interface supportItem {
  image: string,
  title: string,
  subTitle: string
}

export interface rentInfoItem {
  image: string,
  title: string,
  userTag: string
}

// 预约信息
export interface orderInfo {
  id?: number,
  userId?: number,
  houseId: string,
  date: string,
  name: string,
  comment: string,
  phone?: string
}
