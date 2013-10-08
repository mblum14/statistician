require 'bundler'
Bundler.require
require File.join(File.dirname(__FILE__), 'lib', 'statistician')

def usage message
  $stderr.puts message
  $stderr.puts("Usage: #{File.bnasename($0)}: rulset [-r <ruleset>] dataset [-d <dataset>]")
  $stderr.puts("   -r <FILE>      provide another ruleset")
  $stderr.puts("   -d <FILE>      provide another dataset")
  exit 2
end

def error_text filename
  $stderr.print "ERROR: ".red.on_black
  $stderr.print "#{filename}".yellow.on_black
  $stderr.print " does not exist!\r\n"
  exit 2
end

data_filename  = 'data.txt'
rules = []

loop do
  case ARGV[0]
  when '-r' then ARGV.shift; rule_filename = ARGV.shift
  when '-d' then ARGV.shift; data_filename  = ARGV.shift
  when /^-/ then  usage("Unknown option: #{ARGV[0].inspect}")
  else break
  end
end

class Defense < Statistician::Reportable
  rule "[The ]<name> wounds you[ with <attack>] for <amount> point[s] of <kind>[ damage]."
  rule "You are wounded for <amount> point[s] of <kind> damage."
end

class Offense < Statistician::Reportable
  rule "You wound[ the] <name>[ with <attack>] for <amount> point[s] of <kind>[ damage]."
  rule "You reflect <amount> point[s] of <kind> damage to[ the] <name>."
end

class Defeat < Statistician::Reportable
  rule "You succumb to your wounds."
end

class Victory < Statistician::Reportable
  rule "Your mighty blow defeated[ the] <name>."
end

class Healing < Statistician::Reportable
  rule "You heal <amount> points of your wounds."
  rule "<player> heals you for <amount> of wound damagepoints."
end

class Regen < Statistician::Reportable
  rule "You heal yourself for <amount> Power points."
  rule "<player> heals you for <amount> Power points."
end

class Comment < Statistician::Reportable
  rule "### <comment> ###"
end

class Ignored < Statistician::Reportable
  rule "<player> defeated[ the] <name>."
  rule "<player> has succumbed to his wounds."
  rule "You have spotted a creature attempting to move stealthily about."
  rule "You sense that a creature is nearby but hidden from your sight."
  rule "[The ]<name> incapacitated you."
end

error_text(data_filename) unless File.exists? data_filename

if __FILE__ == $0
  lotro = Statistician::Reporter.new(Defense, Offense, Defeat, Victory,
                                     Healing, Regen, Comment, Ignored)
  lotro.parse(File.read(ARGV[0]))

  num = Offense.records.size
  dmg = Offense.records.inject(0) { |sum, off| sum + Integer(off.amount.gsub(',', '_')) }
  d = Defense.records[3]

  puts <<-EOT
Number of Offense records: #{num}
Total damage inflicted: #{dmg}
Average damage per Offense: #{(100.0 * dmg / num).round / 100.0}

Defense record 3 indicates that a #{d.name} attacked me
using #{d.attack}, doing #{d.amount} points of damage.

Unmatched rules:
#{lotro.unmatched.join("\n")}

Comments:
#{Comment.records.map { |c| c.comment }.join("\n")}

  EOT
end
