import { Home } from './Home'
import { See } from './See'
import { Service } from './Service'
import { Discover } from './Discover'
import { Mine } from './Mine'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  @Builder
  tabBuilder(icon: ResourceStr, title: string, index: number) {
    Column({ space: 5 }) {
      Text(icon)
        .fontSize(22)
        .fontFamily('iconfont')
        .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.gray'))
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.gray'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        Home()
      }.tabBar(this.tabBuilder('\u{e603}', '首页', 0))
      TabContent() {
        See()
      }.tabBar(this.tabBuilder('\u{e616}', '想看', 1))
      TabContent() {
        Service()
      }.tabBar(this.tabBuilder('\u{e661}', '服务', 2))
      TabContent() {
        Discover()
      }.tabBar(this.tabBuilder('\u{e66d}', '发现', 3))
      TabContent() {
        Mine()
      }.tabBar(this.tabBuilder('\u{e643}', '我的', 4))
    }
    .width('100%')
    .height('100%')
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}
