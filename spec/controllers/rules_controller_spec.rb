require File.dirname(__FILE__) + '/../spec_helper'
 
describe RulesController do
  integrate_views

  before do
    @group = Factory(:group)
  end
  
  it "new action should render new template" do
    get :new, :group_id => @group.id
    response.should render_template(:new)
  end
  
  it "create action should render new template when model is invalid" do
    post :create, :group_id => @group.id, :rule => {:name => ''}
    response.should render_template(:new)
  end
  
  it "edit action should render edit template" do
    get :edit, :id => @group.rules.first, :group_id => @group.id
    response.should render_template(:edit)
  end
  
  it "update action should render edit template when model is invalid" do
    put :update, :id => @group.rules.first, :group_id => @group.id, :rule => {:name => ''}
    response.should render_template(:edit)
  end
  
  it "destroy action should destroy model and redirect to index action" do
    rule = @group.rules.first
    delete :destroy, :id => rule, :group_id => @group.id
    response.should redirect_to(group_url(@group))
    Rule.exists?(rule.id).should be_false
  end
end
