defmodule KelimeWeb.KelimeLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(KelimeWeb.PageView, "index.html", assigns)
    #~H"""
    #Current time: <%= @time %>
    #"""
  end

  def mount(_params, _, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    time = DateTime.utc_now
    {:ok, assign(socket, :time, time)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    time = DateTime.utc_now
    {:noreply, assign(socket, :time, time)}
  end
end
