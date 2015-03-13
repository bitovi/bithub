require 'spec_helper'
require 'services/crawler/lock_manager'

class MockRedis
  def initialize; @locks = {}; end
  def get(name); @locks[name]; end
  def set(name, val); @locks[name] = val; end
  def del(name); @locks.delete(name); end
  def setex(name, ttl, val); @locks[name] = val; end
end

describe LockManager do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  let(:mock_redis) { MockRedis.new }
  let(:lock_manager) { LockManager.new(redis: mock_redis) }

  describe '#lock' do
    context 'given an infinitely lasting or a time limited Lock' do
      it 'records it' do
        lock_manager.lock(Lock.new('polling_lock'))
        expect(mock_redis.get('polling_lock')).to be_truthy
      end
    end
  end

  describe '#locked?' do
    context 'given a Lock' do
      it 'checks if the lock is still in effect' do
        lock_manager.lock(Lock.new('polling_lock'))
        expect(lock_manager.locked?(Lock.new('polling_lock'))).to be_truthy
      end
    end
  end

  describe '#unlock' do
    context 'given a Lock' do
      it 'unlocks it' do
        lock_manager.lock(Lock.new('polling_lock'))
        expect(lock_manager.locked?(Lock.new('polling_lock'))).to be_truthy
        lock_manager.unlock(Lock.new('polling_lock'))
        expect(lock_manager.locked?(Lock.new('polling_lock'))).to be_falsey
      end
    end
  end

  describe '#available?' do
    it 'tells whether the LockManager is ready to accept queries and commands' do
      lock_manger = LockManager.new
      expect(lock_manger.available?).to be_truthy
    end
  end
end
