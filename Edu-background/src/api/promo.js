import request from './request'

export function getPromoImage() {
  return request.get('/promo/image')
}

export function updatePromoImage(data) {
  return request.put('/promo/image', data)
}
