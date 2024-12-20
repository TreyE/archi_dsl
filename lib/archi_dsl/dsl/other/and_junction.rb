module ArchiDsl
  module Dsl
    module Other
      class AndJunction < ModelElement
        def base_folder
          Organizations::OTHER_BASE
        end

        def fixed_size?
          true
        end

        def xsi_type
          "AndJunction"
        end
      end
    end
  end
end
