import { http } from '@kit.NetworkKit'
import { Prompt } from '@kit.ArkUI'
import { Home_Result } from '../model/HomeData'
import { HouseResult } from '../model/HouseData'

export class HttpUtils {
  // 1. 定义http变量
  httpRequest: http.HttpRequest

  // 2. 创建http构造函数
  constructor() {
    this.httpRequest = http.createHttp()
  }

  // 3. 发送http请求方法
  async getHomeData(): Promise<Home_Result> {
    try {
      const response = await this.httpRequest.request('http://10.98.10.18:6060/home/info', {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
      })
      console.log('相应: ' + response)

      if (response.responseCode === 200) {
        const result: Home_Result = JSON.parse(response.result as string)
        console.log('结果: ' + JSON.stringify(result))
        return result
      } else {
        return Promise.reject({
          code: response.responseCode,
          status: 'fail',
          message: `数据请求失败: ${response.responseCode}`
        })
      }
    } catch (e) {
      Prompt.showToast({
        message: '网络错误，数据请求失败'
      })
      return Promise.reject({
        code: 500,
        status: 'error',
        message: '网络错误'
      })
    }
  }

  // 获取附近房源方法
  async getHouseData(): Promise<HouseResult> {
    try {
      const response = await this.httpRequest.request('http://10.98.10.18:6060/house/nearbyHouses', {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
      })
      if (response.responseCode === 200) {
        const result: HouseResult = JSON.parse(response.result as string)
        return result
      } else {
        return Promise.reject({
          code: response.responseCode,
          status: 'fail',
          message: `数据请求失败: ${response.responseCode}`
        })
      }
    } catch (error) {
      Prompt.showToast({
        message: '网络错误，请求失败'
      })
      return Promise.reject({
        code: 500,
        status: 'fail',
        message: '网络错误，请求失败'
      })
    }
  }
}
