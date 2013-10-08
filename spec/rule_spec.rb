require 'spec_helper'
require File.join(File.dirname(__FILE__), '../lib', 'statistician')

describe Statistician::Rule do
  #[The ]<name> wounds you[ with <attack>] for <amount> point[s] of <kind>[ damage].

  describe "initialization" do
    it "initializes with optional regexp text" do
      rule = Statistician::Rule.new('[The ]')
      expect(rule.regexp).to eql(/(?:The )?/)
    end

    it "initializes with named capture group regexp" do
      rule = Statistician::Rule.new('<name>')
      expect(rule.regexp).to eql(/(?<name>.+?)/)
    end

    it "initializes an optional capture group" do
      rule = Statistician::Rule.new('[ with <attack>]')
      expect(rule.regexp).to eql(/(?: with (?<attack>.+?))?/)
    end

    it "can interpret a complex rules" do
      rule = Statistician::Rule.new('[The ]<name> wounds you[ with <attack>] for <amount> point[s] of <kind>[ damage].')
      solution = /(?:The )?(?<name>.+?) wounds you(?: with (?<attack>.+?))? for (?<amount>.+?) point(?:s)? of (?<kind>.+?)(?: damage)?\./
      expect(rule.regexp).to eql(solution)
      rule = Statistician::Rule.new('You wound[ the] <name>[ with <attack>] for <amount> point[s] of <kind>[ damage].')
      solution = /You wound(?: the)? (?<name>.+?)(?: with (?<attack>.+?))? for (?<amount>.+?) point(?:s)? of (?<kind>.+?)(?: damage)?\./
      expect(rule.regexp).to eql(solution)
    end
  end

  describe "#parse" do
    let(:rule) { Statistician::Rule.new('[The ]<name> wounds you[ with <attack>] for <amount> point[s] of <kind>[ damage].') }
    subject{ rule }

    it "should output the values of the capture groups" do
      data = "C++ wounds you with Compiled Code for 37 points of Speed damage."
      expect(rule.parse(data)).to eql('Rule 0: C++, Compiled Code, 37, Speed')
    end

    it "ignores failed capture groups" do
      data = "C++ wounds you for 37 points of Speed damage."
      expect(rule.parse(data)).to eql('Rule 0: C++, 37, Speed')
    end
  end

  describe "#match?" do
    let(:rule) { Statistician::Rule.new('[The ]<name> wounds you[ with <attack>] for <amount> point[s] of <kind>[ damage].') }
    subject{ rule }
    it "should not match" do
      data = 'will not match'
      expect(rule.match?(data)).to be_false
    end

    it "should match" do
      data = "C++ wounds you with Compiled Code for 37 points of Speed damage."
      expect(rule.match?(data)).to be_true
    end
  end
end
