import { Prompt, router } from '@kit.ArkUI'
import { getHouseDetail, postOrderInfo } from '../utils/Apis'
import {
  discountItem,
  houseDetail,
  housePictureItem,
  household,
  itemListItem,
  metaInfoItem,
  orderInfo,
  rentInfoItem,
  Result,
  supportItem,
  Tag
} from '../model/Model'

interface houseId {
  id: string
}

interface DateItem {
  label: string
  value: string
  day: string
  isToday: boolean
}

@Entry
@Component
struct HouseDetailPage {
  @State houseId: string = ''
  @State houseInfo: houseDetail | null = null
  // 当前选中图片分类下标
  @State selectedSpaceIndex: number = 0
  // 顶部标题栏是否吸顶
  @State isTopBarFixed: boolean = false
  // 加载中
  @State isLoading: boolean = true
  // 租房预约信息
  @State reservation_info: orderInfo = {
    houseId: '',
    date: '',
    name: '',
    comment: '',
    phone: ''
  }
  // 是否显示弹框组件
  @State isShow: boolean = false
  // 日期面板的显示与隐藏
  @State isShowPanel: boolean = false
  // 日期列表
  @State dateList: Array<DateItem> = []

  async aboutToAppear() {
    const params = router.getParams() as houseId
    if (params) {
      this.houseId = params.id
      this.reservation_info.houseId = params.id
      try {
        const result: Result<houseDetail> = await getHouseDetail(this.houseId)
        this.houseInfo = result.data
        console.log('房屋详情：' + JSON.stringify(this.houseInfo))
      } catch (e) {
        console.error('获取房屋详情失败：' + JSON.stringify(e))
      } finally {
        this.isLoading = false
      }
    } else {
      this.isLoading = false
    }
    this.initDateList()
  }

  // 初始化未来七天的日期
  initDateList() {
    const list: Array<DateItem> = []
    const weekDay: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const now = new Date()
    // 课堂上写成了 i < list.length，列表刚创建时循环一次都不会进
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getTime() + i * 24 * 60 * 60 * 1000)
      const year = d.getFullYear()
      const month = String(d.getMonth() + 1).padStart(2, '0')
      const day = String(d.getDate()).padStart(2, '0')
      const str = `${year}-${month}-${day}`
      list.push({
        label: i === 0 ? '今天' : (i === 1 ? '明天' : weekDay[d.getDay()]),
        value: str,
        day: `${month}-${day}`,
        isToday: i === 0
      })
    }
    this.dateList = list
    this.reservation_info.date = list[0].value
  }

  // 提交预约信息
  async submitOrder() {
    if (!this.reservation_info.houseId.trim() || !this.reservation_info.date.trim() ||
      !this.reservation_info.name.trim() || !this.reservation_info.comment.trim() ||
      !this.reservation_info.phone?.trim()) {
      Prompt.showToast({
        message: '请填写对应的信息'
      })
      return
    }
    try {
      const result: Result<orderInfo> = await postOrderInfo(this.reservation_info)
      if (result.code === 200) {
        Prompt.showToast({
          message: '预约成功'
        })
        this.isShow = false
        this.reservation_info.name = ''
        this.reservation_info.date = this.dateList[0].value
        this.reservation_info.comment = ''
        this.reservation_info.phone = ''
        this.isShowPanel = false
      } else {
        Prompt.showToast({
          message: result.message || '预约失败，请重试'
        })
      }
    } catch (e) {
      Prompt.showToast({
        message: '网络异常，请稍后重试！'
      })
    }
  }

  // ==================== 顶部标题栏 ====================
  @Builder
  TopBar() {
    Row() {
      Text('返回')
        .fontSize(16)
        .fontColor('#333')
        .onClick(() => {
          router.back()
        })
      Text(this.houseInfo ? this.houseInfo.houseTitle : '房屋详情')
        .fontSize(16)
        .fontColor('#333')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 })
        .maxLines(1)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.isTopBarFixed ? '#FFFFFF' : '#F5F7FA')
  }

  // ==================== 图片分类 Tab ====================
  @Builder
  SpaceTabs() {
    Scroll() {
      Row({ space: 24 }) {
        ForEach(this.houseInfo!.housePicture, (item: housePictureItem, index: number) => {
          Column() {
            Text(`${item.spaceName}${item.picList.length}`)
              .fontSize(15)
              .fontColor(index === this.selectedSpaceIndex ? '#333' : '#999')
              .fontWeight(index === this.selectedSpaceIndex ? FontWeight.Medium : FontWeight.Normal)
            Divider()
              .width('100%')
              .height(2)
              .backgroundColor(index === this.selectedSpaceIndex ? '#00C9A7' : '#00000000')
              .margin({ top: 6 })
          }
          .padding({ bottom: 6 })
          .onClick(() => {
            this.selectedSpaceIndex = index
          })
        }, (item: housePictureItem, index: number) => index.toString())
        Text('全部').fontSize(15).fontColor('#999')
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(44)
    .backgroundColor('#FFFFFF')
  }

  // ==================== 图片轮播 ====================
  @Builder
  PictureSwiper() {
    Swiper() {
      ForEach(this.houseInfo!.housePicture[this.selectedSpaceIndex].picList, (url: string, index: number) => {
        Image(url)
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      }, (url: string, index: number) => index.toString())
    }
    .width('100%')
    .height(240)
    .margin({ top: 8 })
    .padding({ left: 16, right: 16 })
    .indicator(
      Indicator.dot()
        .itemWidth(6).itemHeight(6)
        .selectedItemWidth(16).selectedItemHeight(6)
        .color('rgba(255,255,255,0.5)')
        .selectedColor('#FFFFFF')
    )
    .autoPlay(false)
  }

  // ==================== 价格区 ====================
  @Builder
  PriceSection() {
    Row() {
      Text('¥').fontSize(18).fontColor('#FF5A1F').fontWeight(FontWeight.Bold)
      Text(this.houseInfo!.rentPriceUnitListing)
        .fontSize(30).fontColor('#FF5A1F').fontWeight(FontWeight.Bold)
      Text('元(年付价)').fontSize(13).fontColor('#FF5A1F').margin({ left: 2 })
      Blank()
      Row() {
        Text('租金试算').fontSize(12).fontColor('#999')
        Image($r('app.media.startIcon')).width(12).height(12).margin({ left: 4 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 8 })
  }

  // ==================== 优惠卡片 ====================
  @Builder
  DiscountCard(discount: discountItem) {
    Row() {
      Text(discount.tagTxt)
        .fontSize(11)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C9A7')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4)
      Text(discount.txt)
        .fontSize(12)
        .fontColor('#666')
        .margin({ left: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
      Image($r('app.media.startIcon')).width(12).height(12)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#F7FAF9')
    .margin({ left: 16, right: 16, bottom: 6 })
    .borderRadius(8)
  }

  // ==================== 元信息（面积/朝向/户型/楼层） ====================
  @Builder
  MetaInfoSection() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.houseInfo!.metaInfo, (item: metaInfoItem, idx: number) => {
        Column() {
          Text(item.name).fontSize(12).fontColor('#999')
          Text(item.desc).fontSize(14).fontColor('#333').fontWeight(FontWeight.Medium).margin({ top: 4 })
        }
        .width('50%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 10 })
      }, (item: metaInfoItem, idx: number) => idx.toString())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  // ==================== 标签行 ====================
  @Builder
  TagsRow() {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.houseInfo!.tags, (tag: Tag) => {
        Text(tag.name)
          .fontSize(11)
          .fontColor('#666')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#F2F4F5')
          .borderRadius(4)
          .margin({ right: 8, bottom: 8 })
      }, (tag: Tag, index: number) => index.toString())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 4, bottom: 8 })
  }

  // ==================== 键值行 ====================
  @Builder
  TermRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor('#999').width(70)
      Text(value).fontSize(13).fontColor('#333')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  // ==================== 键值单元（两列） ====================
  @Builder
  TermCell(label: string, value: string) {
    Row() {
      Text(label).fontSize(13).fontColor('#999').width(70)
      Text(value).fontSize(13).fontColor('#333')
    }
    .width('50%')
    .padding({ top: 6, bottom: 6 })
  }

  // ==================== 租期信息区 ====================
  @Builder
  RentTermSection() {
    Column() {
      Divider().color('#F0F0F0').margin({ left: 16, right: 16 })
      Column() {
        this.TermRow('入住', this.houseInfo!.rentTerm.term)
        this.TermRow('租期', this.houseInfo!.rentTerm.checkInTime + ' | ' + this.houseInfo!.rentTerm.seeTime)
        Flex({ wrap: FlexWrap.Wrap }) {
          this.TermCell('厨房', this.houseInfo!.rentTerm.kitchen)
          this.TermCell('电梯', this.houseInfo!.rentTerm.lift)
          this.TermCell('年代', this.houseInfo!.rentTerm.year)
          this.TermCell('装修', this.houseInfo!.rentTerm.renovation)
          this.TermCell('上架', this.houseInfo!.rentTerm.grounding)
          this.TermCell('供暖', this.houseInfo!.rentTerm.heating)
          this.TermCell('绿化', this.houseInfo!.rentTerm.green)
        }
        .width('100%')
        .margin({ top: 8 })
        Row() {
          Text('环保').fontSize(13).fontColor('#999').width(70)
          Text(this.houseInfo!.rentTerm.protection).fontSize(13).fontColor('#333')
          Text('查看报告').fontSize(12).fontColor('#00C9A7').margin({ left: 8 })
          Image($r('app.media.startIcon')).width(10).height(10).margin({ left: 2 })
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
        Row() {
          Text('小区').fontSize(13).fontColor('#999').width(70)
          Text(this.houseInfo!.rentTerm.house).fontSize(13).fontColor('#FF5A1F')
          Image($r('app.media.startIcon')).width(10).height(10).margin({ left: 4 })
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }
      .padding({ left: 16, right: 16 })
    }
  }

  // ==================== 通用区块标题 ====================
  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor('#333')
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 12 })
  }

  // ==================== 房屋信息（租客） ====================
  @Builder
  RentInfoSection() {
    Column() {
      ForEach(this.houseInfo!.rentInfo, (item: rentInfoItem, idx: number) => {
        Row() {
          Image(item.image !== '' ? item.image : $r('app.media.startIcon'))
            .width(36).height(36).borderRadius(18)
          Column() {
            Text(item.title).fontSize(13).fontColor('#333')
            Text(item.userTag).fontSize(11).fontColor('#999').margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 10 })
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }, (item: rentInfoItem, idx: number) => `${idx}-${item.title}`)
      Text('* 已出租房屋为您展示房屋签约人信息')
        .fontSize(11)
        .fontColor('#BBB')
        .width('100%')
        .margin({ top: 6 })
    }
    .padding({ left: 16, right: 16 })
  }

  // ==================== 物品配置 ====================
  @Builder
  HouseholdSection() {
    Column() {
      ForEach(this.houseInfo!.householdItem, (group: household, groupIndex: number) => {
        Column() {
          Row() {
            Text(group.name).fontSize(14).fontColor('#333').fontWeight(FontWeight.Medium)
            Text(`${group.itemList.length}件物品`).fontSize(12).fontColor('#999').margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 8 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(group.itemList, (it: itemListItem, itemIndex: number) => {
              Row() {
                Image($r('app.media.startIcon')).width(14).height(14)
                Text(it.value).fontSize(13).fontColor('#666').margin({ left: 4 })
              }
              .width('33%')
              .margin({ bottom: 10 })
            }, (it: itemListItem, itemIndex: number) => `${groupIndex}-${itemIndex}`)
          }
        }
      }, (group: household, groupIndex: number) => groupIndex.toString())
      Text('查看全部内容')
        .fontSize(13)
        .fontColor('#666')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .borderRadius(8)
        .backgroundColor('#F5F6F8')
    }
    .padding({ left: 16, right: 16 })
  }

  // ==================== 租住服务与保障 ====================
  @Builder
  SupportSection() {
    Column() {
      Text('谷粒专享').fontSize(12).fontColor('#999').margin({ bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.houseInfo!.support, (item: supportItem, index: number) => {
          Row() {
            Image(item.image !== '' ? item.image : $r('app.media.startIcon'))
              .width(36).height(36).borderRadius(18)
            Column() {
              Text(item.title).fontSize(13).fontColor('#333')
              Text(item.subTitle).fontSize(11).fontColor('#999').margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 8 })
            .layoutWeight(1)
          }
          .width('50%')
          .margin({ bottom: 14 })
        }, (item: supportItem, index: number) => index.toString())
      }
      .width('100%')
      Text('查看全部内容')
        .fontSize(13)
        .fontColor('#666')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .borderRadius(8)
        .backgroundColor('#F5F6F8')
    }
    .padding({ left: 16, right: 16 })
  }

  // ==================== 底部操作栏 ====================
  @Builder
  BottomBar() {
    Row({ space: 12 }) {
      Column() {
        Image($r('app.media.startIcon')).width(22).height(22)
        Text('99+').fontSize(10).fontColor('#666')
      }
      .width(64)
      Button('去看房')
        .layoutWeight(1)
        .height(40)
        .fontSize(15)
        .fontColor('#333')
        .backgroundColor('#F5F7FA')
        .onClick(() => {
          this.isShow = true
        })
      Button('立即预定')
        .layoutWeight(1)
        .height(40)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#00C9A7')
        .onClick(() => {
          this.isShow = true
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  // ==================== 加载中 ====================
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress().width(48).height(48).color('#00C9A7')
      Text('加载中...').fontSize(13).fontColor('#999').margin({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 空状态 ====================
  @Builder
  EmptyView() {
    Column() {
      Text('暂无房屋信息')
        .fontSize(14)
        .fontColor('#999')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  BindSheetBuilder() {
    Column() {
      Text('预约看房')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')
        .margin({ bottom: 16 })
      TextInput({ placeholder: '请输入姓名', text: this.reservation_info.name })
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .onChange((value: string) => {
          this.reservation_info.name = value
        })
      TextInput({ placeholder: '请输入手机号', text: this.reservation_info.phone })
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .margin({ top: 12 })
        .onChange((value: string) => {
          this.reservation_info.phone = value
        })
      Text('预约日期')
        .fontSize(13)
        .fontColor('#999')
        .width('100%')
        .margin({ top: 16, bottom: 8 })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.dateList, (item: DateItem, index: number) => {
          Column() {
            Text(item.label).fontSize(12).fontColor(this.reservation_info.date === item.value ? '#00C9A7' : '#333')
            Text(item.day).fontSize(12).fontColor(this.reservation_info.date === item.value ? '#00C9A7' : '#999')
              .margin({ top: 4 })
          }
          .width('18%')
          .padding({ top: 8, bottom: 8 })
          .margin({ right: 8, bottom: 8 })
          .borderRadius(8)
          .backgroundColor(this.reservation_info.date === item.value ? '#F0FAF7' : '#FFFFFF')
          .border({
            width: 1,
            color: this.reservation_info.date === item.value ? '#00C9A7' : '#E5E5E5'
          })
          .onClick(() => {
            this.reservation_info.date = item.value
          })
        }, (item: DateItem, index: number) => index.toString())
      }
      TextArea({ placeholder: '请输入备注信息', text: this.reservation_info.comment })
        .height(80)
        .backgroundColor('#F7F8FA')
        .borderRadius(8)
        .margin({ top: 8 })
        .onChange((value: string) => {
          this.reservation_info.comment = value
        })
      Button('提交预约')
        .width('100%')
        .height(44)
        .margin({ top: 16 })
        .backgroundColor('#00C9A7')
        .onClick(() => {
          this.submitOrder()
        })
    }
    .width('100%')
    .padding(16)
  }

  // ==================== 主结构 ====================
  build() {
    Column() {
      this.TopBar()
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.houseInfo === null) {
        this.EmptyView()
      } else {
        Scroll() {
          Column() {
            // 图片分类 tab（housePicture 为空时兜底）
            if (this.houseInfo.housePicture && this.houseInfo.housePicture.length > 0) {
              this.SpaceTabs()
              this.PictureSwiper()
            }
            Text(this.houseInfo.houseTitle)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('100%')
              .padding({ left: 16, right: 16, top: 12 })
            Text(this.houseInfo.address)
              .fontSize(13)
              .fontColor('#999')
              .width('100%')
              .padding({ left: 16, right: 16, top: 6 })
            this.PriceSection()
            ForEach(this.houseInfo.discounts, (discount: discountItem, index: number) => {
              this.DiscountCard(discount)
            }, (discount: discountItem, index: number) => index.toString())
            this.MetaInfoSection()
            this.TagsRow()
            this.RentTermSection()
            this.SectionTitle('房屋信息')
            this.RentInfoSection()
            this.SectionTitle('物品配置')
            this.HouseholdSection()
            this.SectionTitle('租住服务与保障')
            this.SupportSection()
          }
          .width('100%')
          .padding({ bottom: 16 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .onScroll((xOffset: number, yOffset: number) => {
          this.isTopBarFixed = yOffset > 30
        })
        this.BottomBar()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: 44 })
    .bindSheet($$this.isShow, this.BindSheetBuilder(), {
      height: 600,
      dragBar: true,
      showClose: false,
      backgroundColor: '#f7f7fa',
      onDisappear: () => {
        this.isShow = false
      }
    })
  }
}
