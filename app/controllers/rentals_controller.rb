class RentalsController < ApplicationController
  def checkout
    # change the inventory by -1, add update action to movie
    # create an instance of Rental, with today's date in checkout column and due date defined as today + 7 days
    movie = Movie.find_by(id: params[:movie_id])
    if movie == nil
      render json: { error: "Movie was not found in database or no movie id was provided." }, status: :no_content
      return
    end

    if movie.available_inventory > 0 || movie.available_inventory == nil
      rental = Rental.new(rental_params)

      if rental.save
        customer = Customer.find_by(id: params[:customer_id])
        render json: { id: rental.id }, status: :ok
        existing_movie_count = customer.movies_checked_out_count
        customer.update(movies_checked_out_count: existing_movie_count + 1)

        current_movie_inventory = movie.available_inventory
        movie.update(available_inventory: current_movie_inventory - 1)

        # find customer; update movies_checked_out_count column
        # find movie; update available_inventory
      else
        render json: { error: rental.errors.messages }, status: :bad_request
      end
    else
      render json: { message: "This movie is not available for checkout." }, status: :forbidden
    end
  end

  def checkin
    # change the inventory by +1
    # update instance of rental with checked-in date
  end

  private

  def rental_params
    params.permit(:movie_id, :customer_id, :checkout_date, :due_date, :checked_in_date)
  end
end
