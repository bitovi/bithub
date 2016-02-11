every '1,16,31,46 * * * *' do
  rake 'recurring:calc_analytics'
end

every '10,20,30,40,50 * * * *' do
  rake 'recurring:fill_fake_follows'
end

every :day, at: '05:30am' do
  rake 'recurring:flag_inactive'
end

every :day, at: '06:30am' do
  rake 'recurring:age_out_entities'
end

every :day, at: '07:30am' do
  rake 'recurring:clean_orphaned_entities'
end

every :day, at: '8:30am' do
  rake 'recurring:clean_orphaned_services'
  rake 'recurring:load_missing_services'
end

every :day, at: '09:30am' do
  command '/usr/bin/psql -c \'VACUUM FULL ANALYZE;\''
end
