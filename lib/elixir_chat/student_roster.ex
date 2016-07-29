defmodule ElixirChat.StudentRoster do
  alias ElixirChat.Student

  def new do
    HashDict.new
  end

  def add(roster, student = %Student{}) do
    Dict.put(roster, student.id, student)
  end

  def remove(roster, student_id) do
    Dict.delete(roster, student_id)
  end

  def assign_teacher_to_student(roster, teacher_id, student_id) do
    Dict.update!(roster, student_id, fn(s) -> set_teacher_on_student(s, teacher_id) end)
  end

  def chat_finished(roster, student_id) do
    Dict.update!(roster, student_id, fn(s) -> set_finished(s) end)
  end

  def next_waiting(roster) do
    Enum.filter(students(roster), fn(s) -> s.status == "waiting" end)
      |> Enum.sort_by(fn(s) -> s.id end)
      |> Enum.at(0)
  end

  def set_teacher_on_student(student = %Student{}, teacher_id) do
    Map.merge(student, %{status: "chatting", teacher_id: teacher_id})
  end

  def stats(roster) do
    students = students(roster)

    %{
      total:    length(students),
      waiting:  waiting(students),
      chatting: chatting(students),
      finished: finished(students),
    }
  end

  def stats_extended(roster) do
    students = students(roster)

    %{
      total:    length(students),
      waiting:  waiting(students),
      chatting: chatting(students),
      finished: finished(students),
      students: students
    }
  end

  def students(roster) do
    Dict.values(roster)
  end

  defp set_finished(student) do
    Map.merge(student, %{status: "finished", teacher_id: nil})
  end

  defp waiting(students) do
    Enum.count(students, fn(s) -> s.status == "waiting" end)
  end

  defp chatting(students) do
    Enum.count(students, fn(s) -> s.status == "chatting" end)
  end

  defp finished(students) do
    Enum.count(students, fn(s) -> s.status == "finished" end)
  end
end
