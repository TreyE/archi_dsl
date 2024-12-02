require "nokogiri"

require "securerandom"
require_relative "archi_dsl/organizations"
require_relative "archi_dsl/view"
require_relative "archi_dsl/dsl"

module ArchiDsl
  def model(name, id = "model-" + SecureRandom.uuid, &blk)
    ArchiDsl::Dsl::Model.new(name, id, &blk)
  end

  module_function :model
end
