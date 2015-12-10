class RemoteTest < Minitest::Test
  def setup
    super
    VCR.insert_cassette name
  end

  def teardown
    super
    VCR.eject_cassette
  end
end
