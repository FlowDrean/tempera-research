import { get, post, del } from './request'

export function addFavorite(data) {
  return post('/favorite/add', data)
}

export function removeFavorite(itemType, itemId) {
  return del('/favorite/remove', { itemType, itemId })
}

export function getMyFavorites(itemType) {
  const params = itemType ? { itemType } : {}
  return get('/favorite/my', params)
}

export function checkFavorite(itemType, itemId) {
  return get('/favorite/check', { itemType, itemId })
}
