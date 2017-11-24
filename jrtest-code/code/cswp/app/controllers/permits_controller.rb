#---
# Excerpted from "The Way of the Web Tester",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
#---
class PermitsController < ApplicationController
  before_action :set_permit, only: [:show, :edit, :update, :destroy]

  # GET /permits
  # GET /permits.json
  def index
    @permits = Permit.all
  end

  # GET /permits/1
  # GET /permits/1.json
  def show
  end

  # GET /permits/new
  def new
    @permit = Permit.new
    @locations = ['Saskatoon']
  end

  # GET /permits/1/edit
  def edit
  end

  # POST /permits
  # POST /permits.json
  def create
    @permit = Permit.new(permit_params)

    respond_to do |format|
      if @permit.save
        flash[:success] = 'Permit was successfully created.'
        format.html { redirect_to @permit }
        format.json { render :show, status: :created, location: @permit }
      else
        format.html { render :new }
        format.json { render json: @permit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permits/1
  # PATCH/PUT /permits/1.json
  def update
    respond_to do |format|
      if @permit.update(permit_params)
        flash[:success] = 'Permit was successfully updated.'
        format.html { redirect_to @permit }
        format.json { render :show, status: :ok, location: @permit }
      else
        format.html { render :edit }
        format.json { render json: @permit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permits/1
  # DELETE /permits/1.json
  def destroy
    @permit.destroy
    flash[:success] = 'Permit was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to permits_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permit
      @permit = Permit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def permit_params
      params.require(:permit).permit(:location)
    end
end
