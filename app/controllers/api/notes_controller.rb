class Api::NotesController < ApplicationController
  before_action :require_signed_in!
  before_action :user_owns_note?, only: [:edit, :update, :destroy]
  before_action :authorized?, only: [:show]

  def index
    @notes = current_user.notes.includes(:comments, :notebook, :tags)
    render partial: "notes/index", locals: { notes: @notes }
  end

  def create
    @note = current_user.notes.new(note_params)
    if @note.save
      render json: @note
    else
      render json: @note.errors.full_messages, status: :unprocessable_entity
    end
  end

  def edit
    @note = Note.find(params[:id])
    render json: @note
  end

  def update
    @note = Note.find(params[:id])
    @note.assign_attributes(note_params)

    if @note.save
      render partial: "notes/show", locals: { note: @note }
    else
      render json: @note.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    @note = Note.includes(:comments, :notebook, :tags).find(params[:id])
    render partial: "notes/show", locals: { note: @note }
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    render json: {}
  end

  private
  def user_owns_note?
    @note = Note.find(params[:id])
    redirect_to root_url unless @note.author == current_user
  end

  def authorized?
    author = Note.find(params[:id]).author
    unless (current_user == author || user.find_friendship(current_user))
      redirect_to root_url
    end
  end

  def note_params
    params.require(:note).permit(:title, :body, :notebook_id)
  end
end