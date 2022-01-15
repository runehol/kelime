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

  defp classify(w, c) do
    word = String.graphemes(w)
    correct = String.graphemes(c)
    classification = Enum.zip(word, correct) |> Enum.map(fn {w, c} ->
      cond do
        w == c -> {:correct, w}
        true -> {:incorrect, w}
      end
    end)

    freqs = Enum.zip(classification, correct)
    |> Enum.filter(fn {{:incorrect, _}, _} -> true
                      _ -> false
    end)
    |> Enum.map(fn {_, c} -> c end)
    |> Enum.frequencies()

    {rev_list, _} = Enum.reduce(classification, {[], freqs}, fn {classification, w}, {so_far, f} ->
      cond do
        classification == :correct -> {[{classification, w}|so_far], f}
        Map.get(f, w, 0) > 0 -> {[{:wrong_pos, w}|so_far], Map.update!(f, w, &(&1-1))}
        true -> {[{:incorrect, w}|so_far], f}
      end
    end)
    Enum.reverse(rev_list)
  end

  defp advance_guess(socket) do
    guess = socket.assigns[:guess]
    previous_guesses = socket.assigns[:previous_guesses]
    correct_word = socket.assigns[:correct_word]

    socket
    |> assign(:previous_guesses, previous_guesses ++ [classify(guess, correct_word)])
    |> assign(:guess, "")
  end

  def handle_event("update_guess", %{"key" => "Enter"}, socket) do
    guess = socket.assigns[:guess]
    previous_guesses = socket.assigns[:previous_guesses]
    correct_word = socket.assigns[:correct_word]
    allowed_words = KelimeWeb.WordLists.get_allowed_words(socket.assigns[:language])
    cond do
      String.length(guess) != 5 -> report_error(socket, :error, "Ikke nok bokstaver!")
      !MapSet.member?(allowed_words, guess) -> report_error(socket, :error, "Ikke et ord!")
      guess == correct_word ->
        {:noreply,
        socket
        |> advance_guess()
        |> assign(:game_running, false)
        |> put_flash(:info, "Gratulerer, du vant!")
        }
      length(previous_guesses) == @numguesses-1 ->
        {:noreply,
        socket
        |> advance_guess()
        |> assign(:game_running, false)
        |> put_flash(:info, "Beklager, du tapte :/")}
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

  def word_of_the_day(language) do
    date = Date.utc_today()
    answer_words = KelimeWeb.WordLists.get_answer_words(language)
    :rand.seed(:exsss, {date.day, date.month, date.year})
    Enum.random(answer_words)
  end

  def mount(_params, _, socket) do

    language = "nb"

    correct_word = word_of_the_day(language)


    socket2 = socket
    |> assign(:language, language)
    |> assign(:previous_guesses, [])
    |> assign(:guess, "")
    |> assign(:wordlen, @wordlen)
    |> assign(:game_running, true)
    |> assign(:numguesses, @numguesses)
    |> assign(:correct_word, correct_word)

    {:ok, socket2}
  end


end
