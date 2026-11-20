export interface Banner {
  imageURL: string
}

// nav数据结构
export interface Nav {
  id: number,
  title: string,
  imageURL: string
}

// title数据结构
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

// data数据结构
export interface HomeData {
  bannerList: Array<Banner>,
  navList: Array<Nav>,
  tileList: Array<Tile>,
  planList: Array<Plan>,
  adPicture: string
}

export interface Home_Result {
  code: number,
  message: string,
  data: HomeData
}
