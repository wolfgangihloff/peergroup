require 'spec_helper'
require 'flash_messages'

describe FlashMessages do
  class Controller
    include FlashMessages

    def controller_name; "controller"; end
    def action_name; "action"; end
    def flash; @flash ||= {}; end
  end

  before do
    @controller = Controller.new
    I18n.backend.store_translations(:en, {
      :controller => {:action => {
        :key => "scoped key",
        :flash => {:success => "success!"}
      }},
      :key => "unscoped key"
    })
  end

  describe "t method" do
    specify { @controller.t("key").should == "unscoped key" }
    specify { @controller.t(".key").should == "scoped key" }
  end

  describe "successful_flash method" do
    it "should set flash notice from stored translation when available" do
      @controller.successful_flash("does not matter")
      @controller.flash[:notice].should == "success!"
    end

    it "should set flash notice from default when stored translation not available" do
      @controller.successful_flash("default", :scope => :other)
      @controller.flash[:notice].should == "default"
    end
  end
end

