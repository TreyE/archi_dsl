module ArchiDsl
  module Dsl
    module ElementMethods
      def self.define_real_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = RealElement.new(@association_registry, "#{ele_kind}", element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      REAL_ELEMENT_SET = [
        [:business_actor, "BusinessActor"],
        [:business_role, "BusinessRole"],
        [:business_collaboration, "BusinessCollaboration"],
        [:business_interface, "BusinessInterface"],
        [:business_process, "BusinessProcess"],
        [:business_function, "BusinessFunction"],
        [:business_interaction, "BusinessInteraction"],
        [:business_event, "BusinessEvent"],
        [:business_service, "BusinessService"],
        [:business_object, "BusinessObject"],
        [:contract, "Contract"],
        [:representation, "Representation"],
        [:product, "Product"],
        [:application_component, "ApplicationComponent"],
        [:application_collaboration, "ApplicationCollaboration"],
        [:application_interface, "ApplicationInterface"],
        [:application_function, "ApplicationFunction"],
        [:application_interaction, "ApplicationInteraction"],
        [:application_process, "ApplicationProcess"],
        [:application_event, "ApplicationEvent"],
        [:application_service, "ApplicationService"],
        [:data_object, "DataObject"],
        [:node, "Node"],
        [:device, "Device"],
        [:system_software, "SystemSoftware"],
        [:technology_collaboration, "TechnologyCollaboration"],
        [:technology_interface, "TechnologyInterface"],
        [:path, "Path"],
        [:communication_network, "CommunicationNetwork"],
        [:technology_function, "TechnologyFunction"],
        [:technology_process, "TechnologyProcess"],
        [:technology_interaction, "TechnologyInteraction"],
        [:technology_event, "TechnologyEvent"],
        [:technology_service, "TechnologyService"],
        [:artifact, "Artifact"],
        [:equipment, "Equipment"],
        [:facility, "Facility"],
        [:distribution_network, "DistributionNetwork"],
        [:material, "material"],
        [:stakeholder, "Stakeholder"],
        [:driver, "Driver"],
        [:assessment, "Assessment"],
        [:goal, "Goal"],
        [:outcome, "Outcome"],
        [:principle, "Principle"],
        [:requirement, "Requirement"],
        [:constraint, "Constraint"],
        [:meaning, "Meaning"],
        [:value, "Value"],
        [:resource, "Resource"],
        [:capability, "Capability"],
        [:course_of_action, "CourseOfAction"],
        [:value_stream, "ValueStream"],
        [:work_package, "WorkPackage"],
        [:deliverable, "Deliverable"],
        [:implementation_event, "ImplementationEvent"],
        [:plateau, "Plateau"],
        [:gap, "Gap"],
        [:location, "Location"],
        [:and_junction, "AndJunction"],
        [:or_junction, "OrJunction"]
      ].freeze

      REAL_ELEMENT_SET.each do |re_item|
        define_real_element_method(re_item[0], re_item[1])
      end

      def group(element_name, element_id = "g-" + SecureRandom.uuid, &blk)
        ele = Group.new(@association_registry, @element_lookup, element_name, element_id, &blk)
        @element_lookup.add_element(ele)
        @children << ele
        ele
      end
    end
  end
end