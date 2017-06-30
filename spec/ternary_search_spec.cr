require "./spec_helper"

describe TernarySearch do
  # TODO: Write tests

  it "should head a string" do
    "".head.should be_nil
    "head".head.should eq 'h'
  end

  it "should ad a simple case" do
    tst = TernarySearch::Tree.new
    tst.insert "pr"
    tst.insert "cr"

    tst.search("pr").should eq true
    tst.search("prs").should eq false
    tst.search("cr").should eq true
  end
end
