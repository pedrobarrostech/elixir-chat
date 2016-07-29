defmodule ElixirChat.PresenceChannel do
  use Phoenix.Channel

  alias ElixirChat.Teacher
  alias ElixirChat.Student

  alias ElixirChat.ChatLifetimeServer, as: Chats
  alias ElixirChat.TeacherRosterServer, as: Teachers
  alias ElixirChat.StudentRosterServer, as: Students

  def join("presence:teachers", %{"userId" => id, "role" => "teacher"}, socket) do
    Teachers.add %Teacher{id: id}
    socket = assign(socket, :id, id)
    {:ok, %{}, socket}
  end

  def join("presence:" <> topic, %{"userId" => id, "role" => "student"}, socket) do
    Process.flag(:trap_exit, true)

    # not broadcasting status student here because it causes races
    {:ok, %{}, socket}
  end

  def terminate({:shutdown, :left}, socket) do
    # client left intentionally
    Students.remove(socket.assigns[:id])
    broadcast_status
    {:ok, socket}
  end

  def terminate(reason, socket) do
    # terminating for another reason (connection drop, crash, etc)
  end

  def handle_in("student:ready", %{"userId" => id}, socket) do
    Students.add %Student{id: id}
    socket = assign(socket, :id, id)
    broadcast_status
    {:noreply, socket}
  end

  def handle_in("claim:student", %{"teacherId" => teacher_id}, socket) do
    chat = Chats.create_chat_for_next_student(teacher_id)

    if chat do
      push socket, "new:chat:#{chat.teacher_id}", chat
      ElixirChat.Endpoint.broadcast! "presence:student:#{chat.student_id}", "new:chat", chat
    end

    {:noreply, socket}
  end

  def broadcast_status do
    data = %{
      teachers: Teachers.stats,
      students: Students.stats
    }

    ElixirChat.Endpoint.broadcast! "presence:teachers", "user:status", data
  end
end
