require File.join(File.dirname(__FILE__), 'test_helper.rb')
require 'rbkb/cli.rb'

Rbkb.require_all_libs_relative_to(File.dirname(__FILE__) + "/../lib/rbkb/cli.rb")

Rbkb::Cli::TESTING = true unless defined? Rbkb::Cli::TESTING

module CliTest
  def setup
    @stdout_io = StringIO.new
    @stderr_io = StringIO.new
    @stdin_io  = StringIO.new
    @cli_obj = @cli_class.new(
      :stdout => @stdout_io, 
      :stderr => @stderr_io,
      :stdin => @stdin_io
    )
  end

  ## several variations on running a cli command, shouldn't matter which
  ## is used, but we want to test all of them out
  def go_with_args(argv=[])
    catch(:exit_err) { catch(:exit_zero) { @cli_obj.go(argv) } }
  end

  def go_set_args(argv=[])
    @cli_obj.argv = argv
    catch(:exit_err) { catch(:exit_zero) { @cli_obj.go } }
  end

  def run_with_args(argv=[])
    param = {
      :stdout => @stdout_io, 
      :stderr => @stderr_io, 
      :stdin => @stdin_io, 
      :argv => argv
    }
    catch(:exit_err){ catch(:exit_zero) { @cli_class.run(param) } }
  end


  def with_testfile
    fname = ".cli_tst_#{rand(0xffffffffffffffff).to_s(16).rjust(16,'0')}.tmp"
    f=File.open(fname,"w")
    yield(fname.dup, f)
    f.close unless f.closed?
    File.delete(fname)
  end

  ### These are all basic CLI tests which every derived class should be able
  ### to pass.
  ### They'll be imported into individual TestCli.... suites 
  ### along with the standard set up convenience methods above
  def test_usage
    assert_equal 1, go_with_args(%w(-h))
    assert_match(/^Usage: /, @stderr_io.string )
  end

  def test_bad_argument
    assert_equal 1, go_with_args(%w(--this_is_really_redonculouslywrong))
    assert_match(/Error: bad arguments/, @stderr_io.string )
  end

  def test_version_arg
    assert_equal 0, go_with_args(%w(-v))
    assert_match(/Ruby BlackBag version #{Rbkb::VERSION}/, @stdout_io.string)
  end

  def test_vers_go_set_variant
    assert_equal 0, go_set_args(%w(-v))
    assert_match(/Ruby BlackBag version #{Rbkb::VERSION}/, @stdout_io.string)
  end

  def test_vers_class_run_variant
    assert_equal 0, run_with_args(%w(-v))
    assert_match(/Ruby BlackBag version #{Rbkb::VERSION}/, @stdout_io.string)
  end

end
