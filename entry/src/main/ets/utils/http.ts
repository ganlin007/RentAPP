import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { deleteToken, getToken } from './tokenUtil'
import { Result } from '../model/Model'

// 模拟器访问本机后端。课堂上是局域网地址，端口仍是 6060
const HOST = 'http://10.98.44.60:6060'

// 创建axios实例
const instance = axios.create({
  baseURL: HOST,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 3. 不使用token的接口
const publicPaths: string[] = [
  '/sendSMSCode',
  '/login',
  '/home/info',
  '/house/nearbyHouses'
]

// 定义请求拦截器
instance.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    // 获取请求路径
    const path: string = (config.url ?? '').split('?')[0]
    // /house/detail?id=4654515665654645
    // 判断path是否在公共路径上
    if (publicPaths.includes(path)) {
      return config
    }
    // 获取token
    const token: string = await getToken();
    if (token) {
      config.headers.set('token', token);
    }
    return config;
  }, (error) => {
    return Promise.reject(error)
  }
)

// 定义响应拦截器
instance.interceptors.response.use(
  async (response: AxiosResponse) => {
    // 业务请求成功
    const result = response.data as Result<object>
    if (result.code === 200) {
      return response
    }
    if (result.code === 401) {
      await deleteToken();
      return Promise.reject(
        new Error('登录已过期，请重新登录！')
      );
    }
    return Promise.reject(
      new Error('网络请求失败')
    )
  },
  async (error: AxiosError) => {
    const status = error.response?.status
    if (status === 401) {
      await deleteToken();
      return Promise.reject(
        new Error('登录已过期，请重新登录！')
      );
    }
    if (error.code === 'econnaborted') {
      return Promise.reject(
        new Error('请求超时，请稍后重试！')
      )
    }
    return Promise.reject(
      new Error(error.message || '网络请求失败')
    )
  }
)

// 接口里的图片地址写的是 127.0.0.1，模拟器访问不到本机
function rewriteHost<T>(payload: Result<T>): Result<T> {
  const text = JSON.stringify(payload).split('http://127.0.0.1:6060').join(HOST)
  return JSON.parse(text) as Result<T>
}

// get请求
export async function get<T>(url: string): Promise<Result<T>> {
  const response: AxiosResponse<Result<T>> = await instance.get(url);
  return rewriteHost(response.data);
}

// post请求
export async function post<T>(url: string, data: object): Promise<Result<T>> {
  const response: AxiosResponse<Result<T>> = await instance.post(url, data);
  return rewriteHost(response.data);
}

// 封装GET POST
export const request = {
  get: get,
  post: post
}
