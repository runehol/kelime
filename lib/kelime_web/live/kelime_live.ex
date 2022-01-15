defmodule KelimeWeb.KelimeLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  @wordlen 5
  @numguesses 6

  def render(assigns) do
    Phoenix.View.render(KelimeWeb.PageView, "index.html", assigns)
  end

  def report_error(socket, type, message) do
    Process.send_after(self(), :clear_flash, 1500)
    {:noreply,
      socket
      |> put_flash(type, message)
    }
  end

  defp advance_guess(socket) do
    guess = socket.assigns[:guess]
    previous_guesses = socket.assigns[:previous_guesses]
    socket
    |> assign(:previous_guesses, previous_guesses ++ [guess])
    |> assign(:guess, "")
  end

  def handle_event("update_guess", %{"key" => "Enter"}, socket) do
    guess = socket.assigns[:guess]
    previous_guesses = socket.assigns[:previous_guesses]
    correct_word = socket.assigns[:correct_word]
    cond do
      String.length(guess) != 5 -> report_error(socket, :error, "Not enough letters!")
      guess == correct_word ->
        {:noreply,
        socket
        |> advance_guess()
        |> assign(:game_running, false)
        |> put_flash(:info, "Congratulations")
        }
      length(previous_guesses) == @numguesses-1 ->
        {:noreply,
        socket
        |> advance_guess()
        |> assign(:game_running, false)
        |> put_flash(:info, "Game over")}
      true ->
        {:noreply,
        socket
        |> advance_guess()}
    end

  end

  def handle_event("update_guess", %{"key" => "Backspace"}, socket) do
    guess = socket.assigns[:guess]

    if String.length(guess) >= 1 do
      {:noreply, assign(socket, :guess, String.slice(guess, 0..-2))}
    else
      {:noreply, socket}
    end

  end


  def handle_event("update_guess", %{"key" => k}, socket) do
    guess = socket.assigns[:guess]

    if String.length(k) == 1 and String.length(guess) < 5
    do
      {:noreply, assign(socket, :guess, guess <> k)}
    else
      {:noreply, socket}
    end

  end

  def handle_event("game_finished", _, socket) do
    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, socket |> clear_flash()}
  end

  def mount(_params, _, socket) do

    correct_word = "bilde"
    game_running = true
    socket2 = socket
    |> assign(:previous_guesses, [])
    |> assign(:guess, "")
    |> assign(:wordlen, @wordlen)
    |> assign(:game_running, game_running)
    |> assign(:numguesses, @numguesses)
    |> assign(:correct_word, correct_word)

    {:ok, socket2}
  end


end
