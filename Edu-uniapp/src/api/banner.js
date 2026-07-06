import { get } from './request'

/**
 * Get active banners for home page carousel
 */
export function getBannerList() {
  return get('/banner/list')
}
