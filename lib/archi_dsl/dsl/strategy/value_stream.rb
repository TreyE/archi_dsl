module ArchiDsl
  module Dsl
    module Strategy
      class ValueStream < ModelElement
        def base_folder
          Organizations::STRATEGY_BASE
        end

        def xsi_type
          "ValueStream"
        end
      end
    end
  end
end