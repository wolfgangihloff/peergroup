require "spec_helper"
include SupervisionSpecHelper
feature "Supervision Session", :js => true do
  def visit_supervision(supervision)
    visit supervision_path(supervision)
    page.should have_css(".supervision.connected") # make sure it's connected and authenticated
    page.should have_css(".supervision[data-supervision-updates]")
  end

  def prepare_supervision(state)
    supervision = FactoryGirl.create(:supervision, :group => @group, :state => state, :topic => FactoryGirl.create(:topic, :user => @alice))
    @alice.join_supervision(supervision)
    @bob.join_supervision(supervision)
    @cindy.join_supervision(supervision)
    supervision
  end

  background do
    @alice = FactoryGirl.create(:user, :name => "Alice", :email => "alice@example.com")
    @bob = FactoryGirl.create(:user, :name => "Bob", :email => "bob@example.com")
    @cindy = FactoryGirl.create(:user, :name => "Cindy", :email => "cindy@example.com")

    @group = FactoryGirl.create(:group, :name => "FuFighters")
    @group.add_member!(@alice)
    @group.add_member!(@bob)
    @group.add_member!(@cindy)
  end

  context "in gathering_topics state" do
    background do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
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
      FactoryGirl.create(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
      page.should have_content("Can rails scale?")
    end

    scenario "should suggest last propsed topic" do
      @old_supervision = Factory.create(:supervision, :group => @supervision.group)
      @old_supervision.update_attribute(:topic, Factory.create(:topic, :supervision => @old_supervision, :user => @alice) )

      Factory.create(:supervision_membership, :supervision => @old_supervision, :user => @bob)
      @old_supervision.update_attribute(:state, "finished")

      @topic = Factory.create(:topic, :supervision => @old_supervision, :user => @bob, :content => "Good, ol' topic" )      

      sign_in_interactive(@bob)
      visit_supervision(@supervision)
      page.should have_content("Good, ol' topic")
    end
  end

  context "in voting_on_topics state" do
    background do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "voting_on_topics")
      @alice.join_supervision(@supervision)
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)
    end

    scenario "should allow to vote on topic" do
      FactoryGirl.create(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
      topic = FactoryGirl.create(:topic, :supervision => @supervision, :user => @alice, :content => "What is your favorite color?")
      FactoryGirl.create(:vote, :statement => topic, :user => @alice)

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

      FactoryGirl.create(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      page.should have_content("I have some idea")
    end

    scenario "allows to rate idea" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @idea = FactoryGirl.create(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      page.should have_content("I have some idea")
      rate @idea.content, :with => 5, :scope => "idea"
      page.should have_flash("Idea's rating has been changed")
      within "#idea_#{@idea.id} .rating" do
        page.should have_selector("input[type=radio]#idea_rating_5[checked]")
      end
    end

    scenario "shows rated idea" do
      sign_in_interactive(@bob)
      visit_supervision(@supervision)

      @idea = FactoryGirl.create(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
      @idea.update_attributes!(:rating => "4")
      wait_until do
        page.has_selector?("#idea_#{@idea.id} .rating")
      end
      within "#idea_#{@idea.id} .rating" do
        page.should have_selector("input[type=radio]#idea_rating_4[checked]")
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

      @idea = FactoryGirl.create(:idea, :content => "I have some idea", :supervision => @supervision, :user => @bob)
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

      FactoryGirl.create(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      page.should have_content("I have a solution")
    end

    scenario "allows to rate solution" do
      sign_in_interactive(@alice)
      visit_supervision(@supervision)

      @solution = FactoryGirl.create(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
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

      @solution = FactoryGirl.create(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
      @solution.update_attributes(:rating => "4")
      wait_until do
        page.has_selector?("#solution_#{@solution.id} .rating")
      end
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

      @solution = FactoryGirl.create(:solution, :content => "I have a solution", :supervision => @supervision, :user => @bob)
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
  context "in all states" do
    background do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
      @alice.join_supervision(@supervision)
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)
    end
    scenario "should pass all steps" do
        # Gathering topics
        Capybara.using_session :bob do
          sign_in_interactive(@bob)
          visit_supervision(@supervision)
          fill_in "topic_content", :with => "Can rails scale?"
          click_button "Post your topic"
          Topic.exists?(:content => "Can rails scale?").should be_true
          page.should have_flash("Your topic was successfully added")
        end

        Capybara.using_session :alice do
          sign_in_interactive(@alice)
          visit_supervision(@supervision)
          click_button "Post your topic"
        end

        Capybara.using_session :cindy do
          sign_in_interactive(@cindy)
          visit_supervision(@supervision)
          active_state.should eq "Topics"
          fill_in "topic_content", :with => "Last topic"
          click_button "Post your topic"
          Topic.exists?(:content => "Last topic").should be_true
        end

        # Voting on topics
        @topic = Topic.where(:content => "Can rails scale?").first
        @cindy_topic = Topic.where(:content => "Last topic").first
        Capybara.using_session :bob do
          active_state.should eq "Topic votes"
          page.has_css?(".list .topic", :count => 2)
          within("div#topic_#{@topic.id}") do
            click_button "Vote on this topic"
          end
          page.should have_flash("Your vote was successfully added")
        end

        Capybara.using_session :alice do
          within("div#topic_#{@topic.id}") do
            click_button "Vote on this topic"
          end
          page.find("#topic_#{@cindy_topic.id}_vote_submit")["disabled"].should eq "true"
        end

        Capybara.using_session :cindy do
          within("div#topic_#{@cindy_topic.id}") do
            click_button "Vote on this topic"
          end
          find(".chosen_topic .content p").text.should  eq(@topic.content)
        end

        # Asking questions
        Capybara.using_session :alice do
          # active_state.should eq "Questions"
          fill_in "question_content", :with => "Simple question"
          click_button "Post question"
          fill_in "question_content", :with => "Other question"
          click_button "Post question"
          page.should have_no_selector(".answer")
          page.should have_content("Simple question")
          page.should have_content("Other question")
          page.should have_flash("Your question was successfully added")
        end

        Capybara.using_session :bob do
          page.find("#question_content").visible?.should be_false
          within_question_with_text "Simple question" do
            fill_in "answer_content", :with => "Complex answer"
            click_button "Post answer"
          end
          page.should have_flash("Your answer was successfully added")
          within_question_with_text "Other question" do
            fill_in "answer_content", :with => "I CAN HAZ ANSWER"
            click_button "Post answer"
          end
          page.should have_no_css(".new_answer")
        end

        Capybara.using_session :alice do
          within_answer_for_question_with_text("Simple question") do
            page.should have_content "Complex answer"
          end

          within_answer_for_question_with_text("Other question") do
            page.should have_content "I CAN HAZ ANSWER"
          end
          find(".question .content .discard").click
        end

        Capybara.using_session :cindy do
          fill_in "question_content", :with => "Last question"
          click_button "Post question"
          page.should have_content("Last question")
          find(".question .content .discard").click
        end

        Capybara.using_session :bob do
          # active_state.should eq "Questions"
          within_question_with_text "Last question" do
            fill_in "answer_content", :with => "I don't know, sorry :("
            click_button "Post answer"
          end
          active_state.should eq "Ideas"
        end

        # Providing ideas
        Capybara.using_session :alice do
          fill_in "idea_content", :with => "Good idea"
          click_button "Post idea"
          page.should have_flash("Your idea was successfully added")
          fill_in "idea_content", :with => "Other idea"
          click_button "Post idea"
          find(".idea .content .discard").click
        end
        
        Capybara.using_session :cindy do
          fill_in "idea_content", :with => "Bad idea"
          click_button "Post idea"
          find(".idea .content .discard").click
        end
        
        Capybara.using_session :bob do
          page.find("#idea_content").visible?.should be_false
          rate "Good idea", :with => 5, :scope => "idea"
          rate "Other idea", :with => 3, :scope => "idea"
          rate "Bad idea", :with => 1, :scope => "idea"
          page.should have_flash("Idea's rating has been changed")
        end

        Idea.where(:content => "Good idea").first.rating.should eq 5
        Idea.where(:content => "Other idea").first.rating.should eq 3
        Idea.where(:content => "Bad idea").first.rating.should eq 1
        # Giving ideas feedback

        Capybara.using_session :bob do
          active_state.should eq "Ideas feedback"
          fill_in "ideas_feedback_content", :with => "Sample feedback"
          click_button "Post feedback"
          page.should have_flash("Your feedback was successfully added")
        end

        Capybara.using_session :cindy do
          page.should have_content "Sample feedback"
        end

        # Providing solutins

        Capybara.using_session :alice do
          active_state.should eq "Solutions"
          fill_in "solution_content", :with => "First solution"
          click_button  "Post solution proposition"
          page.should have_flash "Your solution was successfully added"
          fill_in "solution_content", :with => "Second solution"
          click_button  "Post solution proposition"
          find(".solution .content .discard").click
        end

        
        Capybara.using_session :cindy do
          page.should have_content "First solution"
          page.should have_content "Second solution"          
          fill_in "solution_content", :with => "Cindy has solution too"
          click_button  "Post solution proposition"
          # page.should have_flash "Your solution was successfully added"
          find(".solution .content .discard").click
        end

        Capybara.using_session :bob do
          page.find("#solution_content").visible?.should be_false
          page.should have_content "Cindy has solution too"
          rate "First solution", :with => 4, :scope => "solution"
          rate "Second solution", :with => 2, :scope => "solution"
          rate "Cindy has solution too", :with => 3, :scope => "solution"
          page.should have_flash("Solution's rating has been changed")
        end

        Solution.where(:content => "First solution").first.rating.should eq 4
        Solution.where(:content => "Second solution").first.rating.should eq 2
        Solution.where(:content => "Cindy has solution too").first.rating.should eq 3

        # Giving solutions feedback

        Capybara.using_session :cindy do
          page.find("#solutions_feedback_content").visible?.should be_false
        end

        Capybara.using_session :bob do
          fill_in "solutions_feedback_content", :with => "Thanks guys!"
          click_button "Post feedback"
          page.should have_flash("Your feedback was successfully added")
        end

        Capybara.using_session :alice do
          page.should have_content "Thanks guys!"
          active_state.should eq "Supervision feedbacks"
        end

        # Giving supervision feedback

        Capybara.using_session :bob do
          fill_in "supervision_feedback_content", :with => "Sample supervision feedback"
          click_button "Post feedback"
          page.should have_flash("Your feedback was successfully added")
        end

        Capybara.using_session :alice do
          fill_in "supervision_feedback_content", :with => "Alice posts her feedback ;)"
          click_button "Post feedback"
          page.should have_flash("Your feedback was successfully added")
        end

        Capybara.using_session :cindy do
          page.should have_content "Sample supervision feedback"
          page.should have_content "Alice posts her feedback ;)"
          click_button "Post feedback"
          page.should have_flash "You must type your feedback before posting"
          fill_in "supervision_feedback_content", :with => "I CAN HAZ FEEDBACK TOO!"
          click_button "Post feedback"
          page.should have_flash("Your feedback was successfully added")          
        end

        Capybara.using_session :bob do
          page.should have_content "This supervision is finished"
        end
    end
  end
end
