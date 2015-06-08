#!/usr/bin/env ruby

require './console.rb'
require './sound_gen.rb'
include Console

console_defaults = `stty -g`

at_exit do
  system "stty #{console_defaults}"
end

begin
  print "Press Ctrl-C when done \n"
  print "Press and hold <space> for a short time to take dot ('.') \n and \nfor a long time to take dash ('-') \n"

  system("stty raw -echo isig -icanon")

  char_seq = []

  loop do
    delay

    if $stdin.ready?
      c = $stdin.getc
    end

    char_seq = store(c, char_seq)

    print "\r#{encode(char_seq)}"
  end
rescue Interrupt
  system "stty -raw echo"

  SoundGen.main(encode(char_seq))
  print "\nWritten to `morse-sound-*.wav` \n"

  exit
end
