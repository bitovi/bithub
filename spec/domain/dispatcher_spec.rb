require 'domain/spec_helper'
require File.expand_path(File.join(PROJECT_ROOT, "config/environment"))

require 'dispatcher'

def dataset(x)
  ActiveSupport::JSON.decode(File.read("spec/domain/support/interaction#{x}.json"))
end

def latest_dataset
  ActiveSupport::JSON.decode(File.read(Dir.glob("spec/domain/support/*.json").last))
end

def prepare_data(which)
  if which == :latest
    latest_dataset.each {|event_data| Dispatcher.new.dispatch(event_data, 'github')}
  elsif which.is_a? Number
    dataset(which).each {|event_data| Dispatcher.new.dispatch(event_data, 'github')}
  end
end

describe Dispatcher do

  describe "#dispatch" do

    before :all do
      import_needed_shit
      prepare_data(:latest)

      @issue1 = Entity.feed('github').type('issue').number(1).first
      @issue2 = Entity.feed('github').type('issue').number(2).first
      @pull_req3 = Entity.feed('github').type('pull_request').number(3).first
      @pull_req4 = Entity.feed('github').type('pull_request').number(4).first
      @push = Entity.feed('github').type('push').first
    end

    after :all do
      ActiveRecord::Base.connection.execute("delete from events; delete from entities; delete from entity_refs;")
    end

    it "testcase - existence" do
      expect(Entity.count).to eq (latest_dataset.size + 3) # 3 commits in push
      expect(Event.count).to eq latest_dataset.size
    end

    it "testcase - state" do
      expect(@issue1.state).to eq "open"
      expect(@issue2.state).to eq "open"
      # expect(@pull_req3.state).to eq "closed"
    end

    it "testcase - children" do
      expect(@issue1.children.count).to eq 4
      expect(@issue2.children.count).to eq 4
      expect(@pull_req3.children.count).to eq 7
    end
    
    it "testcase - labels" do
      expect(@issue1.label_names).to eq "bug"
      expect(@issue2.label_names).to eq "enhancement,question"
      expect(@pull_req3.label_names).to eq "invalid"
    end

    it "testcase - titles and bodies" do
      expect(@issue2.title).to eq "Sa labelom na pocetku, sa izmjenjenim tajtlom"
    end

    it "testcase - references from" do
      expect(@issue1.referenced_from).to eq [@issue2]
    end

    it "testcase - references to" do
      expect(@issue1.references_to).to eq [@pull_req3]
    end

    it "testcase - children have no references_to" do
      expect(@issue1.children.reduce(false){|acc, c|
        acc || c.references_to.present?
      }).to eq false
    end

    it "testcase - children have no references_from" do
      expect(@issue2.children.reduce(false){|acc, c|
        acc || c.references_to.present?
      }).to eq false
    end

    it "testcase - pushes and commits" do
      expect(@push.children.count).to eq 3
    end

    it "testase - non expected event types will not break anything" do
      pairs = [
        %w(foo bar),
        %w(github nonExistingType),
        %w(twitter nonExistingType),
        %w(bithub nonExistingType),
        %w(meetup nonExistingType),
      ]
      expect {
        pairs.each do |pair|
          feed, type = pair
          Dispatcher.new.dispatch({
            'meta' => {
              'feed_name' => feed,
              'type_name' => type
            },
            'source_data' => {}
          })
        end
      }.not_to raise_error
    end

    it "testcase - non existent source_data should not break anything" do
      expect { Dispatcher.new.dispatch({}) }.not_to raise_error
    end

    it "testcase - references from commits" do
    end

    it "testcase - multi-level parentship" do
    end

  end
end
