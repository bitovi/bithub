collection @events
attributes :id, :title, :body
attributes :author, :if => lambda {|e| @qs[:includes].include? 'author' } 

child :children, :if => lambda {|e| @qs[:includes].include? 'children' } do
  attributes :id, :title, :body
end

child :activities, :if => lambda {|e| @qs[:includes].include? 'children' } do
  attributes :id, :value
end

node :tags do |event|
  event.tags.map {|tag| tag.to_s }
end
