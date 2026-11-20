import { router } from '@kit.ArkUI'
import { Banner, HouseItem, Nav, Plan, Tile } from '../model/Model'
import { getHomeData, getHouseData } from '../utils/Apis'
import { PADDING, PADDING_L, BORDER_RADIUS_S, BORDER_RADIUS_L } from './constants/size'

// 首页组件
@Component
export struct Home {
  // 2. 定义轮播图变量
  @State bannerList: Array<Banner> = []

  // 3. 定义nav变量
  @State navList: Array<Nav> = []

  // 4. 定义tile变量
  @State tileList: Array<Tile> = []

  // 5. 定义plan变量
  @State planList: Array<Plan> = []

  // 6. 定义广告图片变量
  @State adPicture: string = ''

  // 定义附近房源变量
  @State nearbyHouse: Array<HouseItem> = []

  // 2. 页面一加载获取数据
  async aboutToAppear(): Promise<void> {
    const result = await getHomeData();
    // 获取轮播图数据
    this.bannerList = result.data.bannerList

    // 获取nav数据
    this.navList = result.data.navList

    // 获取tile数据
    this.tileList = result.data.tileList

    // 获取plan数据
    this.planList = result.data.planList

    // 获取广告图片数据
    this.adPicture = result.data.adPicture

    // 获取附近房源数据
    const house_result = await getHouseData()
    this.nearbyHouse = house_result.data
  }

  build() {
    Scroll() {
      Column({ space: 15 }) {
        // 层叠布局
        Stack() {
          // 轮播图
          Swiper() {
            ForEach(this.bannerList, (item: Banner) => {
              Image(item.imageURL)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            })
          }
          .width('100%')
          .height(200)
          .autoPlay(true)
          .loop(true)
          .indicator(
            new DotIndicator()
              .itemWidth(5)
              .itemHeight(5)
              .selectedItemWidth(5)
              .selectedItemHeight(5)
              .color(Color.White)
              .selectedColor($r('app.color.primary'))
          )

          Row() {
            Text('北京')
              .fontSize(16)
              .fontColor($r('app.color.black'))
            Search({ placeholder: '请输入小区名称' })
              .layoutWeight(1)
              .height(36)
              .margin({ left: 8 })
              .backgroundColor(Color.White)
          }
          .width('100%')
          .padding({
            left: PADDING,
            right: PADDING,
            top: 48
          })
        }
        .width('100%')
        .alignContent(Alignment.Top)

        // nav布局
        Grid() {
          ForEach(this.navList, (navItem: Nav, index: number) => {
            GridItem() {
              Column({ space: 5 }) {
                Image(navItem.imageURL)
                  .width(56)
                  .height(56)
                  .borderRadius(5)
                Text(navItem.title)
                  .fontSize(14)
              }
            }
          })
        }
        .width('100%')
        .height(170)
        .margin({
          top: PADDING_L
        })
        .padding({
          left: PADDING,
          right: PADDING
        })
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .rowsGap(10)

        // tile布局
        Row() {
          ForEach(this.tileList, (tileItem: Tile, index: number) => {
            Column({ space: 5 }) {
              Image(tileItem.imageURL)
                .width('48%')
                .height(57)
                .borderRadius(5)
              Row({ space: 5 }) {
                Text(tileItem.title)
                  .fontSize(14)
                  .fontColor($r('app.color.black'))
                Text(tileItem.sub_title)
                  .layoutWeight(1)
                  .fontSize(10)
                  .fontColor($r('app.color.gray_second'))
                  .maxLines(1)
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })
              }
              .width('48%')
              .alignItems(VerticalAlign.Bottom)
            }
          })
        }
        .width('100%')
        .padding({
          left: PADDING,
          right: PADDING
        })
        .margin({
          top: PADDING_L
        })
        .justifyContent(FlexAlign.SpaceBetween)

        // plan布局
        Row() {
          ForEach(this.planList, (planItem: Plan, index: number) => {
            Image(planItem.imageURL)
              .width('24%')
              .height(60)
              .borderRadius(BORDER_RADIUS_S)
          })
        }
        .width('100%')
        .padding({
          left: PADDING,
          right: PADDING
        })
        .margin({
          top: PADDING_L
        })
        .justifyContent(FlexAlign.SpaceBetween)

        Image(this.adPicture)
          .width('100%')
          .height(60)
          .padding({
            left: PADDING,
            right: PADDING
          })

        // 房源推荐布局
        Row() {
          Text('周边房源推荐')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.black'))
          Text('更多推荐 >')
            .fontSize(12)
            .fontColor($r('app.color.gray'))
        }
        .width('100%')
        .height(44)
        .padding({
          left: PADDING,
          right: PADDING
        })
        .justifyContent(FlexAlign.SpaceBetween)

        // 房源布局
        Grid() {
          ForEach(this.nearbyHouse, (houseItem: HouseItem, index: number) => {
            GridItem() {
              Column({ space: 10 }) {
                // 顶部层叠布局
                Stack() {
                  // 图片
                  Image(houseItem.housePicture)
                    .width('100%')
                    .height('100%')
                    .borderRadius({
                      topLeft: BORDER_RADIUS_L,
                      topRight: BORDER_RADIUS_L
                    })
                  // 地址布局
                  Row({ space: 5 }) {
                    Text('\u{e87e}')
                      .fontFamily('iconfont')
                      .fontSize(14)
                      .fontColor($r('app.color.white'))
                    Text(houseItem.address)
                      .fontSize(14)
                      .fontColor($r('app.color.white'))
                  }
                  .margin({
                    left: 10,
                    bottom: 10
                  })
                }
                .width('100%')
                .height(120)
                .alignContent(Alignment.BottomStart)

                // 价格以及面积的布局
                Row() {
                  Text(houseItem.rentPriceListing + houseItem.rentPriceUnit)
                    .fontColor('#E03810')
                  Text(houseItem.rentArea + '㎡')
                    .fontColor($r('app.color.bg_gray_second'))
                }
                .width('100%')
                .padding({
                  left: PADDING,
                  right: PADDING
                })
                .justifyContent(FlexAlign.SpaceBetween)

                Text('房东直租，巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉巴拉')
                  .width('100%')
                  .maxLines(1)
                  .fontSize(12)
                  .padding({
                    left: PADDING,
                    right: PADDING
                  })
                  .textOverflow({
                    overflow: TextOverflow.Ellipsis
                  })

                // 房屋特点
                Row({ space: 5 }) {
                  Text('大开间')
                    .backgroundColor($r('app.color.primary'))
                    .fontColor('#fff')
                    .fontSize(12)
                    .padding(3)
                    .borderRadius(2)
                  Text('近地铁')
                    .fontColor($r('app.color.gray'))
                    .backgroundColor($r('app.color.bg_gray'))
                    .fontSize(12)
                    .padding(3)
                    .borderRadius(2)
                }
                .width('100%')
                .padding({
                  left: PADDING,
                  right: PADDING
                })
              }
              .width('100%')
              .height(210)
              .backgroundColor(Color.Pink)
              .borderRadius(BORDER_RADIUS_L)
              .onClick(() => {
                router.pushUrl({
                  url: 'view/HouseDetailPage',
                  params: {
                    id: houseItem.id
                  }
                })
              })
            }
          })
        }
        .width('100%')
        .padding(PADDING)
        .columnsTemplate('1fr 1fr')
        .columnsGap(16)
        .rowsGap(16)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
  }
}
