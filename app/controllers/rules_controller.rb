class RulesController < ApplicationController

  before_filter :require_parent_group
  before_filter :require_rule, :except => [:create, :new]

  def new
    @rule = @group.rules.build
  end

  def create
    @rule = @group.rules.build(params[:rule])
    if @rule.save
      successful_flash("Successfully created rule.")
      redirect_to @group
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @rule.update_attributes(params[:rule])
      successful_flash("Successfully updated rule.")
      redirect_to @group
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @rule.destroy
    successful_flash("Successfully destroyed rule.")
    redirect_to @group
  end

  protected

  def require_rule
    @rule = @group.rules.find(params[:id])
  end
end

