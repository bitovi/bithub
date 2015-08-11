every '1,16,31,46 * * * * *' do
  rake 'recurring:calc_analytics'
end

every '10,20,30,40,50 * * * * *' do
  rake 'recurring:fill_fake_follows'
end
