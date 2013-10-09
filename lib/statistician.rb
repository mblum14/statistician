require 'ostruct'

module Statistician
  class Reporter
    attr_accessor :agents, :unmatched

    def initialize *agents
      @agents = agents
      @unmatched = []
    end

    def parse file
      file.each_line do |line|
        line.strip!
        @agents.find { |agent| agent.match(line) } or @unmatched << line
      end
    end
  end

  class Rule
    attr_reader   :result, :fields, :regexp, :name

    def initialize regexp_spec, name='Rule 0'
      @name   = name
      @regexp = Regexp.new translate(regexp_spec)
      @fields = @regexp.names
    end

    def parse text
      "#{name}: #{text.match(regexp).captures.reject(&:nil?).join(', ')}"
    end

    def match text
      @result = if md = @regexp.match(text)
        Hash[*@fields.zip(md.captures).flatten]
      end
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

  class Reportable < OpenStruct
    class << self
      attr_reader :records

      def inherited klass
        klass.class_eval do
          @rules, @records = [], []
        end
        super
      end

      def rule pattern
        @rules << Rule.new(pattern)
      end

      def match text
        if rule = @rules.find { |rule| rule.match(text) }
          @records << self.new(rule.result)
        end
      end
    end
  end
end
