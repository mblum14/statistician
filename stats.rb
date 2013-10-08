require 'bundler'
Bundler.require

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

loop do
  case ARGV[0]
  when '-r' then ARGV.shift; rule_filename = ARGV.shift
  when '-d' then ARGV.shift; data_filename  = ARGV.shift
  when /^-/ then  usage("Unknown option: #{ARGV[0].inspect}")
  else break
  end
end

if File.exists? rule_filename
  rules = File.open(rule_filename)
else
  error_text rule_filename
end

if File.exists? data_filename
  data = File.open(data_filename)
else
  error_text data_filename
end
