module ArchiDsl
  module Dsl
    module Strategy
      class Resource < ModelElement
        def base_folder
          Organizations::STRATEGY_BASE
        end

        def xsi_type
          "Resource"
        end
      end
    end
  end
end