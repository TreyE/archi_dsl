module ArchiDsl
  module Dsl
    module Application
      class DataObject < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "DataObject"
        end
      end
    end
  end
end