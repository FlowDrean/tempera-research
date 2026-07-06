import { get } from './request'

/**
 * Get all promotion cards for home page 探索成果 section
 */
export function getPromotionList() {
  return get('/promotion/list')
}
