--      ████████╗ █████╗  ██████╗     ██╗     ██╗███████╗████████╗
--      ╚══██╔══╝██╔══██╗██╔════╝     ██║     ██║██╔════╝╚══██╔══╝
--         ██║   ███████║██║  ███╗    ██║     ██║███████╗   ██║
--         ██║   ██╔══██║██║   ██║    ██║     ██║╚════██║   ██║
--         ██║   ██║  ██║╚██████╔╝    ███████╗██║███████║   ██║
--         ╚═╝   ╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚═╝╚══════╝   ╚═╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require('awful')
local modkey = require('keys').modkey

-- define module table
local tag_list = {}

-- create the tag list widget
tag_list.create = function(s)
   return awful.widget.taglist(
      s,
      awful.widget.taglist.filter.all,
      awful.util.table.join(
         awful.button({}, 1,
            function(t)
               t:view_only()
            end
         ),
         awful.button({ modkey }, 1,
            function(t)
               if client.focus then
                  client.focus:move_to_tag(t)
                  t:view_only()
               end
            end
         ),
         awful.button({}, 3,
            awful.tag.viewtoggle
         ),
         awful.button({ modkey }, 3,
            function(t)
               if client.focus then
                  client.focus:toggle_tag(t)
               end
            end
         ),
         awful.button({}, 4,
            function(t)
               awful.tag.viewprev(t.screen)
            end
         ),
         awful.button({}, 5,
            function(t)
               awful.tag.viewnext(t.screen)
            end
         )
      )
   )
end

return tag_list
