module Delayed
  def self.reset_all
    Delayed::Job.all.each do |d|
      d.last_error = nil
      d.run_at = Time.now
      d.failed_at = nil
      d.locked_at = nil
      d.locked_by = nil
      d.attempts = 0
      d.save!
    end
  end
end

Delayed::Worker.destroy_failed_jobs = false