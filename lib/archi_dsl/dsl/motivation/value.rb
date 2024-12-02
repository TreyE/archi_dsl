module ArchiDsl
  module Dsl
    module Motivation
      class Value < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Value"
        end
      end
    end
  end
end