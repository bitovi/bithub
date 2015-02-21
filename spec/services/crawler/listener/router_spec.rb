require 'services/crawler/listener/router'

describe Router do

  before :each do
    @router = Router.new
  end

  describe '#register' do
    it 'throws exception if route already exists' do
      @router.register :handler, '/foo/bar'

      expect do
        @router.register :handler, '/foo/bar'
      end.to raise_error Router::Errors::RouteAlreadyExists
    end

  end

  describe '#unregister' do
    it 'unregisters route' do
      @router.register :foo_handler, '/some/path'
      @router.register :bar_handler, '/some/path', :post
      @router.register :baz_handler, '/some/other/path'
      expect(@router.routes.count).to eq 3

      expect(@router.unregister '/some/other/path').to eq :baz_handler
      expect(@router.unregister '/some/path', :post).to eq :bar_handler
      expect(@router.unregister '/some/path').to eq :foo_handler

      expect(@router.routes.count).to eq 0
    end
  end

  describe '#route' do
    it 'routes req based on method and path' do
      @router.register :all_handler, '/foobar'
      @router.register :post_handler, '/foobar', :post
      @router.register :other_handler, '/other/bar'

      expect(@router.route('/foobar')).to eq :all_handler
      expect(@router.route('/foobar', :post)).to eq :post_handler
      expect(@router.route('/foobar', :delete)).to eq :all_handler
      expect(@router.route('/other/bar')).to eq :other_handler
      expect(@router.route('/non/existing')).to be nil
    end
  end

end
