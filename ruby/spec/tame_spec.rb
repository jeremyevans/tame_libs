require './lib/tame'

gem 'minitest'
require 'minitest/autorun'

RUBY = ENV['RUBY'] || 'ruby'

describe "Tame.tame" do
  def _tamed(status, args, code)
    system(RUBY, '-I', 'lib', '-r', 'tame', '-e', "Tame.tame(#{Array(args).map(&:inspect).join(',')}); #{code}").must_equal status
  end

  def tamed(code, *args)
    _tamed(true, args, code)
  end

  def untamed(code, *args)
    _tamed(false, args, code)
  end

  def with_lib(lib)
    rubyopt = ENV['RUBYOPT']
    ENV['RUBYOPT'] = "#{rubyopt} -r#{lib}"
    yield
  ensure
    ENV['RUBYOPT'] = rubyopt
  end

  after do
    Dir['spec/_*'].each{|f| File.delete(f)}
    Dir['*.core'].each{|f| File.delete(f)}
  end

  it "should raise a KeyError for unsupported exceptions" do
    proc{Tame.tame(:foo)}.must_raise ArgumentError
  end

  it "should produce a core file on failure if abort is use" do
    Dir['*.core'].must_equal []
    untamed("File.read('#{__FILE__}')")
    Dir['*.core'].must_equal []
    untamed("File.read('#{__FILE__}')", :abort)
    Dir['*.core'].wont_equal []
  end

  it "should allow reading files if :rpath is used" do
    untamed("File.read('#{__FILE__}')")
    tamed("File.read('#{__FILE__}')", :rpath)
  end

  it "should allow creating files if :cpath and :wpath are used" do
    untamed("File.open('spec/_test', 'w'){}")
    untamed("File.open('spec/_test', 'w'){}", :cpath)
    untamed("File.open('spec/_test', 'w'){}", :wpath)
    File.file?('spec/_test').must_equal false
    tamed("File.open('#{'spec/_test'}', 'w'){}", :cpath, :wpath)
    File.file?('spec/_test').must_equal true
  end

  it "should allow writing to files if :wpath and rpath are used" do
    File.open('spec/_test', 'w'){}
    untamed("File.open('spec/_test', 'r+'){}")
    tamed("File.open('#{'spec/_test'}', 'r+'){|f| f.write '1'}", :wpath, :rpath)
    File.read('spec/_test').must_equal '1'
  end

  it "should allow dns lookups if :dns is used" do
    with_lib('socket') do
      untamed("Socket.gethostbyname('google.com')")
      tamed("Socket.gethostbyname('google.com')", :dns)
    end
  end

  it "should allow internet access if :inet is used" do
    with_lib('net/http') do
      untamed("Net::HTTP.get('127.0.0.1', '/index.html') rescue nil")
      args = [:inet]
      # rpath necessary on ruby < 2.1, as it calls stat
      args << :rpath if RUBY_VERSION < '2.1'
      tamed("Net::HTTP.get('127.0.0.1', '/index.html') rescue nil", *args)
    end
  end

  it "should allow killing programs if :proc is used" do
    untamed("Process.kill(:INFO, $$)")
    tamed("Process.kill(:INFO, $$)", :proc)
  end

  it "should allow creating temp files if :tmppath and :rpath are used" do
    with_lib('tempfile') do
      untamed("Tempfile.new('foo')")
      untamed("Tempfile.new('foo')", :tmppath)
      untamed("Tempfile.new('foo')", :rpath)
      args = [:tmppath, :rpath]
      # cpath necessary on ruby < 2.0, as it calls mkdir
      args << :cpath if RUBY_VERSION < '2.0'
      tamed("Tempfile.new('foo')", *args)
    end
  end

  it "should allow unix sockets if :unix and :rpath is used" do
    require 'socket'
    us = UNIXServer.new('spec/_sock')
    with_lib('socket') do
      untamed("UNIXSocket.new('spec/_sock').send('u', 0)")
      untamed("UNIXSocket.new('spec/_sock').send('u', 0)", :unix)
      untamed("UNIXSocket.new('spec/_sock').send('u', 0)" ,:rpath)
      tamed("UNIXSocket.new('spec/_sock').send('t', 0)", :unix, :rpath)
    end
    us.accept.read.must_equal 't'
  end
end
