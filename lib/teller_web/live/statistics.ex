defmodule TellerWeb.Live.Statistics do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  alias Phoenix.PubSub
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    Current temperature: <%= @request %>
    """
  end

  def mount(_params, session, socket) do
    user_id = session["user_id"]
    if connected?(socket), do: PubSub.subscribe(Teller.PubSub, user_id)

    {:ok, assign(socket, :request, 0)}
  end

  def handle_info(:incr, socket) do
    val = socket.assigns.request
    {:noreply, assign(socket, :request, val + 1)}
  end
end
