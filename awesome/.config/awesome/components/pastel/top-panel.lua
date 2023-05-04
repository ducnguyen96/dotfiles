--      ████████╗ ██████╗ ██████╗     ██████╗  █████╗ ███╗   ██╗███████╗██╗
--      ╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
--         ██║   ██║   ██║██████╔╝    ██████╔╝███████║██╔██╗ ██║█████╗  ██║
--         ██║   ██║   ██║██╔═══╝     ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
--         ██║   ╚██████╔╝██║         ██║     ██║  ██║██║ ╚████║███████╗███████╗
--         ╚═╝    ╚═════╝ ╚═╝         ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi

-- import widgets
local tag_list = require("widgets.tag-list")
local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')

-- define module table
local top_panel = {}


-- ===================================================================
-- Bar Creation
-- ===================================================================


top_panel.create = function(s)
   local panel = awful.wibar({
      screen = s,
      position = "top",
      ontop = true,
      height = beautiful.top_panel_height,
      width = s.geometry.width,
   })

   -- Create a textclock widget
   mytextclock = wibox.widget.textclock()
   local cw = calendar_widget({
      theme = 'nord',
      previous_month_button = 1,
      next_month_button = 3,
   })

   mytextclock:connect_signal("button::press",
      function(_, _, _, button)
         if button == 1 then cw.toggle() end
      end)

   panel:setup {
      expand = "none",
      layout = wibox.layout.align.horizontal,
      tag_list.create(s),
      -- require("widgets.calendar").create(s),
      mytextclock,
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.layout.margin(wibox.widget.systray(), dpi(5), dpi(5), dpi(5), dpi(5)),
         volume_widget {
            widget_type = 'horizontal_bar',
            with_icon = true,
            mute_color = '#f77272',
            refresh_rate = 10,
         },
         brightness_widget(),
         require("widgets.battery"),
         -- require("widgets.network")(),
         wibox.layout.margin(require("widgets.layout-box"), dpi(5), dpi(5), dpi(5), dpi(5))
      }
   }


   -- ===================================================================
   -- Functionality
   -- ===================================================================


   -- hide panel when client is fullscreen
   local function change_panel_visibility(client)
      if client.screen == s then
         panel.ontop = not client.fullscreen
      end
   end

   -- connect panel visibility function to relevant signals
   client.connect_signal("property::fullscreen", change_panel_visibility)
   client.connect_signal("focus", change_panel_visibility)
end

return top_panel
