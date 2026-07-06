import { get } from './request'

export function getPromoImage() {
  return get('/promo/image')
}
