const battery = await Service.import('battery')

const Battery = () => Widget.Box({
  children: [
    Widget.Icon({
      icon: 'battery-symbolic'
    }).hook(battery, self => {
      const level = Math.min(Math.floor(battery.percent / 10) + 1, 10)
      if (battery.charging) {
        self.icon = `battery-level-${level}0-charging-symbolic`
      }
      else {
        self.icon = `battery-level-${level}0-symbolic`   
      }
    }),
    Widget.Label({
      label: ''
    }).hook(battery, self => {
      self.label = `${battery.percent}%`
      if (! battery.charging) {
        const hh = Math.floor(battery.time_remaining / 3600).toString().padStart(2, '0')
        const mm = Math.floor((battery.time_remaining % 3600) / 60).toString().padStart(2, '0')
        self.label += ` (${hh}:${mm})`
      }
    })
  ],
  class_name: 'widget',
}).hook(battery, self => {
  if ((! battery.available) || battery.charged) {
    self.visible = false
  }
  else {
    self.visible = true
  }
})

export default Battery
