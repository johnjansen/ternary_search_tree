require "./spec_helper"

describe String do
  # TODO: Write tests

  it "should head a string" do
    "".head.should be_nil
    "h".head.should eq 'h'
    "head".head.should eq 'h'
  end

  it "should tail a string" do
    "".tail.should eq ""
    "1".tail.should eq ""
    "12".tail.should eq "2"
    "head".tail.should eq "ead"
  end
end
