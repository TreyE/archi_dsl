module ArchiDsl
  module Dsl
    module Other
      class OrJunction < ModelElement
        def base_folder
          Organizations::OTHER_BASE
        end

        def name
          ""
        end

        def fixed_size?
          true
        end

        def xsi_type
          "OrJunction"
        end
      end
    end
  end
end
