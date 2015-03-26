require 'rails_helper'

describe Identities::Facade do

  let(:source_data) do
    {
      "uid"=>90485442,
      "info"=>{
        "name"=>"neektza"
      },
      "credentials"=>{
        "token"=>"49d58f4a8082390d1ab61da05fd11ea8", # valid for all feeds
        "secret"=>"JPia4VY8A1He93HNX08GRS7nq26WNWbbwauQCTg6s7neI", # only valid for twitter
        "refresh_token"=>"f3fbcdde8d27554c8ea02facd52258e0",
        "expires_at"=>1427264292,
        "expires"=>true
      }
    }
  end

  let(:extracted_data) do
    {
      "pages"=>[{
        "id"=>12345,
        "name"=>"KSET",
        "access_token"=>"23145ythjgbfdsweq435rtyghbdf"
      }],
      "groups"=>[{
        "id"=>13140052,
        "urlname"=>"rubyzg"
      }, {
        "id"=>15488792,
        "urlname"=>"lambdazagreb"
      }],
      "venues"=>[{
        "id"=>12345,
        "name"=>"KSET",
      }],
      "repos"=>[{
        "id"=>4475165,
        "name"=>"muchi.me",
        "full_name"=>"aljosa/muchi.me"
      }, {
        "id"=>4232639,
        "name"=>"Tonfa.js",
        "full_name"=>"retro/Tonfa.js"
      }],
      "orgs"=>[{
        "id"=>2782656,
        "login"=>"bitovi"
      }]
    }
  end

  class FacadeMock
    def initialize(sd, ed); end
    def provider_name; 'facebook'; end
  end

  describe '#name' do
    it 'fetches the name from the oauth info' do
      facade = Identities::Facade.new(FacadeMock, source_data, extracted_data)
      expect(facade.name).to eq('neektza')
    end
  end

  describe '#credentials' do
    context 'when accessing a brand identity from facebook' do
      it 'constructs credentials from a access token taken from a page' do
        facebook_facade = Identities::Facade.new(
          Identities::Facades::Facebook,
          source_data, extracted_data)

        expect(facebook_facade.credentials(12345)).to eq({
          access_token: extracted_data['pages'].first['access_token']
        })
      end
    end

    context 'when accessing a brand identity from twitter' do
      it 'constructs credentians from a token and a secret' do
        twitter_facade = Identities::Facade.new(
          Identities::Facades::Twitter,
          source_data, extracted_data)

        expect(twitter_facade.credentials).to eq({
          access_token: source_data['credentials']['token'],
          access_secret: source_data['credentials']['secret']
        })
      end
    end

    context 'when accessing a brand identity from any other source' do
      it 'constructs credentials from a token' do
        disqus_facade = Identities::Facade.new(
          Identities::Facades::Disqus,
          source_data, extracted_data)

        expect(disqus_facade.credentials).to eq({
          access_token: source_data['credentials']['token'],
        })
      end
    end
  end

  describe '#property_id_name_pairs' do
    context 'when accessing properties from meetup identities' do
      it 'plucks the id<>name pairs from the identity\'s groups' do
        disqus_facade = Identities::Facade.new(
          Identities::Facades::Meetup,
          source_data, extracted_data)

        expect(disqus_facade.property_id_name_pairs).to eq([{
          id: extracted_data['groups'][0]['id'],
          name: extracted_data['groups'][0]['urlname']
        }, {
          id: extracted_data['groups'][1]['id'],
          name: extracted_data['groups'][1]['urlname']
        }])
      end
    end

    context 'when accessing properties from github identities' do
      it 'plucks the id<>name pairs from the identity\'s repos' do
        disqus_facade = Identities::Facade.new(
          Identities::Facades::Github,
          source_data, extracted_data)

        expect(disqus_facade.property_id_name_pairs('repo')).to eq([{
          id: extracted_data['repos'][0]['full_name'],
          name: extracted_data['repos'][0]['full_name']
        }, {
          id: extracted_data['repos'][1]['full_name'],
          name: extracted_data['repos'][1]['full_name']
        }])
      end
    end
  end

  describe '#property_name_for_id' do
  end
end
