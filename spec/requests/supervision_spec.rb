require "spec_helper"

describe "Supervision", :js => true do
  def visit_supervision(supervision)
    visit supervision_path(supervision)
    page.should have_css(".supervision.connected") # make sure it's connected and authenticated
    page.should have_css(".supervision[data-supervision-updates]")
  end

  def prepare_supervision(state)
    supervision = Factory(:supervision, :group => @group, :state => state, :topic => Factory(:topic, :user => @alice))
    @alice.join_supervision(supervision)
    @bob.join_supervision(supervision)
    @cindy.join_supervision(supervision)
    supervision
  end

  before do
    @alice = Factory(:user, :name => "Alice", :email => "alice@example.com")
    @bob = Factory(:user, :name => "Bob", :email => "bob@example.com")
    @cindy = Factory(:user, :name => "Cindy", :email => "cindy@example.com")

    @group = Factory(:group, :name => "FuFighters")
    @alice.join_group(@group)
    @bob.join_group(@group)
    @cindy.join_group(@group)
  end

  context "in providing_ideas state" do
    before do
      @supervision = prepare_supervision("providing_ideas")
    end

    it "allows to add idea by non-topic owner" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      fill_in "idea_content", :with => "I have some idea"
      click_button "Post idea"
      page.should have_content("I have some idea")
    end

    it "allows to view posted idea" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      page.should have_content("I have some idea")
    end

    it "allows to rate idea" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @idea = Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      page.should have_content("I have some idea")
      within "#idea_#{@idea.id} .rating" do
        page.find("a[title]", :text => "5").click
      end
      page.should have_flash("Idea's rating has been changed")
      within "#idea_#{@idea.id} .rating" do
        page.should have_selector("input[type=radio]#idea_rating_5[checked]")
      end
    end

    it "shows rated idea" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      @idea = Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      @idea.update_attributes(:rating => "5")
      page.should have_flash("Idea's rating has been changed")
      within "#idea_#{@idea.id} .rating" do
        page.should have_selector("input[type=radio]#idea_rating_5[checked]")
      end
    end

    it "allows to step back" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      within ".supervision_statusbar" do
        click_button "Questions"
      end
      page.should have_flash("Go back to \"Questions\" state")
      within ".supervision_statusbar" do
        page.should have_selector("li.step.current_state input[value=Questions]")
      end
    end
  end

  context "in giving_ideas_feedback state" do
    before do
      @supervision = prepare_supervision("giving_ideas_feedback")
    end

    it "allows to rate idea" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @idea = Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      @idea_rating_selector = "#idea_#{@idea.id} .rating"
      page.should have_content("I have some idea")
      within @idea_rating_selector do
        page.find("a[title]", :text => "5").click
      end
      page.should have_flash("Idea's rating has been changed")
      within @idea_rating_selector do
        page.should have_selector("input[type=radio]#idea_rating_5[checked]")
      end
    end
  end

  context "in providing_solutions state" do
    before do
      @supervision = prepare_supervision("providing_solutions")
    end

    it "allows to add solution by non-topic owner" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      fill_in "solution_content", :with => "I have a solution"
      click_button "Post solution"
      page.should have_content("I have a solution")
    end

    it "allows to view posted solution" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      page.should have_content("I have a solution")
    end

    it "allows to rate solution" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @solution = Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      page.should have_content("I have a solution")
      within "#solution_#{@solution.id} .rating" do
        page.find("a[title]", :text => "4").click
      end
      page.should have_flash("Solution's rating has been changed")
      within "#solution_#{@solution.id} .rating" do
        page.should have_selector("input[type=radio]#solution_rating_4[checked]")
      end
    end

    it "shows rated solution" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      @solution = Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      @solution.update_attributes(:rating => "4")
      page.should have_flash("Solution's rating has been changed")
      within "#solution_#{@solution.id} .rating" do
        page.should have_selector("input[type=radio]#solution_rating_4[checked]")
      end
    end

    it "allows to step back" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      within ".supervision_statusbar" do
        click_button "Questions"
      end
      page.should have_flash(%Q[Go back to "Questions" state])
      within ".supervision_statusbar" do
        page.should have_selector("li.step.current_state input[value=Questions]")
      end
    end
  end

  context "in giving_solutions_feedback state" do
    before do
      @supervision = prepare_supervision("giving_solutions_feedback")
    end

    it "allows to rate solution" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @solution = Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      @solution_rating_selector = "#solution_#{@solution.id} .rating"
      page.should have_content("I have a solution")
      within @solution_rating_selector do
        page.find("a[title]", :text => "4").click
      end
      page.should have_flash("Solution's rating has been changed")
      within @solution_rating_selector do
        page.should have_selector("input[type=radio]#solution_rating_4[checked]")
      end
    end
  end
end
