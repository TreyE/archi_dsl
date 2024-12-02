module ArchiDsl
  module Dsl
    module ElementMethods

      MODEL_ELEMENT_SET = [
        [:business_actor, "Business::BusinessActor"],
        [:business_role, "Business::BusinessRole"],
        [:business_collaboration, "Business::BusinessCollaboration"],
        [:business_interface, "Business::BusinessInterface"],
        [:business_process, "Business::BusinessProcess"],
        [:business_function, "Business::BusinessFunction"],
        [:business_interaction, "Business::BusinessInteraction"],
        [:business_event, "Business::BusinessEvent"],
        [:business_service, "Business::BusinessService"],
        [:business_object, "Business::BusinessObject"],
        [:contract, "Business::Contract"],
        [:representation, "Business::Representation"],
        [:product, "Business::Product"],
        [:application_component, "Application::ApplicationComponent"],
        [:application_collaboration, "Application::ApplicationCollaboration"],
        [:application_interface, "Application::ApplicationInterface"],
        [:application_function, "Application::ApplicationFunction"],
        [:application_interaction, "Application::ApplicationInteraction"],
        [:application_process, "Application::ApplicationProcess"],
        [:application_event, "Application::ApplicationEvent"],
        [:application_service, "Application::ApplicationService"],
        [:data_object, "Application::DataObject"],
        [:deliverable, "Implementation::Deliverable"],
        [:gap, "Implementation::Gap"],
        [:implementation_event, "Implementation::ImplementationEvent"],
        [:plateau, "Implementation::Plateau"],
        [:work_package, "Implementation::WorkPackage"],
        [:assessment, "Motivation::Assessment"],
        [:constraint, "Motivation::Constraint"],
        [:driver, "Motivation::Driver"],
        [:goal, "Motivation::Goal"],
        [:meaning, "Motivation::Meaning"],
        [:outcome, "Motivation::Outcome"],
        [:principle, "Motivation::Principle"],
        [:requirement, "Motivation::Requirement"],
        [:stakeholder, "Motivation::Stakeholder"],
        [:value, "Motivation::Value"],
        [:and_junction, "Other::AndJunction"],
        [:or_junction, "Other::OrJunction"],
        [:distribution_network, "Physical::DistributionNetwork"],
        [:equipment, "Physical::Equipment"],
        [:facility, "Physical::Facility"],
        [:material, "Physical::Material"],
        [:capability, "Strategy::Capability"],
        [:course_of_action, "Strategy::CourseOfAction"],
        [:resource, "Strategy::Resource"],
        [:value_stream, "Strategy::ValueStream"],
        [:communication_network, "Technology::CommunicationNetwork"],
        [:device, "Technology::Device"],
        [:node, "Technology::Node"],
        [:path, "Technology::Path"],
        [:artifact, "Technology::Artifact"],
        [:technology_collaboration, "Technology::TechnologyCollaboration"],
        [:technology_event, "Technology::TechnologyEvent"],
        [:technology_function, "Technology::TechnologyFunction"],
        [:technology_interaction, "Technology::TechnologyInteraction"],
        [:technology_interface, "Technology::TechnologyInterface"]
      ].freeze

      PARENTING_ELEMENT_SETS = [
        [:grouping, "Grouping"],
        [:location, "Location"],
        [:system_software, "SystemSoftware"],
        [:technology_process, "TechnologyProcess"],
        [:technology_service, "TechnologyService"]
      ].freeze

      def self.define_model_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def self.define_parent_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      MODEL_ELEMENT_SET.each do |pe_item|
        define_model_element_method(pe_item[0], pe_item[1])
      end

      PARENTING_ELEMENT_SETS.each do |pe_item|
        define_parent_element_method(pe_item[0], pe_item[1])
      end
    end
  end
end