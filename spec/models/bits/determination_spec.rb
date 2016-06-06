require 'rails_helper'
require 'bits/bits'

describe Bits::FeedDeterminator do

  describe "#feed_module" do
    it "responds with a proper feed module" do
      raw = raw_data(response_path: 'twitter/status_event.json')
      tweet_event = Events::Twitter::TweetEvent.new(raw)
      
      raw = raw_data(response_path: 'github/events/issues_event.json')
      github_issue_event = Events::Github::IssueEvent.new(raw)

      expect(
        Bits::FeedDeterminator\
        .new(tweet_event)
        .feed_module
      ).to eq(Bits::Twitter)

      expect(
        Bits::FeedDeterminator\
        .new(github_issue_event)
        .feed_module
      ).to eq(Bits::Github)
    end
  end
end

describe Bits::TypeDeterminator do
  describe '#type_class' do
    context 'given a namespace and a type_name' do
      it 'finds the type_class in the provided namespace' do
        event = Events::Rss::PostEvent.new({ source_data: {}, meta: {} })

        expect(
          Bits::TypeDeterminator\
          .new(event)
          .type_class({ namespace: Bits::Rss, type_name: :Post })
        ).to eq(Bits::Rss::Post)
      end
    end

    context 'given a block' do
      it 'allows the provided block do the finding' do
        event = Events::Rss::PostEvent.new({ source_data: {}, meta: {} })
        type_name = :Post

        expect(
          Bits::TypeDeterminator.new(event).type_class do
            if Bits::Rss.constants.include?(type_name)
              Bits::Rss.const_get(type_name)
            end
          end
        ).to eq(Bits::Rss::Post)
      end
    end

    it 'fails if it is unable to find the appropriate type_class' do
      rss_event = Events::Rss::PostEvent.new({ source_data: { }, meta: { } })
      expect do
        Bits::TypeDeterminator\
        .new(rss_event)
        .type_class({ namespace: Bits::Rss, type_name: :Wat })
      end.to raise_error(Bits::DeterminationError)
    end
  end
end

describe Bits::Disqus::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Disqus::Post class' do
      expect(
        Bits::Disqus::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Bits::Disqus::Post)
    end
  end
end

describe Bits::Facebook::TypeDeterminator do
  describe '#type_class' do
    it 'plucks the type_name from the event\'s type_name and returns a type_class' do
      raw = raw_data(response_path: 'facebook/feed.json')[4]
      event = Events::Facebook::StatusEvent.new(raw)
      
      expect(
        Bits::Facebook::TypeDeterminator\
        .new(event).type_class
      ).to eq(Bits::Facebook::Status)
    end
  end
  
  describe '#type_name' do
    it 'plucks the type_name from the event\'s source_data' do
      raw = raw_data(response_path: 'facebook/feed.json')[4]
      event = Events::Facebook::StatusEvent.new(raw)

      expect(
        Bits::Facebook::TypeDeterminator\
        .new(event).type_name
      ).to eq(:Status)
    end
  end
end

describe Bits::Foursquare::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Foursquare::Checkin class' do
      raw = CGI.parse(File.read('spec/support/responses/foursquare/checkin_postback'))
      event = Events::Foursquare::CheckinEvent.new(raw.merge({'venue' => {}}))

      expect(
        Bits::Foursquare::TypeDeterminator\
        .new(raw).type_class
      ).to eq(Bits::Foursquare::Checkin)
    end
  end
end

describe Bits::Github::TypeDeterminator do

  describe '#type_class' do
    it 'finds the type_class based on the type_name'
  end

  describe '#type_name' do
    context "specifically an Issue from Issues API endpoint" do
      it "responds with PullRequest bit" do
        raw = raw_data(response_path: 'github/issues/issues.json').first
        event = Events::Github::CustomIssueEvent.new(raw)

        expect(
          Bits::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Bits::Github::Issue)
      end
    end

    context "specifically a PullRequestEvent" do
      it "responds with PullRequest bit" do
        raw = raw_data(response_path: 'github/events/issues_event.json')
        event = Events::Github::PullRequestEvent.new(raw)
        
        expect(
          Bits::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Bits::Github::PullRequest)
      end

      context "with action != opened" do
        it "responds with IssueAction bit if action != opened" do
          raw = raw_data(response_path: 'github/events/issues_event.json')
          raw['payload']['action'] = 'reopened'
          event = Events::Github::PullRequestEvent.new(raw)

          expect(
            Bits::Github::TypeDeterminator\
            .new(event)
            .type_class
          ).to eq(Bits::Github::IssueAction)
        end
      end
    end

    context "specifically an IssueEvent" do
      it "responds with Issue bit" do
        raw = raw_data(response_path: 'github/events/pull_request_event.json')
        event = Events::Github::IssueEvent.new(raw)

        expect(
          Bits::Github::TypeDeterminator\
          .new(event)
          .type_class
        ).to eq(Bits::Github::Issue)
      end

      context "action != opened" do
        it "responds with IssueAction bit if action != opened" do
          raw = raw_data(response_path: 'github/events/pull_request_event.json')
          raw['payload']['action'] = 'closed'
          event = Events::Github::IssueEvent.new(raw)

          expect(
            Bits::Github::TypeDeterminator\
            .new(event)
            .type_class
          ).to eq(Bits::Github::IssueAction) 
        end
      end
    end

  end
end

describe Bits::Instagram::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Instagram::Media class' do
      expect(
        Bits::Instagram::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Bits::Instagram::Media)
    end
  end
end

describe Bits::Meetup::TypeDeterminator do
  describe '#type_class' do
    it 'remaps the event_type and returns the type_class' do
      event = Events::Meetup::EventEvent.new({ source_data: {}, meta: {} })

      expect(
        Bits::Meetup::TypeDeterminator\
        .new(event)
        .type_class
      ).to eq(Bits::Meetup::Event)
    end
  end
end

describe Bits::Rss::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Rss::Post class' do
      expect(
        Bits::Rss::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Bits::Rss::Post)
    end
  end
end

describe Bits::Stackexchange::TypeDeterminator do
  describe '#type_class' do
    it 'remapps the event type and gets the appropriate class' do
      raw = raw_data(response_path: 'stackexchange/question.json')
      event = Events::Stackexchange::QuestionEvent.new(raw)

      expect(
        Bits::Stackexchange::TypeDeterminator\
        .new(event).type_class
      ).to eq(Bits::Stackexchange::Question)
    end
  end
end

describe Bits::Tumblr::TypeDeterminator do
  describe '#type_class' do
    it 'finds the type_class based on the type_name' do
      raw = raw_data(response_path: 'tumblr/blog.json')['response']['posts'][0]
      event = Events::Tumblr::PostEvent.new(raw)

      expect(
        Bits::Tumblr::TypeDeterminator\
        .new(event).type_class
      ).to eq(Bits::Tumblr::Text)
    end
  end

  describe '#type_name' do
    it 'plucks the type name from the source_data' do
      raw = raw_data(response_path: 'tumblr/blog.json')['response']['posts'][0]
      event = Events::Tumblr::PostEvent.new(raw)

      expect(
        Bits::Tumblr::TypeDeterminator\
        .new(event).type_name
      ).to eq(:Text)
    end
  end
end

describe Bits::Twitter::TypeDeterminator do
  describe '#type_class' do
    it 'remaps the event\'s type_name and returns a type_class' do
      fake_follow_raw = raw_data(response_path: 'twitter/fake_follow_event.json')
      fake_follow = Events::Twitter::FakeFollowEvent.new(fake_follow_raw)

      follow_raw = raw_data(response_path: 'twitter/follow_event.json')
      follow = Events::Twitter::FollowEvent.new(follow_raw)

      expect(
        Bits::Twitter::TypeDeterminator\
        .new(fake_follow).type_class
      ).to eq(Bits::Twitter::Follow)

      expect(
        Bits::Twitter::TypeDeterminator\
        .new(follow).type_class
      ).to eq(Bits::Twitter::Follow)
    end
  end
end

describe Bits::Youtube::TypeDeterminator do
  describe '#type_class' do
    it 'always returns the Youtube::Video class' do
      expect(
        Bits::Youtube::TypeDeterminator\
        .new({ 'whatever' => 'doesn\'t matter' })
        .type_class
      ).to eq(Bits::Youtube::Video)
    end
  end
end
