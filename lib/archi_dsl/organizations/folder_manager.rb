module ArchiDsl
  module Organizations
    class FolderManager
      def initialize(elements, associations, diagrams)
        @elements = elements
        @diagrams = diagrams
        @viewable_elements = elements.reject(&:view_only?)
        @associations = associations
        @folders = organize_folders
      end

      def to_xml(model_node)
        if @folders.any?
          model_node["archimate"].organizations do |org_node|
            @folders.each do |folder|
              folder.to_xml(org_node)
            end
          end
        end
      end

      private

      def organize_folders
        all_elements_and_names = (@viewable_elements + @associations + @diagrams).map do |ele|
          [ele.folder_name.split("/"), ele]
        end

        roots_lookup = Hash.new do |h, k|
          h[k] = Folder.new(k)
        end
        
        all_elements_and_names.each do |e_and_n|
          paths, ele = e_and_n
          folder = roots_lookup
          paths.each do |path|
            folder = folder[path]
          end
          folder.add_element(ele)
        end

        roots_lookup.values.sort_by(&:label)
      end
    end
  end
end