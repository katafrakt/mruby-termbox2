# mruby-termbox2

This is a mruby binding for [termbox2](https://github.com/termbox/termbox2).

## Installation

Add this mrbgem to `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
    # ...
    conf.gem :git => 'https://github.com/katafrakt/mruby-termbox2.git'
end
```

Compile mruby with it.

## Usage

It is intentionally kept close to the original C API (at least where it makes sense). Therefore it might feel a bit awkward at times for a Ruby programmer. It is, however, expected that higher level mrbgems will build on top of this one.

### Example

This will create a very simple empty window with a moving character '@', which is green and bold. You can use arrow keys to move the character around. ESC closes the application.

```ruby
Termbox2.init()

w = Termbox2.width()
h = Termbox2.height()

player_x = w/2
player_y = h/2

loop do
  Termbox2.clear()

  Termbox2.set_cell(
    player_x, player_y, '@', 
    Termbox2::Format::BOLD | Termbox2::Color::GREEN, 
    Termbox2::Color::DEFAULT
  )

  Termbox2.present()

  event = Termbox2.poll_event
  case event.key
  when Termbox2::Keys::ARROW_UP
    player_y -= 1 unless player_y == 0
  when Termbox2::Keys::ARROW_DOWN
    player_y += 1 unless player_y == h - 1
  when Termbox2::Keys::ARROW_LEFT
    player_x -= 1 unless player_x == 0
  when Termbox2::Keys::ARROW_RIGHT
    player_x += 1 unless player_x == w - 1
  when Termbox2::Keys::ESC
    break
  end
end

Termbox2.shutdown()
```

## License

This project is licensed under the MIT license. See the [LICENSE.md](LICENSE.md) file for details.
