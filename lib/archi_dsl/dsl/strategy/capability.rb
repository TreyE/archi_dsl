module ArchiDsl
  module Dsl
    module Strategy
      class Capability < ModelElement
        def base_folder
          Organizations::STRATEGY_BASE
        end

        def xsi_type
          "Capability"
        end
      end
    end
  end
end