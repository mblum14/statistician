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
