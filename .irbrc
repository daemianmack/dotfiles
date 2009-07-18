require 'rubygems'
require 'irb/completion'
require 'pp'
require 'wirble'
require 'irb/ext/save-history'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"
IRB.conf[:AUTO_INDENT]=true

alias l local_variables

# Always have a hash and an array pre-defined. That way I don't have to whip up something when I'm messing around trying out Enumerable, Array or Hash methods.
HASH = {
  :color => 'orange', :colors => ['purple','silver'],
  :letter => 'V', :fruit => 'nectarine'} unless defined?(HASH)
ARRAY = HASH.keys unless defined?(ARRAY)

# History shit from http://dotfiles.org/~topfunky/.irbrc
def history_dump(how_many = 250)
  history_size = Readline::HISTORY.size

  # no lines, get out of here
  puts "No history" and return if history_size == 0

  start_index = 0

  # not enough lines, only show what we have
  if history_size <= how_many
    how_many  = history_size - 1
    end_index = how_many
  else
    end_index = history_size - 1 # -1 to adjust for array offset
    start_index = end_index - how_many 
  end

  start_index.upto(end_index) {|i| print_line i}
  nil
end
alias :h  :history_dump

# -2 because -1 is ourself
def history_do(lines = (Readline::HISTORY.size - 2))
  irb_eval lines
  nil
end 
alias :h! :history_do

# Turn auto-print off -- sometimes more convenient than appending a ;nil to noisy statements.
def chut
  IRB.conf[:PROMPT][ IRB.conf[:PROMPT_MODE]  ][:RETURN].replace('')
end
# And re-enable it.
def talk
  IRB.conf[:PROMPT][ IRB.conf[:PROMPT_MODE]  ][:RETURN].replace("=> %s\n\n\n")
end

# Quick benchmarking.
# Based on rue's irbrc => http://pastie.org/179534
def quick(repetitions=100, &block)
  require 'benchmark'
  Benchmark.bmbm do |b|
    b.report {repetitions.times &block} 
  end
  nil
end

# Monkeying with the system.
class Array
  def collapse_ranges
    # Take an array, detect any contiguous numbers, and return those
    # collapsed into ranges, in an array.
    # irb(main):0> ["90",'2','3','4','5'].collapse_ranges
    # => ["2".."5", "90"]
    return self if self.length <= 2
    self.uniq!
    self.sort! rescue nil
    temp_array, return_array = [], []
    self.each_with_index do |item, i|
      if item.respond_to?(:next)
        temp_array.push item
        if item.next != self[i + 1]
          return_array.concat 3 <= temp_array.length ?
          [temp_array.first..temp_array.last] : temp_array
          temp_array.clear
        end
      else
        return_array.concat 3 <= temp_array.length ?
        [temp_array.first..temp_array.last] : temp_array
        temp_array.clear
        return_array.push item
      end
    end
    return return_array
  end
end

class Object
  # Sort methods by default.
  alias :original_methods :methods
  def methods
    original_methods.sort
  end
  # Show only instance methods of the current instance.
  def own_methods
    (self.methods - Object.methods)
  end
end




private

wirble_opts = {
  # Don't set the prompt.
  :skip_prompt    => true,
}
Wirble.init(wirble_opts)
Wirble.colorize

