require "graphviz"

module ArchiDsl
  module View
    class DotInterpreter < ::Dot2Ruby #:nodoc:
      include ::GraphViz::Utils

      def initialize( xGVPath, xOutFile, xOutFormat = nil ) #:nodoc:
        paths = (xGVPath.nil?) ? [] : [xGVPath]
        @xGvprPath = find_executable( 'gvpr', paths )
        if(@xGvprPath.nil?)
          raise Exception, "GraphViz is not installed. Please be sure that 'gvpr' is on the search path'"
        end
        @xOutFile = xOutFile
        @xOutFormat = xOutFormat || "_"
        @gvprScript = File.join(
          File.expand_path(File.dirname(__FILE__)),
          "dot2rubyfix.g"
        )
      end

      def self.parse( xFile, hOpts = {}, &block )
        graph = DotInterpreter::new( hOpts[:path], nil, nil ).eval( xFile )
        yield( graph ) if( block and graph )
        return graph
      end
    end
  end
end