max_sign_width = 100

function init_signs()
 add_sign('here the rain never stops\n...\nnor does the sun rise...', 7, 37)
 add_sign('thick fog... biting cold.\nthe wind howls and howls\ncan you hear it?', 19, 34)
 add_sign('these floating moons\nthey shine brightly.\nthey call to you.', 29, 31)
 add_sign('you feel an urge\n\nan insatiable desire\n\nto collect all the moons.', 54, 37)
 add_sign('will you prevail in these\ntrials? they have taken\nmany before you,\nyou know...',19,43)
 add_sign('the ancient memory\nof the moon lord\'s\nbloodline...\nyou posses it',21,62)
 add_sign('you recall building a\ncity, much like this one.\nbut it feels distant,\nlike the memory doesn\'t\nbelong to you...',94,57)
 add_sign('you are no moon lord\nyou are no moon lord\nyou are no moon lord\nyou are no moon lord\nyou are no moon lord\nyou are no moon lord\nyou are no moon lord\nyou are no moon lord\n...',118,42)
 add_sign('your fate...\nis it your fate?\nis it yours to change?',125,62)
 add_sign('the sight of this shrine\nmakes you feel safe\nmakes you feel at home.',72,18)
 --but those scarlett eyes...
 --they are not those of a moon lord. those are the eyes of a lord slayer.
 
 --upon your slaugher of the moon queen you
end

function add_sign(message, x_tile, y_tile, is_moon_counter)
 add(signs,{
  x=x_tile*8,
  y=y_tile*8,
  w=8,
  h=8,
  sprite=103,
  is_hovered=false,
  is_active=false,
  text=message,
  hover_height=0,
  text_index=1,
  b=is_moon_counter or false,
  draw=function(self)
   if self.is_hovered and not self.is_active then
    print('🅾️',self.x,self.y-self.hover_height,13)
   end
   if self.is_active then
    local substring=sub(self.text,0,flr(self.text_index))
    draw_rounded_textbox(self.x/8,self.y/8,substring)
   end
  end,
  update=function(self)
   self.is_hovered=touch(player,self)
   if self.is_hovered then
    self.hover_height=lerp(self.hover_height,8,0.5)
    if btnp(4) then
     self.is_active=not self.is_active
    end
   else
    self.hover_height=0
    self.is_active=false
   end
   if self.is_active then
    self.text_index+=0.5
   end
  end
 })
end
