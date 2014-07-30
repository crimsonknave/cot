require 'active_model'

require 'cot/version'
require 'cot/frame'
require 'cot/collection'
require 'json'

module Cot
  def version_string
    "Cot version #{Cot::VERSION}"
  end
end
