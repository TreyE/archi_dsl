module ArchiDsl
  module Dsl
    module Physical
      class Equipment < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Equipment"
        end
      end
    end
  end
end