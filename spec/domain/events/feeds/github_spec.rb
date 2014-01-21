describe Events::Payload do

  shared_examples_for "every github event" do
    it_should_behave_like "every event"

    it "has common github event attributes" do
      expect(payload.origin_id).to be_a(String)
      expect(payload.origin_event_id).to be_a(String)
      expect(payload.actor).to be_a(Hash)
      expect(payload.repo).to be_a(Hash)
      expect(payload.repo_name).to be_a(String)
      expect(payload.origin_author_name).to be_a(String)
      expect(payload.origin_author_id).to be_a(Integer)
      expect(payload.origin_author_gravatar).to be_a(String)
      expect(payload.origin_ts).to be_a(Time)
    end
  end

  shared_examples_for "every github comment event" do
    it "has common github comment event attributes" do
      expect(payload.comment).to be_a(Hash)
      expect(payload.body).to be_a(String)
      expect(payload.html_url).to be_a(String)      
    end
  end

  shared_examples_for "every github event with refs" do
    it "has refs attributes" do
      expect(payload.ref_type).to be_a(String)
      expect(payload.ref).to be_a(String)
    end
  end

  shared_examples_for "every github event with labels" do
    it "has lablel attributes" do
      expect(payload.labels).to be_a(Array)
      expect(payload.label_names).to be_a(String)
    end
  end

  shared_examples_for "every github issues or pull requests event" do
    it "has refs attributes" do
      expect(payload.title).to be_a(String)
      expect(payload.body).to be_a(String)
      expect(payload.html_url).to be_a(String)
      expect(payload.number).to be_a(Integer)
      expect(payload.state).to be_a(String)
      expect(payload.action).to be_a(String)
    end
  end
  
  describe "#initialize" do
    context "Github" do

      context "CommitCommentEvent" do
        let(:payload) {
          build_payload('github','commit_comment_event', {response_path: 'github/events/commit_comment_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github comment event"
        
        it "creates Payload object with mapping methods" do
          expect(payload.commit_id).to be_a(String)
        end        
      end

      context "CreateEvent" do
        let(:payload) {
          build_payload('github','create_event', {response_path: 'github/events/create_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github event with refs"
        #it "creates Payload object with mapping methods"
      end

      # context "CustomIssueEvent" do
      #   let(:payload) { build_payload('github','push_event') }

      #   it_should_behave_like "every github event"
      #   it "creates Payload object with mapping methods" do
      #     expect(payload.push_id).to be_a(Integer)
      #   end        
      # end

      context "DeleteEvent" do
        let(:payload) {
          build_payload('github','delete_event', {response_path: 'github/events/delete_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github event with refs"
        # it "creates Payload object with mapping methods"
      end

      context "DownloadEvent" do
        let(:payload) {
          build_payload('github','download_event', {response_path: 'github/events/download_event.json'})
        }

        it_should_behave_like "every github event"
        it "creates Payload object with mapping methods" do
          expect(payload.name).to be_a(String)
          expect(payload.description).to be_a(String)
          expect(payload.url).to be_a(String)
        end        
      end

      context "FollowEvent" do
        let(:payload) {
          build_payload('github','follow_event', {response_path: 'github/events/follow_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

      context "ForkApplyEvent" do
        let(:payload) {
          build_payload('github','fork_apply_event', {response_path: 'github/events/fork_apply_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

      context "ForkEvent" do
        let(:payload) {
          build_payload('github','fork_event', {response_path: 'github/events/fork_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

      context "GistEvent" do
        let(:payload) {
          build_payload('github','gist_event', {response_path: 'github/events/gist_event.json'})
        }

        it_should_behave_like "every github event"
        it "creates Payload object with mapping methods" do
          expect(payload.action).to be_a(String)
          expect(payload.html_url).to be_a(String)
          expect(payload.description).to be_a(String)
        end        
      end

      context "GollumEvent" do
        let(:payload) {
          build_payload('github','gollum_event', {response_path: 'github/events/gollum_event.json'})
        }

        it_should_behave_like "every github event"
        it "creates Payload object with mapping methods" do
          expect(payload.pages).to be_a(Array)
          expect(payload.page_titles).to be_a(Array)
          expect(payload.page_urls).to be_a(Array)
        end        
      end

      context "IssueCommentEvent" do
        let(:payload) {
          build_payload('github','issue_comment_event', {response_path: 'github/events/issue_comment_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github comment event"
        it_should_behave_like "every github issues or pull requests event"
        it_should_behave_like "every github event with labels"
        #it "creates Payload object with mapping methods"
      end

      context "IssuesEvent" do
        let(:payload) {
          build_payload('github','issues_event', {response_path: 'github/events/issues_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github issues or pull requests event"
        it_should_behave_like "every github event with labels"
        #it "creates Payload object with mapping methods"
      end

      context "MemberEvent" do
        let(:payload) {
          build_payload('github','member_event', {response_path: 'github/events/member_event.json'})
        }

        it_should_behave_like "every github event"
        it "creates Payload object with mapping methods" do
          expect(payload.member_name).to be_a(String)
        end        
      end

      context "PublicEvent" do
        let(:payload) {
          build_payload('github','public_event', {response_path: 'github/events/public_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

      context "PullRequestEvent" do
        let(:payload) {
          build_payload('github','pull_request_event', {response_path: 'github/events/pull_request_event.json'})
        }

        it_should_behave_like "every github event"
        it_should_behave_like "every github issues or pull requests event"
        #it "creates Payload object with mapping methods"
      end

      ### WRONG RESPONSE IN EXAMPLE FILE
      # context "PullRequestReviewCommentEvent" do
      #   let(:payload) {
      #     build_payload('github','pull_request_review_comment_event', {response_path: 'github/events/pull_request_review_comment_event.json'})
      #   }

      #   it_should_behave_like "every github event"
      #   it_should_behave_like "every github comment event"
      #   #it "creates Payload object with mapping methods"
      # end

      context "PushEvent" do
        let(:payload) {
          build_payload('github','push_event', {response_path: 'github/events/push_event.json'})
        }

        it_should_behave_like "every github event"
        it "creates Payload object with mapping methods" do
          expect(payload.push_id).to be_a(Integer)
          expect(payload.commits).to be_a(Array)
          expect(payload.commit_shas).to be_a(Array)
          expect(payload.commit_messages).to be_a(Array)
          expect(payload.commit_shas_csv).to be_a(String)
          expect(payload.referenced_repo_name).to be_a(String)
          expect(payload.head).to be_a(String)

          # SHOULD IT RETURN JUST AN INT OR PREFIXED WITH #
          expect(payload.referenced_number).to be_a(String)
        end        
      end

      context "TeamAddEvent" do
        let(:payload) {
          build_payload('github','team_add_event', {response_path: 'github/events/team_add_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

      context "WatchEvent" do
        let(:payload) {
          build_payload('github','watch_event', {response_path: 'github/events/watch_event.json'})
        }

        it_should_behave_like "every github event"
        #it "creates Payload object with mapping methods"
      end

    end
  end
end
