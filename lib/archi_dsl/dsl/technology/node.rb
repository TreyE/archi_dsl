module ArchiDsl
  module Dsl
    module Technology
      class Node < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Node"
        end
      end
    end
  end
end