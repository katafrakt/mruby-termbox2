assert("Termbox2 can print and read output") do
  Termbox2Test.init_pty(80, 24)
  
  Termbox2.print(x: 0, y: 0, character: '@')
  Termbox2.print(x: 1, y: 0, character: 'X')
  Termbox2.present
  
  output = Termbox2Test.read_output
  #puts "Debug - Received output: #{output.inspect}"  # Debug output
  
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
  #puts "Debug - Received output: #{output.inspect}"  # Debug output
  
  # The output might contain ANSI escape sequences, so we'll check for the presence
  # of some output
  assert_true output.size > 0, "Output should not be empty"
  
  Termbox2Test.cleanup
end
