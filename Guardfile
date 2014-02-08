notification :gntp, sticky: true, host: '192.168.0.11', password: 'budala'

guard :rspec, cmd: 'ENV=test rake test:domain' do
  watch('spec/spec_helper.rb')
  watch(%r{^spec/support/*/*.rb})

  watch(%r{^spec/domain/events/*/*.rb})

  watch(%r{^app/domain/events/*.rb})
  watch(%r{^app/domain/events/*/*.rb})
end
