require 'rails_helper'
require 'entities/entities'

describe Entities::FeedDeterminator do

  describe "#feed_module" do
    it "responds with a proper feed module" do
      raw = raw_data(response_path: 'twitter/status_event.json')
      tweet_event = Events::Twitter::TweetEvent.new(raw)
      
      raw = raw_data(response_path: 'github/events/issues_event.json')
      github_issue_event = Events::Github::IssueEvent.new(raw)

      expect(
        Entities::FeedDeterminator\
        .new(tweet_event)
        .feed_module
      ).to eq(Entities::Twitter)

      expect(
        Entities::FeedDeterminator\
        .new(github_issue_event)
        .feed_module
      ).to eq(Entities::Github)
    end
  end
end

describe Entities::TypeDeterminator do
  describe '#type_class' do
    context 'given a namespace and a type_name' do
      it 'finds the type_class in the provided namespace' do
        event = Events::Rss::PostEvent.new({ source_data: {}, meta: {} })

        expect(
          Entities::TypeDeterminator\
          .new(event)
          .type_class({ namespace: Entities::Rss, type_name: :Post })
        ).to eq(Entities::Rss::Post)
      end
    end

    context 'given a block' do
      it 'allows the provided block do the finding' do
        event = Events::Rss::PostEvent.new({ source_data: {}, meta: {} })
        type_name = :Post

        expect(
          Entities::TypeDeterminator.new(event).type_class do
            if Entities::Rss.constants.include?(type_name)
              Entities::Rss.const_get(type_name)
            end
          end
        ).to eq(Entities::Rss::Post)
      end
    end

    it 'fails if it is unable to find the appropriate type_class' do
      rss_event = Events::Rss::PostEvent.new({ source_data: { }, meta: { } })
      expect do
        Entities::TypeDeterminator\
        .new(rss_event)
        .type_class({ namespace: Entities::Rss, type_name: :Wat })
      end.to raise_error(Entities::DeterminationError)
    end
  end
end

describe Entities::Disqus::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Disqus::Post class' do
      expect(
        Entities::Disqus::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Entities::Disqus::Post)
    end
  end
end

describe Entities::Facebook::TypeDeterminator do
  describe '#type_class' do
    it 'plucks the type_name from the event\'s type_name and returns a type_class' do
      raw = raw_data(response_path: 'facebook/feed.json')[4]
      event = Events::Facebook::StatusEvent.new(raw)
      
      expect(
        Entities::Facebook::TypeDeterminator\
        .new(event).type_class
      ).to eq(Entities::Facebook::Status)
    end
  end
  
  describe '#type_name' do
    it 'plucks the type_name from the event\'s source_data' do
      raw = raw_data(response_path: 'facebook/feed.json')[4]
      event = Events::Facebook::StatusEvent.new(raw)

      expect(
        Entities::Facebook::TypeDeterminator\
        .new(event).type_name
      ).to eq(:Status)
    end
  end
end

describe Entities::Foursquare::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Foursquare::Checkin class' do
      raw = CGI.parse(File.read('spec/support/responses/foursquare/checkin_postback'))
      event = Events::Foursquare::CheckinEvent.new(raw.merge({'venue' => {}}))

      expect(
        Entities::Foursquare::TypeDeterminator\
        .new(raw).type_class
      ).to eq(Entities::Foursquare::Checkin)
    end
  end
end

describe Entities::Github::TypeDeterminator do

  describe '#type_class' do
    it 'finds the type_class based on the type_name'
  end

  describe '#type_name' do
    context "specifically an Issue from Issues API endpoint" do
      it "responds with PullRequest entity" do
        raw = raw_data(response_path: 'github/issues/issues.json').first
        event = Events::Github::CustomIssueEvent.new(raw)

        expect(
          Entities::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Entities::Github::Issue)
      end
    end

    context "specifically a PullRequestEvent" do
      it "responds with PullRequest entity" do
        raw = raw_data(response_path: 'github/events/issues_event.json')
        event = Events::Github::PullRequestEvent.new(raw)
        
        expect(
          Entities::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Entities::Github::PullRequest)
      end

      context "with action != opened" do
        it "responds with IssueAction entity if action != opened" do
          raw = raw_data(response_path: 'github/events/issues_event.json')
          raw['payload']['action'] = 'reopened'
          event = Events::Github::PullRequestEvent.new(raw)

          expect(
            Entities::Github::TypeDeterminator\
            .new(event)
            .type_class
          ).to eq(Entities::Github::IssueAction)
        end
      end
    end

    context "specifically an IssueEvent" do
      it "responds with Issue entity" do
        raw = raw_data(response_path: 'github/events/pull_request_event.json')
        event = Events::Github::IssueEvent.new(raw)

        expect(
          Entities::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Entities::Github::Issue)
      end

      context "action != opened" do
        it "responds with IssueAction entity if action != opened" do
          raw = raw_data(response_path: 'github/events/pull_request_event.json')
          raw['payload']['action'] = 'closed'
          event = Events::Github::IssueEvent.new(raw)

          expect(
            Entities::Github::TypeDeterminator\
            .new(event)
            .type_class
          ).to eq(Entities::Github::IssueAction) 
        end
      end
    end

  end
end

describe Entities::Instagram::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Instagram::Media class' do
      expect(
        Entities::Instagram::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Entities::Instagram::Media)
    end
  end
end

describe Entities::Meetup::TypeDeterminator do
  describe '#type_class' do
    it 'remaps the event_type and returns the type_class' do
      event = Events::Meetup::EventEvent.new({ source_data: {}, meta: {} })

      expect(
        Entities::Meetup::TypeDeterminator\
        .new(event)
        .type_class
      ).to eq(Entities::Meetup::Event)
    end
  end
end

describe Entities::Rss::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Rss::Post class' do
      expect(
        Entities::Rss::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Entities::Rss::Post)
    end
  end
end

describe Entities::Stackexchange::TypeDeterminator do
  describe '#type_class' do
    it 'remapps the event type and gets the appropriate class' do
      raw = raw_data(response_path: 'stackexchange/question.json')
      event = Events::Stackexchange::QuestionEvent.new(raw)

      expect(
        Entities::Stackexchange::TypeDeterminator\
        .new(event).type_class
      ).to eq(Entities::Stackexchange::Question)
    end
  end
end

describe Entities::Tumblr::TypeDeterminator do
  describe '#type_class' do
    it 'finds the type_class based on the type_name' do
      raw = raw_data(response_path: 'tumblr/blog.json')['response']['posts'][0]
      event = Events::Tumblr::PostEvent.new(raw)

      expect(
        Entities::Tumblr::TypeDeterminator\
        .new(event).type_class
      ).to eq(Entities::Tumblr::Text)
    end
  end

  describe '#type_name' do
    it 'plucks the type name from the source_data' do
      raw = raw_data(response_path: 'tumblr/blog.json')['response']['posts'][0]
      event = Events::Tumblr::PostEvent.new(raw)

      expect(
        Entities::Tumblr::TypeDeterminator\
        .new(event).type_name
      ).to eq(:Text)
    end
  end
end

describe Entities::Twitter::TypeDeterminator do
  describe '#type_class' do
    it 'remaps the event\'s type_name and returns a type_class' do
      fake_follow_raw = raw_data(response_path: 'twitter/fake_follow_event.json')
      fake_follow = Events::Twitter::FakeFollowEvent.new(fake_follow_raw)

      follow_raw = raw_data(response_path: 'twitter/follow_event.json')
      follow = Events::Twitter::FollowEvent.new(follow_raw)

      expect(
        Entities::Twitter::TypeDeterminator\
        .new(fake_follow).type_class
      ).to eq(Entities::Twitter::Follow)

      expect(
        Entities::Twitter::TypeDeterminator\
        .new(follow).type_class
      ).to eq(Entities::Twitter::Follow)
    end
  end
end

describe Entities::Youtube::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Youtube::Video class' do
      expect(
        Entities::Youtube::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Entities::Youtube::Video)
    end
  end
end
