defmodule CountdownGui do
  @moduledoc false
  import Bitwise
  import WX

  require Record

  Record.defrecord(:wx, Record.extract(:wx, from_lib: "wx/include/wx.hrl"))

  def start(seconds) when is_integer(seconds) do
    :wx.new()
    frame = :wxFrame.new(:wx.null(), wxID_ANY(), "Countdown")

    label = :wxStaticText.new(frame, wxID_ANY(), "Seconds remaining", style: wxTE_RIGHT())
    :wxStaticText.wrap(label, 100)

    counter =
      :wxTextCtrl.new(frame, wxID_ANY(), value: Integer.to_charlist(seconds), style: wxALIGN_RIGHT())

    font = :wxFont.new(42, wxFONTFAMILY_DEFAULT(), wxFONTSTYLE_NORMAL(), wxFONTWEIGHT_BOLD())
    :wxTextCtrl.setFont(counter, font)

    button =
      :wxButton.new(frame, wxID_ANY(), label: "Start", pos: {0, 64}, style: wxBU_LEFT())

    counter_sizer = :wxBoxSizer.new(wxHORIZONTAL())
    :wxSizer.add(counter_sizer, label, flag: wxALL() ||| wxALIGN_CENTRE(), border: 5)
    :wxSizer.add(counter_sizer, counter, flag: wxALL() ||| wxEXPAND(), border: 5, proportion: 1)

    main_sizer = :wxBoxSizer.new(wxVERTICAL())
    :wxSizer.add(main_sizer, counter_sizer, flag: wxALL() ||| wxEXPAND())
    :wxSizer.add(main_sizer, button, flag: wxALL() ||| wxEXPAND(), border: 5)
    :wxWindow.setSizer(frame, main_sizer)
    :wxSizer.setSizeHints(main_sizer, frame)

    :wxButton.connect(button, :command_button_clicked,
      callback: &handle_click/2,
      userData: %{counter: counter, env: :wx.get_env()}
    )

    :wxFrame.show(frame)
  end

  defp handle_click(wx(obj: button, userData: %{counter: counter, env: env}), _Event) do
    :wx.set_env(env)
    label = :wxButton.getLabel(button)

    case List.to_integer(:wxTextCtrl.getValue(counter)) do
      0 when label == ~c"Start" ->
        :ok

      _ when label == ~c"Start" ->
        :wxTextCtrl.setEditable(counter, false)
        :wxButton.setLabel(button, ~c"Stop")
        :timer.apply_after(1000, __MODULE__, :update_gui, [counter, button, env])

      _ when label == ~c"Stop" ->
        :wxTextCtrl.setEditable(counter, true)
        :wxButton.setLabel(button, ~c"Start")
    end
  end

  def update_gui(counter, button, env) do
    :wx.set_env(env)

    case :wxButton.getLabel(button) do
      ~c"Stop" ->
        value = :wxTextCtrl.getValue(counter)

        case List.to_integer(value) do
          1 ->
            :wxTextCtrl.setValue(counter, ~c"0")
            :wxTextCtrl.setEditable(counter, true)
            :wxButton.setLabel(button, ~c"Start")

          n ->
            :wxTextCtrl.setValue(counter, Integer.to_charlist(n - 1))
            :timer.apply_after(1000, __MODULE__, :update_gui, [counter, button, env])
        end

      ~c"Start" ->
        :ok
    end
  end
end
