module Termbox2
  extend self

  def init
    C.init
  end

  def shutdown
    C.shutdown
  end

  def present
    C.present
  end

  def clear
    C.clear
  end

  def print(x, y, ch)
    C.print(x, y, ch)
  end

  def poll_event
    C.poll_event
  end

  def width
    C.width
  end

  def height
    C.height
  end

  def set_cell(x, y, ch, fg, bg)
    C.set_cell(x, y, ch, fg, bg)
  end

  def set_cursor(x, y)
    C.set_cursor(x, y)
  end

  def hide_cursor
    C.hide_cursor
  end

  module Keys
    CTRL_TILDE       = 0x00
    CTRL_2           = 0x00
    CTRL_A           = 0x01
    CTRL_B           = 0x02
    CTRL_C           = 0x03
    CTRL_D           = 0x04
    CTRL_E           = 0x05
    CTRL_F           = 0x06
    CTRL_G           = 0x07
    BACKSPACE        = 0x08
    CTRL_H           = 0x08
    TAB              = 0x09
    CTRL_I           = 0x09
    CTRL_J           = 0x0a
    CTRL_K           = 0x0b
    CTRL_L           = 0x0c
    ENTER            = 0x0d
    CTRL_M           = 0x0d
    CTRL_N           = 0x0e
    CTRL_O           = 0x0f
    CTRL_P           = 0x10
    CTRL_Q           = 0x11
    CTRL_R           = 0x12
    CTRL_S           = 0x13
    CTRL_T           = 0x14
    CTRL_U           = 0x15
    CTRL_V           = 0x16
    CTRL_W           = 0x17
    CTRL_X           = 0x18
    CTRL_Y           = 0x19
    CTRL_Z           = 0x1a
    ESC              = 0x1b
    CTRL_LSQ_BRACKET = 0x1b
    CTRL_3           = 0x1b
    CTRL_4           = 0x1c
    CTRL_BACKSLASH   = 0x1c
    CTRL_5           = 0x1d
    CTRL_RSQ_BRACKET = 0x1d
    CTRL_6           = 0x1e
    CTRL_7           = 0x1f
    CTRL_SLASH       = 0x1f
    CTRL_UNDERSCORE  = 0x1f
    SPACE            = 0x20
    BACKSPACE2       = 0x7f
    CTRL_8           = 0x7f
    F1               = 0xffff - 0
    F2               = 0xffff - 1
    F3               = 0xffff - 2
    F4               = 0xffff - 3
    F5               = 0xffff - 4
    F6               = 0xffff - 5
    F7               = 0xffff - 6
    F8               = 0xffff - 7
    F9               = 0xffff - 8
    F10              = 0xffff - 9
    F11              = 0xffff - 10
    F12              = 0xffff - 11
    INSERT           = 0xffff - 12
    DELETE           = 0xffff - 13
    HOME             = 0xffff - 14
    # end is reserved, the name needed to be changed
    END_KEY          = 0xffff - 15
    PGUP             = 0xffff - 16
    PGDN             = 0xffff - 17
    ARROW_UP         = 0xffff - 18
    ARROW_DOWN       = 0xffff - 19
    ARROW_LEFT       = 0xffff - 20
    ARROW_RIGHT      = 0xffff - 21
    BACK_TAB         = 0xffff - 22
    MOUSE_LEFT       = 0xffff - 23
    MOUSE_RIGHT      = 0xffff - 24
    MOUSE_MIDDLE     = 0xffff - 25
    MOUSE_RELEASE    = 0xffff - 26
    MOUSE_WHEEL_UP   = 0xffff - 27
    MOUSE_WHEEL_DOWN = 0xffff - 28
  end

  module Color
    DEFAULT = 0x0000
    BLACK = 0x0001
    RED = 0x0002
    GREEN = 0x0003
    YELLOW = 0x0004
    BLUE = 0x0005
    MAGENTA = 0x0006
    CYAN = 0x0007
    WHITE = 0x0008
  end
end
