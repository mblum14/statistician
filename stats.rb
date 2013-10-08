require 'bundler'
Bundler.require
require File.join(File.dirname(__FILE__), 'lib', 'rule')

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

rule_filename = 'rules.txt'
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

if File.exists? rule_filename
  File.open(rule_filename).each_with_index do |line, index|
    rules << Rule.new(line, "Rule #{index}")
  end
else
  error_text rule_filename
end

if File.exists? data_filename
  File.open(data_filename).each do |line|
    matched = false
    rules.each do |rule|
      if rule.match? line
        puts rule.parse line
        matched = true
        break
      end
    end
    puts "# No Matches" unless matched
    matched = false
  end
else
  error_text data_filename
end
