import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'

// 存储常量
const store: string = 'auth_store'

// 键值名
const token_info: string = 'token'

// 定义存储上下文信息变量
let api_context: common.UIAbilityContext | undefined;

// 初始化上下文信息
export function initContext(context: common.UIAbilityContext) {
  api_context = context
}

// 获取context
// 获取preferences实例
async function getStore(): Promise<preferences.Preferences> {
  if (!api_context) {
    throw new Error('toekn context 未初始化')
  }
  return preferences.getPreferences(api_context, store);
}

// 保存token
export async function savaToken(token: string): Promise<void> {
  const pref = await getStore();
  pref.put(token_info, token);
  pref.flush()
}

// 获取token
export async function getToken(): Promise<string> {
  const pref = await getStore();
  // let token: string = await pref.get(token_info, '') as string
  // return token
  return await pref.get(token_info, '') as string
}

// 删除token
export async function deleteToken(): Promise<void> {
  const pref = await getStore();
  await pref.delete(token_info);
  pref.flush()
}
