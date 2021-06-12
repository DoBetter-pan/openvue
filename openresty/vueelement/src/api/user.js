import request from '@/utils/request'

export function login(data) {
  return request({
    url: '/openservice/user/login',
    method: 'post',
    data
  })
}

export function getInfo(token) {
  return request({
    url: '/openservice/user/info',
    method: 'get',
    params: { token }
  })
}

export function logout() {
  return request({
    url: '/openservice/user/logout',
    method: 'post'
  })
}
