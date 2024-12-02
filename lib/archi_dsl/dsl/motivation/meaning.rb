module ArchiDsl
  module Dsl
    module Motivation
      class Meaning < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Meaning"
        end
      end
    end
  end
end