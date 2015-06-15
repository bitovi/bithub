require 'events/determinator'
require 'events/protocol'
require 'events/github/push_event'
require 'events/github/custom_issue_event'

describe Events::FeedModuleDeterminator do

  describe '#feed_module' do
    context 'provided a feed_name, either through a hint or in meta' do
      it 'returns a feed module' do
        d = Events::FeedModuleDeterminator.new({
          meta: { feed_name: 'github' },
          source_data: { },
        })

        expect(d.feed_module).to eq(Events::Github)
      end
    end
  end

  describe '#feed_name' do
    context 'given a hint' do
      it 'respects the hint and converts it to a CamelCase symbol' do
        d = Events::FeedModuleDeterminator.new({ source_data: { }, meta: { } }, 'github')
        expect(d.feed_name).to eq(:Github)
      end
    end

    context 'given no hint, but given meta with feed_name' do
      it 'plucks the feed_name from meta and converts it to a CamelCase symbol' do
        d = Events::FeedModuleDeterminator.new({
          meta: { feed_name: 'github' },
          source_data: { },
        })

        expect(d.feed_name).to eq(:Github)
      end
    end

    context 'given no feed_name of any kind' do
      it 'raises a DeterminationError' do
        expect do
          Events::FeedModuleDeterminator.new({ source_data: { }, meta: { } }).feed_module
        end.to raise_error(Events::DeterminationError)
      end
    end
  end
end

describe Events::BaseTypeClassDeterminator do

  module Events
    class StubTypeClassDeterminator < BaseTypeClassDeterminator
      def type_class
        super { nil }
      end
    end
  end

  describe '#type_class' do
    it 'raises a DeterminationError if it\'s unable to find an appropriate type_class' do
      expect do
        Events::StubTypeClassDeterminator.new({ source_data: { }, meta: { } }).type_class
      end.to raise_error(Events::DeterminationError)
    end
  end
end

describe Events::Github::TypeClassDeterminator do

  describe '#type_class' do
    it 'determines a type_class for a given event' do
      activity_event = {
        'source_data' => {
          'type' => 'push_event'
        }
      }

      expect(
        Events::Github::TypeClassDeterminator\
        .new(activity_event)
        .type_class
      ).to eq(Events::Github::PushEvent)
    end
  end

  describe '#remapped_type_name' do
    it 'remapps source types to our custom types' do
      activity_issues_event = {
        'source_data' => {
          'type' => 'issues_event'
        }
      }

      expect(
        Events::Github::TypeClassDeterminator\
        .new(activity_issues_event)
        .remapped_type_name
      ).to eq(:'IssueEvent')
    end
  end

  describe '#type_name' do
    context 'provided a valid Github event' do
      it 'determines the type of the event and returns a type_name' do

        activity_event = {
          'source_data' => {
            'type' => 'push_event'
          }
        }

        expect(
          Events::Github::TypeClassDeterminator\
          .new(activity_event)
          .type_name
        ).to eq(:'PushEvent')

        issue = { 
          'source_data' => {
            'labels' => %w(foo bar),
            'comments' => %(baz qux),
            'state' => 'open',
          }
        }

        expect(
          Events::Github::TypeClassDeterminator\
          .new(issue)
          .type_name
        ).to eq(:'CustomIssueEvent')
        
        # pull_req = {
        #   source_data: {
        #     state: 'open',
        #     labels: %w(foo bar),
        #     comments: %w(baz qux),
        #     pull_request: {
        #       id: 123,
        #       author: 'molim'
        #     }
        #   }
        # }
        
        # expect(
        #   Events::Github::TypeClassDeterminator\
        #   .new(pull_req)\
        #   .type_name
        # ).to eq(:CustomPullRequestEvent)
      end
    end
  end
end

describe Events::Twitter::TypeClassDeterminator do
  describe '#type_class' do
    it 'determines a type_class for a given event' do
      tweet = {
        'source_data' => {
          'text' => 'blah #blah @blah',
          'user' => { 'screen_name' => 'neektza' }
        }
      }
      
      expect(
        Events::Twitter::TypeClassDeterminator\
        .new(tweet)
        .type_class
      ).to eq(Events::Twitter::TweetEvent)
    end
  end

  describe '#type_name' do
    it 'determines the type of the event and returns a type_name' do
      follow_event = {
        'source_data' => {
          'event' => 'follow',
          'source' => { },
          'target' => { }
        }
      }

      expect(
        Events::Twitter::TypeClassDeterminator\
        .new(follow_event)
        .type_name
      ).to eq(:FollowEvent)
      
      fake_follow_event = {
        'source_data' => {
          'event' => 'fake_follow',
          'source' => { },
          'target' => { }
        }
      }
      
      expect(
        Events::Twitter::TypeClassDeterminator\
        .new(fake_follow_event)
        .type_name
      ).to eq(:FakeFollowEvent)
      
      tweet_event = {
        'source_data' => {
          'text' => 'blah #blah @blah',
          'user' => { 'screen_name' => 'neektza' }
        }
      }
      
      expect(
        Events::Twitter::TypeClassDeterminator\
        .new(tweet_event)
        .type_name
      ).to eq(:TweetEvent)
    end
  end
end

describe Events::Facebook::TypeClassDeterminator do
  describe '#type_class' do
    it 'returns a type_class' do
      status_event = { 'source_data' => { 'type' => 'status' } }
      
      expect(
        Events::Facebook::TypeClassDeterminator\
        .new(status_event)
        .type_class
      ).to eq(Events::Facebook::StatusEvent)
    end
  end
  
  describe '#type_name' do
    it 'plucks the type of the event from the :type attribute' do
      status_event = { 'source_data' => { 'type' => 'status' } }

      expect(
        Events::Facebook::TypeClassDeterminator\
        .new(status_event)\
        .type_name
      ).to eq(:StatusEvent)
    end
  end
end

describe Events::Meetup::TypeClassDeterminator do
  describe '#type_class' do
    it 'returns a type_class' do
      event_event = { 'source_data' => { 'rsvp_id' => 1 } }
      rsvp_event = { 'source_data' => { 'event_url' => 'http://example.url' } }

      expect(
        Events::Meetup::TypeClassDeterminator\
        .new(event_event)
        .type_class
      ).to eq(Events::Meetup::RsvpEvent)

      expect(
        Events::Meetup::TypeClassDeterminator\
        .new(rsvp_event)\
        .type_class
      ).to eq(Events::Meetup::EventEvent)
    end
  end
end
