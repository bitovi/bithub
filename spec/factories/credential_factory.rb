FactoryGirl.define do
	factory :credential do
		provider 'facebook'
		source_data Hash.new
		extracted_data Hash.new
	end
end
