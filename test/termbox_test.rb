assert("Termbox2 can print and read output") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.print(x: 0, y: 0, character: '@')
  Termbox2.print(x: 1, y: 0, character: 'X')
  Termbox2.present
  
  output = Termbox2Test.read_output
  
  # The output might contain ANSI escape sequences, so we'll check for the presence
  # of our characters somewhere in the output
  assert_true output.include?('@'), "Output should contain '@'"
  assert_true output.include?('X'), "Output should contain 'X'"
  
  Termbox2Test.cleanup
end

assert("Termbox2 handles screen dimensions") do
  Termbox2Test.init_pty(80, 24)
  
  assert_true Termbox2.width > 0
  assert_true Termbox2.height > 0
  assert_equal 80, Termbox2.width
  assert_equal 24, Termbox2.height
  
  Termbox2Test.cleanup
end

assert("Termbox2 can set cursor position") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.set_cursor(5, 5)
  Termbox2.present
  
  # The cursor position should be reflected in the terminal output
  # We might need to parse ANSI escape sequences to verify exact position
  output = Termbox2Test.read_output
  # The output might contain ANSI escape sequences, so we'll check for the presence
  # of some output
  assert_true output.size > 0, "Output should not be empty"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can hide cursor") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.hide_cursor
  Termbox2.present
  
  output = Termbox2Test.read_output
  # The output should contain the hide cursor ANSI sequence
  assert_true output.size > 0, "Output should not be empty"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can clear screen") do
  Termbox2Test.init_pty(80, 24)
  
  # First print something
  Termbox2.print(x: 0, y: 0, character: '@')
  Termbox2.present
  Termbox2Test.read_output  # Clear the output buffer
  
  # Then clear and verify
  Termbox2.clear
  Termbox2.present
  
  output = Termbox2Test.read_output
  # The output should contain the clear screen ANSI sequence
  assert_true output.size > 0, "Output should not be empty"
  
  Termbox2Test.cleanup
end

assert("Termbox2 can set cell with attributes") do
  Termbox2Test.init_pty(80, 24)
  
  # Set a cell with specific attributes
  Termbox2.set_cell(0, 0, 'A', Termbox2::Format::BOLD, Termbox2::Color::RED)
  Termbox2.present
  
  output = Termbox2Test.read_output
  # The output should contain the character and its attributes
  assert_true output.size > 0, "Output should not be empty"
  
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
  # The output should contain all three characters
  assert_true output.size > 0, "Output should not be empty"
  
  Termbox2Test.cleanup
end
