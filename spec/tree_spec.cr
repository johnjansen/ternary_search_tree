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

  it "should return all words" do
    tst = TernarySearch::Tree.new
    tst.insert "p"
    tst.insert "pr"
    tst.insert "pa"
    tst.insert "cr"

    output = tst.words

    output[0].should eq "cr"
    output[1].should eq "p"
    output[2].should eq "pa"
    output[3].should eq "pr"
  end

  it "should compute the max length of the tree" do
    tst = TernarySearch::Tree.new
    tst.insert "p"
    tst.insert "pr"
    tst.insert "prototype"
    tst.insert "cra"

    # len = 0
    tst.max_word_length.should eq 8
  end
end
