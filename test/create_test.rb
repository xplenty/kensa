require 'test/helper'

class CreateTest < Test::Unit::TestCase
  include Xplenty::Kensa

  def setup
    stub(Git).run
    any_instance_of Client do |client|
      stub(client).init
    end
    stub(Dir).chdir
  end

  def test_requires_app_name
    assert_raise Client::CommandInvalid do
      kensa "create my_addon"
    end
  end

  def test_requires_template
    assert_raise Client::CommandInvalid do
      kensa "create --template foo"
    end
  end

  def test_assumes_xplenty_template
    kensa "create my_addon --template sinatra"
    assert_received Git do |git|
      git.run("git clone git://github.com/xplenty/xplenty-kensa-create-sinatra my_addon")
    end
  end

  def test_assumes_github
    kensa "create my_addon --template xplenty/sinatra"
    assert_received Git do |git|
      git.run("git clone git://github.com/xplenty/sinatra my_addon")
    end
  end

  def test_allows_full_url
    kensa "create my_addon --template git://xplenty.com/sinatra.git"
    assert_received Git do |git|
      git.run("git clone git://xplenty.com/sinatra.git my_addon")
    end
  end
end
