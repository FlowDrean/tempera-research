<template>
  <image
    class="svg-icon-img"
    :style="{ width: size, height: size }"
    :src="iconSrc"
    mode="aspectFit"
  />
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  name: { type: String, required: true },
  color: { type: String, default: '#999' },
  fill: { type: String, default: 'none' },
  stroke: { type: String, default: '' },
  size: { type: String, default: '16px' }
})

function enc(svg) {
  return 'data:image/svg+xml,' + encodeURIComponent(svg)
}

/* 每个图标提供 SVG 模板，动态替换颜色 */
function svgTag(body, c, f, s) {
  const sc = s || c
  // 当 fill 不为 'none' 时，用指定颜色；否则保留 fill="none" 避免重复属性
  const fillAttr = f !== 'none' ? `fill="${f}"` : 'fill="none"'
  return `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" ${fillAttr} stroke="${sc}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${body}</svg>`
}

const iconSrc = computed(() => {
  const c = props.color
  const f = props.fill
  const s = props.stroke
  switch (props.name) {
    case 'search':
      return enc(svgTag('<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>', c, f, s))
    case 'headphones':
      return enc(svgTag('<path d="M3 18v-6a9 9 0 0 1 18 0v6"/><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"/>', c, f, s))
    case 'user':
      return enc(svgTag('<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>', c, f, s))
    case 'star':
      return enc(svgTag('<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>', c, f, s))
    case 'message':
      return enc(svgTag('<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>', c, f, s))
    case 'link':
      return enc(svgTag('<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>', c, f, s))
    case 'clock':
      return enc(svgTag('<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>', c, f, s))
    case 'globe':
      return enc(svgTag('<circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>', c, f, s))
    case 'bell':
      return enc(svgTag('<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>', c, f, s))
    case 'microscope':
      return enc(svgTag('<path d="M6 22h12"/><path d="M12 11V2"/><path d="M9 2h6"/><circle cx="6" cy="8" r="4"/><path d="M17 8a4 4 0 0 1-2.5 3.7"/>', c, f, s))
    case 'book':
      return enc(svgTag('<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>', c, f, s))
    case 'graduation':
      return enc(svgTag('<path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 2 3 3 6 3s6-1 6-3v-5"/>', c, f, s))
    case 'lightbulb':
      return enc(svgTag('<path d="M9 18h6"/><path d="M10 22h4"/><path d="M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14"/>', c, f, s))
    case 'trophy':
      return enc(svgTag('<path d="M6 9H4.5a2.5 2.5 0 0 1 0-5C6 4 8 4 8 4"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5C18 4 16 4 16 4"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2z"/>', c, f, s))
    case 'file':
      return enc(svgTag('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>', c, f, s))
    case 'check':
      return enc(svgTag('<polyline points="20 6 9 17 4 12"/>', c, f, s))
    case 'play':
      return enc(`<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="${c}"><polygon points="5 3 19 12 5 21 5 3"/></svg>`)
    case 'fullscreen':
      return enc(svgTag('<polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/><line x1="21" y1="3" x2="14" y2="10"/><line x1="3" y1="21" x2="10" y2="14"/>', c, f, s))
    case 'share':
      return enc(svgTag('<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>', c, f, s))
    case 'info':
      return enc(svgTag('<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>', c, f, s))
    case 'menu':
      return enc(svgTag('<line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/>', c, f, s))
    case 'close':
      return enc(svgTag('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>', c, f, s))
    case 'arrow-down':
      return enc(svgTag('<polyline points="6 9 12 15 18 9"/>', c, f, s))
    case 'arrow-up':
      return enc(svgTag('<polyline points="18 15 12 9 6 15"/>', c, f, s))
    case 'arrow-left':
      return enc(svgTag('<polyline points="15 18 9 12 15 6"/>', c, f, s))
    case 'arrow-right':
      return enc(svgTag('<polyline points="9 18 15 12 9 6"/>', c, f, s))
    case 'gear':
      return enc(svgTag('<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>', c, f, s))
    default:
      return ''
  }
})
</script>

<style scoped>
.svg-icon-img {
  display: inline-block;
  flex-shrink: 0;
}
</style>
