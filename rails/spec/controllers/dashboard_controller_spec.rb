require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DashboardController do
  describe 'index' do
    before :each do
      @failed = stub('failed nodes')
      Node.stubs(:failed).returns(@failed)

      @silent = stub('silent nodes')
      Node.stubs(:silent).returns(@silent)

      @logs = stub('latest logs')
      Log.stubs(:latest).returns(@logs)
    end

    def do_get
      get :index
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should get failed nodes' do
      Node.expects(:failed)
      do_get
    end

    it 'should assign failed nodes for the view' do
      do_get
      assigns[:failed_nodes].should == @failed
    end

    it 'should get nodes not checked in' do
      Node.expects(:silent)
      do_get
    end

    it 'should assign nodes not checked in for the view' do
      do_get
      assigns[:silent_nodes].should == @silent
    end

    it 'should get latest logs' do
      Log.expects(:latest)
      do_get
    end

    it 'should assign latest logs for the view' do
      do_get
      assigns[:logs].should == @logs
    end
  end

  describe 'search' do
    before :each do
      @query = 'match'
      @matches = 'matches'
      @parsed = 'parsed'
      @page = '2'
      Node.stubs(:search).returns(@matches)
      SearchParser.stubs(:parse).returns(@parsed)
    end

    def do_get
      get :search, { :q => @query, :page => @page }
    end

    it 'should be successful' do
      do_get
      response.should be_success
    end

    it 'should parse the query string' do
      SearchParser.expects(:parse).with(@query).returns(@parsed)
      do_get
    end

    it 'should search nodes with conditions from the parsed query string' do
      Node.expects(:search).with do |args|
        args[:conditions] == @parsed
      end
      do_get
    end

    it 'should pass the current page when searching' do
      Node.expects(:search).with do |args|
        args[:page] == @page
      end
      do_get
    end

    it 'should make the query string available to the view' do
      do_get
      assigns[:q].should == @query
    end

    it 'should make search results available to the view' do
      do_get
      assigns[:results].should == @matches
    end

    it 'should render the search results page' do
      do_get
      response.should render_template('search')
    end
  end
end
