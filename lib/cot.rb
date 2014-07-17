require 'active_model'

require 'cot/version'
require 'cot/frame'
require 'json'

module Cot
  def version_string
    "Cot version #{Cot::VERSION}"
  end
end
