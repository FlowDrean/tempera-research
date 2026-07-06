import { get, post } from './request'

export function submitApplication(data) {
  return post('/application/submit', data)
}

export function getMyApplications() {
  return get('/application/my')
}
