defmodule TellerWeb.Live.Statistics do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  alias Phoenix.PubSub
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <b>Token:</b> <%= @token%>
    <br>
    <b>Api count:</b> <%= @request %>

    """
  end

  def mount(_params, session, socket) do
    token = session["token"]
    if connected?(socket), do: PubSub.subscribe(Teller.PubSub, token)

    {:ok, assign(socket, :request, 0) |> assign(:token, token)}
  end

  def handle_info(:incr, socket) do
    val = socket.assigns.request
    {:noreply, assign(socket, :request, val + 1)}
  end
end
