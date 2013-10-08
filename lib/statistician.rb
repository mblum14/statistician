module Statistician
  class Reporter
    attr_accessor :agents, :unmatched

    def initialize *agents
      @agents = agents
      @unmatched = []
    end

    def parse file
      file.each_line do |line|
        matched = false
        agents.each do |agent|
          if agent.match? line
            agent.parse(line)
            matched = true
            break
          end
        end
        unmatched << line unless matched
        matched = false
      end
    end
  end

  class Rule
    attr_accessor :regexp, :name

    def initialize regexp_spec, name='Rule 0'
      @name   = name
      @regexp = Regexp.new translate(regexp_spec)
    end

    def parse text
      "#{name}: #{text.match(regexp).captures.reject(&:nil?).join(', ')}"
    end

    def match? text
      !!regexp.match(text)
    end

    private

    def translate regexp_spec
      optional_text_regexp = /\[(?<content>[^\]]*)\]/
      capture_group_regexp = /<(?<content>[^>]*)>/
      escapable_regexp     = /(?<content>[\.])/
      regexp_spec = regexp_spec.gsub(escapable_regexp, '\\.')
      regexp_spec = regexp_spec.gsub(optional_text_regexp, '(?:\k<content>)?')
      regexp_spec = regexp_spec.gsub(capture_group_regexp, '(?<\k<content>>.+?)')
    end
  end

  class Reportable
    def self.inherited(base)
      base.class_eval do
        @rules = []
        @records = []

        def self.parse line
          rules.each do |rule|
            @records << self.new(rule, line) if rule.match?(line)
          end
        end

        def self.rule rule
          @rules << Rule.new(rule)
        end

        def self.rules
          @rules
        end

        def self.records
          @records
        end

        def self.match? text
          matched = false
          rules.each do |rule|
            if rule.match?(text)
              matched = true
              break
            end
          end
          matched
        end

      end
    end

    def initialize rule, line
      @record = rule.parse(line)
      methods = [rule.regexp.names, rule.regexp.match(line).captures].transpose
      methods.each do |method_name, value|
        value ||= ''
        define_singleton_method method_name, lambda { value }
      end
    end
  end
end
