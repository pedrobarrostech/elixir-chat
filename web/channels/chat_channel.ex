defmodule ElixirChat.ChatChannel do
  use Phoenix.Channel
  alias ElixirChat.ChatLogServer, as: Log
  alias ElixirChat.ChatLifetimeServer, as: ChatLifetime

  def join("chats:" <> chat_id, %{"userId" => id, "role" => "teacher"}, socket) do
    socket = assign(socket, :teacher_id, id)
    socket = assign(socket, :chat_id, chat_id)

    {:ok, %{}, socket}
  end

  def join("chats:" <> chat_id, %{"userId" => id, "role" => "student"}, socket) do
    socket = assign(socket, :student_id, id)
    socket = assign(socket, :chat_id, chat_id)

    {:ok, %{}, socket}
  end

  def handle_in("teacher:joined", message, socket) do
    id      = socket.assigns[:teacher_id]
    chat_id = socket.assigns[:chat_id]

    chat = Log.teacher_entered(chat_id, id)

    if chat.teacher_entered && chat.student_entered do
      broadcast! socket, "chat:ready", %{}
    end

    {:noreply, socket}
  end

  def handle_in("student:joined", message, socket) do
    id      = socket.assigns[:student_id]
    chat_id = socket.assigns[:chat_id]

    chat = Log.student_entered(chat_id, id)

    if chat.teacher_entered && chat.student_entered do
      broadcast! socket, "chat:ready", %{}
    end

    {:noreply, socket}
  end

  def handle_in("student:send", payload, socket) do
    chat_id = socket.assigns[:chat_id]

    Log.append_message chat_id, "student", payload["message"]
    broadcast! socket, "teacher:receive", payload
    {:noreply, socket}
  end

  def handle_in("teacher:send", payload, socket) do
    chat_id = socket.assigns[:chat_id]

    Log.append_message chat_id, "teacher", payload["message"]
    broadcast! socket, "student:receive", payload
    {:noreply, socket}
  end

  def handle_in("chat:terminate", payload, socket) do
    chat_id = socket.assigns[:chat_id]

    ChatLifetime.finish chat_id
    broadcast! socket, "chat:terminated", %{}
    {:noreply, socket}
  end

  def handle_out(event = "student:receive", payload, socket) do
    if socket.assigns[:student_id] do
      push socket, event, payload
    end
    {:noreply, socket}
  end

  def handle_out(event = "teacher:receive", payload, socket) do
    if socket.assigns[:teacher_id] do
      push socket, event, payload
    end
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    # terminating for another reason (connection drop, crash, etc)
  end
end
