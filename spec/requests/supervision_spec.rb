require "spec_helper"

feature "Supervision Session", :js => true do
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

  background do
    @alice = Factory(:user, :name => "Alice", :email => "alice@example.com")
    @bob = Factory(:user, :name => "Bob", :email => "bob@example.com")
    @cindy = Factory(:user, :name => "Cindy", :email => "cindy@example.com")

    @group = Factory(:group, :name => "FuFighters")
    @group.add_member!(@alice)
    @group.add_member!(@bob)
    @group.add_member!(@cindy)
  end

  context "in gathering_topics state" do
    background do
      @supervision = Factory(:supervision, :group => @group, :state => "gathering_topics")
      @alice.join_supervision(@supervision)
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)
    end

    scenario "should allow to post topic" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)
      fill_in "topic_content", :with => "Can rails scale?"
      click_button "Post your topic"
      Topic.exists?(:content => "Can rails scale?").should be_true
    end

    scenario "should display topic posted by other user" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)
      Factory(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
      page.should have_content("Can rails scale?")
    end
  end

  context "in voting_on_topics state" do
    background do
      @supervision = Factory(:supervision, :group => @group, :state => "voting_on_topics")
      @alice.join_supervision(@supervision)
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)
    end

    scenario "should allow to vote on topic" do
      Factory(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
      topic = Factory(:topic, :supervision => @supervision, :user => @alice, :content => "What is your favorite color?")
      Factory(:vote, :statement => topic, :user => @alice)

      sign_in_interactive(@bob)
      visit_supervision(@supervision)
      within "#topic_#{topic.id}" do
        click_button "Vote on this topic"
      end
      @supervision.topic.should == topic
    end
  end

  context "in providing_ideas state" do
    background do
      @supervision = prepare_supervision("providing_ideas")
    end

    scenario "allows to add idea by non-topic owner" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      fill_in "idea_content", :with => "I have some idea"
      click_button "Post idea"
      page.should have_content("I have some idea")
    end

    scenario "allows to view posted idea" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      page.should have_content("I have some idea")
    end

    scenario "allows to rate idea" do
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

    scenario "shows rated idea" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      @idea = Factory(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      @idea.update_attributes(:rating => "5")
      within "#idea_#{@idea.id} .rating" do
        page.should have_selector("input[type=radio]#idea_rating_5[checked]")
      end
    end

    scenario "allows to step back" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      within ".supervision_statusbar" do
        click_button "Questions"
      end
      page.should have_flash("Go back to \"Questions\" state")
      within ".supervision_statusbar" do
        page.should have_selector("li.step.current_step input[value=Questions]")
      end
    end
  end

  context "in giving_ideas_feedback state" do
    background do
      @supervision = prepare_supervision("giving_ideas_feedback")
    end

    scenario "allows to rate idea" do
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
    background do
      @supervision = prepare_supervision("providing_solutions")
    end

    scenario "allows to add solution by non-topic owner" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      fill_in "solution_content", :with => "I have a solution"
      click_button "Post solution"
      page.should have_content("I have a solution")
    end

    scenario "allows to view posted solution" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      page.should have_content("I have a solution")
    end

    scenario "allows to rate solution" do
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

    scenario "shows rated solution" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      @solution = Factory(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      @solution.update_attributes(:rating => "4")
      within "#solution_#{@solution.id} .rating" do
        page.should have_selector("input[type=radio]#solution_rating_4[checked]")
      end
    end

    scenario "allows to step back" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      within ".supervision_statusbar" do
        click_button "Questions"
      end
      page.should have_flash(%Q[Go back to "Questions" state])
      within ".supervision_statusbar" do
        page.should have_selector("li.step.current_step input[value=Questions]")
      end
    end
  end

  context "in giving_solutions_feedback state" do
    background do
      @supervision = prepare_supervision("giving_solutions_feedback")
    end

    scenario "allows to rate solution" do
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
