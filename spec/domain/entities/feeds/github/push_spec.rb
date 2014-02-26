require 'domain/entities/spec_helper'

describe Entities::Github::Push do
end

#   describe "#build" do
#     it "instances new Github Push entity " do
#       p = build_push(); p.determine.group.normalize.persist!

#       # check push
#       expect(p.instance.title).to be_a(String)
#       expect(p.instance.url).to be_a(String)
#       expect(p.instance.props['repo_name']).to be_a(String)
#       expect(p.instance.props['commit_shas']).not_to be_empty
#       #expect(p.instance.props['origin_id']).not_to be_empty

#       # procure commits
#       expect(Entity.where(:parent_id => p.instance.id).count).to eq(2)
#     end
#   end
