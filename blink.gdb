target extended-remote :3333
monitor reset halt
monitor mww 0x4002104C 0x2
monitor mww 0x48000400 0xFFFFFE7F
while 1
  monitor mww 0x48000418 0x00000008
  monitor sleep 500
  monitor mww 0x48000418 0x00080000
  monitor sleep 500
  end 
