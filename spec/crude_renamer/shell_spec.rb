RSpec.describe CrudeRenamer::Shell do
  let(:err_double) { double('err') }
  let(:out_double) { double('out', puts: nil) }
  let(:renamer_double) { double('renamer', reports: '') }

  it "exits without replacing if no argument is passed" do
    argv = []
    expect(err_double).to receive(:puts).with ::CrudeRenamer::Shell::BANNER
    expect(lambda { ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double) }).to raise_error SystemExit
  end

  it "performs a replace if there are exactly two arguments" do
    argv = ['.', 'foo', 'bar']
    expect(::CrudeRenamer::Renamer).
      to receive(:new).
      with(hash_including(path: '.', current_name: 'foo', target_name: 'bar', force: false)).
      and_return(renamer_double)
    ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double)
  end

  it "exits without replacing if more than two arguments are passed" do
    argv = ['.', 'one', 'two', 'three']
    expect(err_double).to receive(:puts).with ::CrudeRenamer::Shell::BANNER
    expect(lambda { ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double) }).to raise_error SystemExit
  end

  it "sets force to true if -f option is passed" do
    argv = ['some/path', '-f', 'foo', 'bar']
    expect(::CrudeRenamer::Renamer).
      to receive(:new).
      with(hash_including(path: 'some/path', current_name: 'foo', target_name: 'bar', force: true)).
      and_return(renamer_double)
    expect(renamer_double).to receive(:rename!)
    ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double)
  end

end
