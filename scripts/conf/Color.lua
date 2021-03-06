
local babypink = {red = 255, green = 142, blue = 240, alpha = 255}
local babyblue = {red = 170, green = 183, blue = 255, alpha = 255}

return {
  -- Common colors
  white = {red = 255, green = 255, blue = 255, alpha = 255},
  red = {red = 255, green = 0, blue = 0, alpha = 255},
  green = {red = 0, green = 255, blue = 0, alpha = 255},
  blue = {red = 0, green = 0, blue = 255, alpha = 255},
  babypink = babypink,
  babyblue = babyblue,

  -- Tile skill colors (selectable)
  tile_general = {red = 215, green = 127, blue = 215, alpha = 215},
  tile_move = {red = 100, green = 100, blue = 255, alpha = 215},
  tile_support = {red = 100, green = 255, blue = 100, alpha = 215},
  tile_attack = {red = 255, green = 100, blue = 100, alpha = 215},
  tile_nothing = {red = 179, green = 179, blue = 179, alpha = 192},

  -- Tile skill colors (non-selectable)
  tile_general_off = {red = 200, green = 110, blue = 200, alpha = 102},
  tile_move_off = {red = 76, green = 76, blue = 255, alpha = 102},
  tile_support_off = {red = 76, green = 255, blue = 76, alpha = 102},
  tile_attack_off = {red = 255, green = 76, blue = 76, alpha = 102},
  tile_nothing_off = {red = 150, green = 150, blue = 150, alpha = 50},

  -- Battle heal/damagge pop-ups
  popup_dmghp = {red = 255, green = 255, blue = 127, alpha = 255},
  popup_dmgsp = {red = 255, green = 76, blue = 76, alpha = 255},
  popup_healhp = {red = 76, green = 255, blue = 76, alpha = 255},
  popup_healsp = {red = 76, green = 76, blue = 255, alpha = 255},
  popup_miss = {red = 204, green = 204, blue = 204, alpha = 255},
  popup_status_add = {red = 255, green = 255, blue = 255, alpha = 255},
  popup_status_remove = {red = 255, green = 255, blue = 255, alpha = 255},
  
  -- GUI
  gui_text_enabled = {red = 255, green = 255, blue = 255, alpha = 255},
  gui_text_disabled = {red = 200, green = 200, blue = 200, alpha = 200},
  gui_icon_enabled = {red = 255, green = 255, blue = 255, alpha = 255},
  gui_icon_disabled = {red = 200, green = 200, blue = 200, alpha = 200},
  barHP = {red = 50, green = 255, blue = 100, alpha = 255},
  barSP = {red = 50, green = 100, blue = 255, alpha = 255},
  barEXP = {red = 255, green = 255, blue = 100, alpha = 255},
  barTC = {red = 255, green = 200, blue = 100, alpha = 255}
  
}
