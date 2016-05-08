require_dependency 'exception_canary/application_controller'

module ExceptionCanary
  class GroupsController < ApplicationController
    helper_method :sort_column, :sort_direction

    def index
      @groups = Group.scoped.calculated(:exceptions_count, :most_recent_exception).order(sort_param).page(params[:page])
    end

    def show
      @group = Group.find(params[:id])
      @stored_exception = @group.stored_exceptions.last
    end

    def edit
      @group = Group.find(params[:id])
    end

    def update
      @group = Group.find(params[:id])
      params[:group][:value].gsub!("\r\n", "\n") if params[:group][:value]
      if @group.update_attributes(params[:group].merge(is_auto_generated: false))
        reclassified_msg = flash_num_reclassified(reclassify_exceptions)
        redirect_to @group, flash: { notice: "Updated group and reclassified #{reclassified_msg}." }
      else
        render :edit
      end
    end

    def destroy
      group = Group.find(params[:id])
      group.destroy
      redirect_to groups_path, flash: { notice: 'Deleted group.' }
    end

    private

    def sort_param
      "#{sort_column} #{sort_direction}"
    end

    def sort_column
      Group.column_names.concat(%w(exceptions_count most_recent_exception)).include?(params[:sort]) ? params[:sort] : 'most_recent_exception'
    end

    def sort_direction
      default = sort_column == 'most_recent_exception' ? 'desc' : 'asc'
      %w(asc desc).include?(params[:direction]) ? params[:direction] : default
    end

    def reclassify_exceptions
      exceptions_reclassified = 0
      StoredException.all.each do |se|
        if se.group == @group
          unless @group.matches? se
            se.group = nil
            se.save!
            exceptions_reclassified += 1
          end
        elsif @group.matches? se
          old_group = se.group
          se.group = @group
          se.save!
          old_group.destroy if old_group && old_group.auto_generated? && old_group.stored_exceptions.empty?
          exceptions_reclassified += 1
        end
      end
      exceptions_reclassified
    end

    def flash_num_reclassified(num_reclassified)
      ActionController::Base.helpers.pluralize(num_reclassified, 'exception')
    end
  end
end
