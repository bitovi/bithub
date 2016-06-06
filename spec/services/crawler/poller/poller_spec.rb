require 'celluloid/test'
require 'spec_helper'
require 'supervisors/owner_data'
require 'poller/poller'

class MockLocker
  def initialize; @locked = false; end
  def available?; true; end
  def locked?(l); @locked; end
  def lock(l); @locked = true; end
end

class MockFetcher
  def initialize(r = %w(one page of events)); @r = r; end
  def fetch; @r; end
end

class MockPublisher
  attr_reader :q
  def initialize; @q = []; end
  def publish(xs, own, o={}); @q += xs; end
end

class MockNotifier
  attr_reader :qb, :qf
  def initialize; @qb = []; @qf = []; end
  def publish_to_backend(n, od); @qb << n; end
  def publish_to_frontend(n, od); @qf << n; end
end

describe Poller do
  let(:locker) { MockLocker.new }
  let(:fetcher) { MockFetcher.new }
  let(:publisher) { MockPublisher.new }
  let(:notifier) { MockNotifier.new }

  before { Celluloid.boot }
  after { Celluloid.shutdown }

  describe '#fetch_and_lock' do
    it 'fetches events via the provided Fetcher' do
      owner_data = OwnerData.new(1, '', 11, '', 111, '', '', {})
      poller = Poller.new(owner_data, fetcher, locker: locker)
      expect(poller.fetch_and_lock).to eq %w(one page of events)
    end

    it 'locks the designated lock via the LockManager' do
      owner_data = OwnerData.new(1, '', 11, '', 111, '', '', {})
      poller = Poller.new(owner_data, fetcher, locker: locker)
      poller.fetch_and_lock
      expect(locker.locked?("doesnt matter")).to eq(true)
    end
  end

  describe '#poll' do
    context 'assuming the fetch returns a non-empty array of events' do
      it 'publishes the events sends the command to clear service errros' do
        owner_data = OwnerData.new(1, '', 11, '', 111, '', '', {})
        poller = Poller.new(owner_data, fetcher, {
          locker: locker,
          publisher: publisher,
          notifier: notifier
        })

        poller.poll
        expect(publisher.q).to eq fetcher.fetch
        expect(notifier.qf).to eq [poller.clear_service_errors_notif]
        expect(notifier.qb).to eq [poller.clear_service_errors_notif]
      end
    end

    context 'assuming the fetch returns an empty array' do
      it 'notifies that the response is empty and publishes the command to clear service errors' do
      owner_data = OwnerData.new(1, '', 11, '', 111, '', '', {})
      poller = Poller.new(owner_data, f = MockFetcher.new([]), {
        locker: locker,
        publisher: publisher,
        notifier: notifier
      })

      poller.poll
      expect(publisher.q).to eq f.fetch
      expect(notifier.qf).to eq [poller.empty_response_notif, poller.clear_service_errors_notif]
      expect(notifier.qb).to eq [poller.clear_service_errors_notif]
    end

    end
  end

  describe '#lock_name' do
    context 'given a lock type' do
      it 'produces a lock name' do
        owner_data = OwnerData.new(1, '', 11, '', 111, '', '', {})
        poller = Poller.new(owner_data, fetcher, locker: locker)
        expect(poller.lock_name).to eq "lock:polling:brand/1:hub/11:service/111"
        expect(poller.lock_name(:initial)).to eq "lock:polling:initial_fetch:brand/1:hub/11:service/111"
      end
    end
  end
end
