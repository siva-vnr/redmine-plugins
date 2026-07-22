class TacticalMeetingReviewsController < ApplicationController
  before_action :require_admin
  before_action :set_tactical_meeting_response

  def new
    return redirect_to edit_tactical_meeting_response_review_path(@tactical_meeting_response) if @tactical_meeting_response.tactical_meeting_review

    @role = params[:role]
    @kras = @role.present? ? Kra.where(role: @role).order(:position) : []
    @tactical_meeting_review = TacticalMeetingReview.new
  end

  def create
    return redirect_to edit_tactical_meeting_response_review_path(@tactical_meeting_response) if @tactical_meeting_response.tactical_meeting_review

    role = params[:role]
    kras = Kra.where(role: role).order(:position)
    scores = params[:scores] || {}

    @tactical_meeting_review = TacticalMeetingReview.new(
      tactical_meeting_response: @tactical_meeting_response,
      reviewer: User.current,
      role: role,
      comment: params.dig(:tactical_meeting_review, :comment)
    )

    kras.each do |kra|
      @tactical_meeting_review.tactical_meeting_review_items.build(
        kra: kra,
        kra_name: kra.name,
        weight: kra.weight,
        score: scores[kra.id.to_s]
      )
    end

    if @tactical_meeting_review.save
      flash[:notice] = "Review saved successfully."
      redirect_to tactical_meeting_response_path(@tactical_meeting_response)
    else
      @role = role
      @kras = kras
      render :new
    end
  end

  def edit
    @tactical_meeting_review = @tactical_meeting_response.tactical_meeting_review
    render_404 unless @tactical_meeting_review
  end

  def update
    @tactical_meeting_review = @tactical_meeting_response.tactical_meeting_review
    return render_404 unless @tactical_meeting_review

    scores = params[:scores] || {}
    @tactical_meeting_review.comment = params.dig(:tactical_meeting_review, :comment)
    @tactical_meeting_review.tactical_meeting_review_items.each do |item|
      item.score = scores[item.id.to_s] if scores.key?(item.id.to_s)
    end

    if @tactical_meeting_review.save
      flash[:notice] = "Review updated successfully."
      redirect_to tactical_meeting_response_path(@tactical_meeting_response)
    else
      render :edit
    end
  end

  private

  def set_tactical_meeting_response
    @tactical_meeting_response = TacticalMeetingResponse.find(params[:tactical_meeting_response_id])
  end
end
