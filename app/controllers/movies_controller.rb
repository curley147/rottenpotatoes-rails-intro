class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    # colour title clicked
    if params[:title_click]=="yes"
      session[:title_class]="hilite"
      session[:release_date_class]=""
    elsif params[:release_date_click]=="yes"
      session[:title_class]=""
      session[:release_date_class]="hilite"
    end
    # sorting movies in ascending
    if session[:title_class]=="hilite"
     @movies = @movies.all.order(:title)
    elsif session[:release_date_class]=="hilite"
     @movies = @movies.all.order(:release_date)
    end
    
    # just loading records with 'rating' attribute
    @all_ratings = Movie.distinct.pluck(:rating)
    #if its not a new user - load data
    if params[:ratings]!=nil
     session[:checked]=params[:ratings]
    end
    #if its a new user check all boxes
    if session[:checked]==nil
      session[:checked]=Hash.new()
      @all_ratings.each do |rating|
       session[:checked][rating]=1
      end
    end
    
    @movies = @movies.where({rating: session[:checked].keys})
    
    # setting titles clickable and colour
    if session[:title_class]=="hilite" and params[:title_click]==nil 
      params[:title_click]="yes"
      redirect_to movies_path(params)
    elsif session[:release_date_class]=="hilite" and params[:release_date_click]==nil
      params[:release_date_click]="yes"
      redirect_to movies_path(params)
    elsif params[:ratings]==nil and session[:checked]!=nil
      params[:ratings]=session[:checked]
      flash.keep
      redirect_to movies_path(params)
    end
    
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end