import { get } from './request'

/**
 * Get all explore module cards for home page 学术探索 section
 */
export function getExploreList() {
  return get('/explore/list')
}
