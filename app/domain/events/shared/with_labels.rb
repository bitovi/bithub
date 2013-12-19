module Events
  module Github
    module WithLabels

      def labels(original_hash)
        original_hash['payload']['issue']['labels']
      end

      def label_names(labels)
        labels.map {|l| l['name'] }.join(',')
      end

    end
  end
end
