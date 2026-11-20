import { houseDetail, HomeItem, HouseItem, orderInfo, Result, Token, UserInfo } from '../model/Model'
import { get, post } from './http'
import { savaToken } from './tokenUtil'

// 获取首页数据方法
export function getHomeData() {
  return get<HomeItem>('/home/info');
}

// 获取附近房源方法
export function getHouseData() {
  return get<Array<HouseItem>>('/house/nearbyHouses');
}

// 获取验证码方法
export function postSMSCode(data: object) {
  return post<string>('/sendSMSCode', data);
}

// 登录方法
export async function postLogin(data: object) {
  const result = await post<Token>('/login', data);
  await savaToken(result.data.token);
  return result;
}

// 获取个人信息方法
export async function getUserInfo() {
  return await get<UserInfo>('/auth/user/userInfo')
}

// 获取房屋信息方法
export async function getHouseDetail(id: string): Promise<Result<houseDetail>> {
  // 第一种方式
  // return await get<houseDetail>('/house/detail?id=' + id)
  // 第二种方式 推荐
  return await get<houseDetail>(`/house/detail?id=${id}`)
}

// 租房预约方法
export async function postOrderInfo(order: orderInfo): Promise<Result<orderInfo>> {
  return post<orderInfo>('/auth/house/reservation', order);
}
