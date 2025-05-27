assert("Termbox2 can print and read output") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.print(x: 0, y: 0, character: '@')
  Termbox2.print(x: 1, y: 0, character: 'X')
  Termbox2.present
  
  output = Termbox2Test.read_output
  
  # Check for cursor positioning and characters
  expected_sequence = "\e[1;1H@X"  # Move to 1,1 print @, move to 1,2 print X
  assert_include output, expected_sequence, "Output should contain proper cursor positioning and characters"
  
  Termbox2Test.cleanup
end

assert("Termbox2 handles screen dimensions") do
  Termbox2Test.init_pty(80, 24)
  
  assert_equal 80, Termbox2.width
  assert_equal 24, Termbox2.height
  
  Termbox2Test.cleanup
end

assert("Termbox2 can set cursor position") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.set_cursor(5, 5)
  Termbox2.present
  
  output = Termbox2Test.read_output
  expected_sequence = "\e[6;6H"  # ANSI escape sequence for moving cursor to 6,6 (1-based indexing)
  assert_include output, expected_sequence, "Output should contain cursor positioning sequence"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can hide cursor") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.set_cursor(5, 5)
  Termbox2.hide_cursor
  Termbox2.present
  
  output = Termbox2Test.read_output
  expected_sequence = "\e[?25l"  # ANSI escape sequence for hiding cursor
  assert_include output, expected_sequence, "Output should contain cursor hide sequence"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can clear screen") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.print(x: 0, y: 0, character: '@')
  Termbox2.present
  Termbox2Test.read_output  # Clear the output buffer
  
  Termbox2.clear
  Termbox2.present
  
  output = Termbox2Test.read_output
  assert_false output.include?("@"), "Output should not include 'at' character"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can set cell with attributes") do
  Termbox2Test.init_pty(80, 24)
  
  # Set a cell with specific attributes
  Termbox2.set_cell(0, 0, 'A', Termbox2::Format::BOLD, Termbox2::Color::RED)
  Termbox2.present
  
  output = Termbox2Test.read_output
  # Check for: SGR reset + Bold + Red foreground + cursor position + character
  expected_sequence = "\e[m\e[1m\e[41m\e[1;1HA"
  assert_include output, expected_sequence, "Output should contain proper attributes and character"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can handle multiple cells") do
  Termbox2Test.init_pty(80, 24)
  
  # Set multiple cells with different attributes
  Termbox2.set_cell(0, 0, 'A', Termbox2::Format::BOLD, Termbox2::Color::RED)
  Termbox2.set_cell(1, 0, 'B', Termbox2::Format::UNDERLINE, Termbox2::Color::GREEN)
  Termbox2.set_cell(2, 0, 'C', Termbox2::Format::REVERSE, Termbox2::Color::BLUE)
  Termbox2.present
  
  output = Termbox2Test.read_output
  
  # ANSI escape sequence breakdown:
  # \e[m     - Reset all attributes
  # \e[1m    - Set Bold
  # \e[41m   - Set Red background
  # \e[1;1H  - Move cursor to row 1, col 1
  # A        - Print 'A'
  # \e(B     - Set ASCII character set
  # \e[m     - Reset all attributes
  # \e[4m    - Set Underline
  # \e[42m   - Set Green background
  # B        - Print 'B'
  # \e(B     - Set ASCII character set
  # \e[m     - Reset all attributes
  # \e[7m    - Set Reverse video
  # \e[44m   - Set Blue background
  # C        - Print 'C'
  expected_sequence = "\e[m\e[1m\e[41m\e[1;1HA\e(B\e[m\e[4m\e[42mB\e(B\e[m\e[7m\e[44mC"
  assert_include output, expected_sequence, "Output should contain proper attributes and characters for all cells"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can handle UTF-8 characters") do
  Termbox2Test.init_pty(80, 24)

  # Set a cell with a UTF-8 character (Japanese あ)
  Termbox2.set_cell(0, 0, 'あ', Termbox2::Format::BOLD, Termbox2::Color::WHITE)
  Termbox2.present

  output = Termbox2Test.read_output

  # ANSI escape sequence breakdown:
  # \e[m     - Reset all attributes
  # \e[1m    - Set Bold
  # \e[47m   - Set White background
  # \e[1;1H  - Move cursor to row 1, col 1
  # あ       - Print UTF-8 character
  expected_sequence = "\e[m\e[1m\e[47m\e[1;1Hあ"
  assert_include output, expected_sequence, "Output should contain proper UTF-8 character with attributes"

  Termbox2Test.cleanup
end
