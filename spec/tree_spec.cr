require "./spec_helper"

describe TernarySearch::Tree do
  # TODO: Write tests

  it "should ad a simple case" do
    tst = TernarySearch::Tree.new
    tst.insert "p"
    tst.search("p").should eq true

    tst.insert "pr"
    tst.insert "cr"

    tst.search("pr").should eq true
    tst.search("prs").should eq false
    tst.search("cr").should eq true
  end
end
