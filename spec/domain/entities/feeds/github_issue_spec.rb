# issue_def = {
#   number: "100",
#   issue_id: "1001"
# }
# issue_def2 = {
#   number: "200",
#   issue_id: "2001",
#   body: "referencing issue #100 ...",
#   referenced_issue_numbers: ['100']
# }
# issue_comment_def = {
#   number: "100",
#   comment_id: "1002"
# }
# issue_comment_def2 = {
#   number: "100",
#   comment_id: "1003"
# }
# issue_comment_def3 = {
#   number: "200",
#   comment_id: "1004",
#   body: "referencing issue #100 ...",
#   referenced_issue_numbers: ['100']
# }

# describe Entities::Github::Issue do
#   describe "#build" do
#     it "instances new Github::Issue entity" do
#       i = build_issue(); i.determine.normalize.persist!

#       expect(i.instance.title).to be_a(String)
#       expect(i.instance.body).to be_a(String)
#       expect(i.instance.url).to be_a(String)
#       expect(i.instance.feed_name).to eq('github')
#       expect(i.instance.type_name).to eq('issue')
#       expect(i.instance.props['repo_name']).to be_a(String)
#       expect(i.instance.props['number']).not_to be_empty
#       #expect(i.instance.props['origin_id']).not_to be_empty
#       expect(i.instance.props['label_names']).to be_a(String)
#       expect(i.instance.props['state']).to be_a(String)
#     end
#   end

#   describe "children finding/building" do
#     it "checks for children" do
#       ic = build_issue_comment(issue_comment_def)   ; ic.determine.group.normalize.persist!
#       i = build_issue(issue_def)                    ; i.determine.group.normalize.persist!
#       ic2 = build_issue_comment(issue_comment_def2) ; ic2.determine.group.normalize.persist!
#       i2 = build_issue(issue_def2)                  ; i2.determine.group.normalize.persist!

#       expect(i.find_children.length).to eq(2)
#       expect(i2.find_children.length).to eq(0)
#     end
#   end

#   describe "reference building" do
#     it "checks for entities contain references to exact issue" do
#       i = build_issue(issue_def)                    ; i.determine.group.normalize.persist!
#       i2 = build_issue(issue_def2)                  ; i2.determine.group.normalize.persist!
#       ic3 = build_issue_comment(issue_comment_def3) ; ic3.determine.group.normalize.persist!
#       p = build_push()                              ; p.determine.group.normalize.persist!

#       expect(i.instance.referenced_from.length).to eq(5)
#       expect(i2.instance.referenced_from.length).to eq(2)
#     end
#   end
# end

# describe Entities::Github::IssueComment do
#   describe "#build" do
#     it "builds a new Github::IssueComment entity" do
#       ic = build_issue_comment(); ic.determine.normalize.persist!

#       expect(ic.instance.title).to be_a(String)
#       expect(ic.instance.body).to be_a(String)
#       expect(ic.instance.url).to be_a(String)
#       expect(ic.instance.feed_name).to eq('github')
#       expect(ic.instance.type_name).to eq('issue_comment')
#       expect(ic.instance.props['repo_name']).to be_a(String)
#       expect(ic.instance.props['number']).not_to be_empty
#       #expect(ic.instance.props['origin_id']).not_to be_empty
#     end
#   end

#   describe "parent finding/building" do
#     it "checks for the parent issue" do
#       ic = build_issue_comment(issue_comment_def)   ; ic.determine.group.normalize.persist!
#       i = build_issue(issue_def)                    ; i.determine.group.normalize.persist!
#       ic2 = build_issue_comment(issue_comment_def2) ; ic2.determine.group.normalize.persist!
#       i2 = build_issue(issue_def2)                  ; i2.determine.group.normalize.persist!

#       expect(ic.find_parent.id).to eq(i.instance.id)
#       expect(ic2.find_parent.id).to eq(i.instance.id)
#     end
#   end
# end

# describe Entities::Github::PullRequest do
#   describe "#build" do
#     it "instances new Github::PullRequest entity" do
#       pr = build_pull_req(); pr.determine.normalize.persist!

#       expect(pr.instance.title).to be_a(String)
#       expect(pr.instance.body).to be_a(String)
#       expect(pr.instance.url).to be_a(String)
#       expect(pr.instance.feed_name).to eq('github')
#       expect(pr.instance.type_name).to eq('pull_request')
#       expect(pr.instance.props['repo_name']).to be_a(String)
#       expect(pr.instance.props['number']).not_to be_empty
#       #expect(pr.instance.props['origin_id']).not_to be_empty
#       expect(pr.instance.props['state']).to be_a(String)
#       #expect(pr.instance.props['action']).to be_a(String)
#     end
#   end
# end

# describe Entities::Github::PullRequest
# # PullRequestComment behaves the same as IssueComment
