require 'spec_helper'

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
        :flash => {:successful => "successful", :error => "error"}
      }},
      :key => "unscoped key",
      :overwritten => {:key => "overwritten scope key"}
    })
  end

  describe "t method" do
    specify { @controller.t("key").should == "unscoped key" }
    specify { @controller.t(".key").should == "scoped key" }
    specify { @controller.t(".key", :overwritten_scope => "").should == "unscoped key" }
    specify { @controller.t(".key", :overwritten_scope => [:overwritten]).should == "overwritten scope key" }
  end

  {:successful => :notice, :error => :error}.each_pair do |result, flash_type|
    describe "#{result}_flash method" do
      it "should set flash #{flash_type} from stored translation when available" do
        @controller.send("#{result}_flash", "does not matter")
        @controller.flash[flash_type].should == result.to_s
      end

      it "should set flash #{flash_type} from default when stored translation not available" do
        @controller.send("#{result}_flash", "default", :scope => :other)
        @controller.flash[flash_type].should == "default"
      end

      it "should overwrite scope" do
        @controller.send("#{result}_flash", "default", :key => "key")
        @controller.flash[flash_type].should == "unscoped key"
      end
    end
  end
end

