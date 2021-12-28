defmodule TellerWeb.Live.Statistics do
  @moduledoc """
    Generates live view dashboard that gives the count of api calls for a given token.
    It uses phoenix pubsub to increment the api count to the live view process.
  """
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
