class KrasController < ApplicationController
  before_action :require_admin
  before_action :set_valid_role, only: [:edit, :update]

  def index
    @kras_by_role = Kra.order(:position).group_by(&:role)
  end

  def edit
    @kras = Kra.where(role: @role).order(:position)
  end

  def update
    rows = (params[:kras] || {}).values.map do |row|
      { name: row[:name].to_s.strip, weight: row[:weight].to_s.strip }
    end.reject { |row| row[:name].blank? }

    total_weight = rows.sum { |row| row[:weight].to_f }

    if rows.empty? || (total_weight - 100.0).abs > 0.01
      @kras = rows.each_with_index.map { |row, i| Kra.new(role: @role, name: row[:name], weight: row[:weight], position: i) }
      flash.now[:error] = "KRA weights for #{@role} must add up to 100% (currently #{total_weight.round(2)}%)."
      render :edit
      return
    end

    Kra.transaction do
      Kra.where(role: @role).destroy_all
      rows.each_with_index do |row, i|
        Kra.create!(role: @role, name: row[:name], weight: row[:weight], position: i)
      end
    end

    flash[:notice] = "KRA weights for #{@role} updated successfully."
    redirect_to edit_kra_path(role: @role)
  end

  private

  def set_valid_role
    @role = params[:role]
    render_404 unless Kra::ROLES.include?(@role)
  end
end
