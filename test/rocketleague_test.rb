require 'test_helper'

describe RocketLeague do
  before do
    @rl = RocketLeague::API.new "https://example.com", 1, "Steam", "callprockey"
  end

  it "must have a version number" do
    refute_nil ::RocketLeague::VERSION
  end

  it "must encode proc calls correcly" do
    encoded = @rl.procencode([["ProcWithNoArgs"], ["ProcWithArgs", "123456789", "abcdefg"]])
    expected = "&P1P[]=123456789&P1P[]=abcdefg&Proc[]=ProcWithNoArgs&Proc[]=ProcWithArgs"
    assert_equal expected, encoded
  end

  it "must parse proc responses correcly" do
    # features leading empty line, multiple intermediate empty lines, trailing empty line, duplicate results
    response = <<-END.gsub(/^    /, '')

    DataKey=Analytics&DataValue=1
    DataKey=BugReports&DataValue=0
    DataKey=RankEnabled&DataValue=1



    DataKey=Analytics&DataValue=1
    DataKey=BugReports&DataValue=0
    DataKey=RankEnabled&DataValue=1

    DataKey=Analytics&DataValue=1
    DataKey=BugReports&DataValue=0
    DataKey=RankEnabled&DataValue=1

    SQL ERROR: Whatever

    END
    parsed = @rl.procparse(response)
    expected = [
      [],
      [
        {"DataKey"=>"Analytics", "DataValue"=>"1"},
        {"DataKey"=>"BugReports", "DataValue"=>"0"},
        {"DataKey"=>"RankEnabled", "DataValue"=>"1"}
      ],
      [],
      [],
      [
        {"DataKey"=>"Analytics", "DataValue"=>"1"},
        {"DataKey"=>"BugReports", "DataValue"=>"0"},
        {"DataKey"=>"RankEnabled", "DataValue"=>"1"}
      ],
      [
        {"DataKey"=>"Analytics", "DataValue"=>"1"},
        {"DataKey"=>"BugReports", "DataValue"=>"0"},
        {"DataKey"=>"RankEnabled", "DataValue"=>"1"}
      ],
      [
        RuntimeError.new("SQL ERROR: Whatever")
      ],
      []
    ]
    assert_equal expected, parsed
  end
end
