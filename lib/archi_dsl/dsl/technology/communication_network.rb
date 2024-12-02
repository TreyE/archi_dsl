module ArchiDsl
  module Dsl
    module Technology
      class CommunicationNetwork < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "CommunicationNetwork"
        end
      end
    end
  end
end