require 'minitest/reporters'
Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)
require 'minitest/autorun'

require_relative '../lib/gerablog'
