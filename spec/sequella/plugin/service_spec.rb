require 'spec_helper'
require 'ostruct'

describe Sequella::Plugin::Service do
  subject { Sequella::Plugin::Service }

  describe '#start' do
    it 'should raise if start attempted without an adapter specified' do
      config = OpenStruct.new
      expect { subject.start config.marshal_dump }.to raise_error 'Must supply an adapter argument to the Sequel configuration'
    end

    it 'should not raise an error if start attempted with a connection uri specified' do
      config = OpenStruct.new connection_uri: 'postgres://user:password@localhost/blog'
      subject.should_receive(:establish_connection).with(config.connection_uri)
      subject.should_receive(:require_models)

      expect { subject.start config.marshal_dump }.to_not raise_error
    end
  end

  describe '#qualify_path' do
    it 'should not alter a path that begins with "/"' do
      subject.qualify_path('/tmp/foo/bar').should == '/tmp/foo/bar'
    end

    it 'should prefix the Adhearsion root for relative paths' do
      Adhearsion.should_receive(:root).once.and_return '/path/to/myapp'
      subject.qualify_path('models').should == '/path/to/myapp/models'
    end
  end

  describe '#require_models' do
    it 'should load all files in a given path' do
      Dir.should_receive(:glob).once.with('/tmp/models/*.rb').and_yield('/tmp/models/foo.rb').and_yield('/tmp/models/bar.rb')
      subject.should_receive(:require).once.ordered.with '/tmp/models/foo.rb'
      subject.should_receive(:require).once.ordered.with '/tmp/models/bar.rb'
      subject.require_models '/tmp/models'
    end
  end
end
