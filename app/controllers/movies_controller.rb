class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    #sorting da columnz
    if session[:sort_title].nil?
      session[:sort_title] = 0
    end
    if session[:sort_release_date].nil?
      session[:sort_release_date] = 0
    end
      
    if not params[:sort_title].nil?
      session[:sort_title] = 1
      session[:sort_release_date] = 0
    end
    if not params[:sort_release_date].nil?
      session[:sort_title] = 0
      session[:sort_release_date] = 1
    end
    
    params[:sort_title] = session[:sort_title]
    params[:sort_release_date] = session[:sort_release_date]

    #no ratings passed in
    if params[:ratings].nil?
      flash.keep
      #if no selection then display all 
      if session[:selected_ratings].nil?
        rat = {} ; 
        @all_ratings.each { |r| rat[r] = "yes" } ; 
        session[:selected_ratings] = rat
        @selected_ratings = session[:selected_ratings]
      else
        @selected_ratings = session[:selected_ratings]
        if not params[:sort].nil?
          session[:sort] = params[:sort]
        end
      end
      # session reflects params sorting 
      if not params[:sort].nil?
        session[:sort] = params[:sort] 
      end
      redirect_to movies_path :ratings => @selected_ratings, :sort => session[:sort]
      return
    else
      session[:selected_ratings] = params[:ratings]
      @selected_ratings = session[:selected_ratings]
    end
    
    temp = Movie
    if not session[:selected_ratings].nil?
      temp = temp.where(:rating => session[:selected_ratings].keys)
    end

    @movies = temp.order(params[:sort])
    
    if session[:sort_title] == 1
      @movies = temp.order(:title).where(:rating => session[:selected_ratings].keys)
    elsif session[:sort_release_date] == 1
      @movies = temp.order(:release_date).where(:rating => session[:selected_ratings].keys)
    else
      #@sort_what = "n/a"
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  
end
