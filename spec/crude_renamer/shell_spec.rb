RSpec.describe CrudeRenamer::Shell do
  let(:err_double) { double('err') }
  let(:out_double) { double('out', puts: nil) }

  it "exits without replacing if no argument is passed" do
    argv = []
    expect(err_double).to receive(:puts).with ::CrudeRenamer::Shell::BANNER
    expect(lambda { ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double) }).to raise_error SystemExit
  end

  it "performs a replace if there are exactly two arguments" do
    argv = ['.', 'foo', 'bar']
    expect(::CrudeRenamer::RenamingOrchestrator).
      to receive(:rename_with_options).
      with(
        hash_including(
          path: '.',
          current_name: 'foo',
          target_name: 'bar',
          perform: false
        ),
        out: out_double,
        err: err_double
      )
      ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double)
  end

  it "exits without replacing if more than two arguments are passed" do
    argv = ['.', 'one', 'two', 'three']
    expect(err_double).to receive(:puts).with ::CrudeRenamer::Shell::BANNER
    expect(lambda { ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double) }).to raise_error SystemExit
    expect(::CrudeRenamer::RenamingOrchestrator).not_to receive(:rename_with_options)
  end

  it "sets perform to true if -p option is passed" do
    argv = ['some/path', '-p', 'foo', 'bar']
    expect(::CrudeRenamer::RenamingOrchestrator).
    to receive(:rename_with_options).
    with(
      hash_including(
        path: 'some/path',
        current_name: 'foo',
        target_name: 'bar',
        perform: true
      ),
      out: out_double,
      err: err_double
    )

    ::CrudeRenamer::Shell.start( argv, out: out_double, err: err_double)
  end
end
