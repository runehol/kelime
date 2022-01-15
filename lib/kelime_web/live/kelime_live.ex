defmodule KelimeWeb.KelimeLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  @wordlen 5
  @numguesses 6

  def render(assigns) do
    Phoenix.View.render(KelimeWeb.PageView, "index.html", assigns)
  end

  def handle_event("update_guess", %{"key" => "Backspace"}, socket) do
    guess = socket.assigns[:guess]

    if String.length(guess) >= 1 do
      {:noreply, assign(socket, :guess, String.slice(guess, 0..-2))}
    else
      {:noreply, socket}
    end

  end

  def handle_event("update_guess", %{"key" => "Enter"}, socket) do
    guess = socket.assigns[:guess]
    previous_guesses = socket.assigns[:previous_guesses]
    if String.length(guess) == 5 do
      {:noreply,
      socket
      |> assign(:previous_guesses, previous_guesses ++ [guess])
      |> assign(:guess, "")
    }
    else
      IO.puts("Attempting flash")
      {:noreply,
      socket
      |> put_flash(:error, "Not enough letters!")
    }
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


  def mount(_params, _, socket) do

    correct_word = "bilde"
    socket2 = socket
    |> assign(:previous_guesses, [])
    |> assign(:guess, "")
    |> assign(:wordlen, @wordlen)
    |> assign(:numguesses, @numguesses)
    |> assign(:correct_word, correct_word)

    {:ok, socket2}
  end


end
